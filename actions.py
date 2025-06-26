from typing import Dict, Text, Any, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.events import SlotSet, ActiveLoop, UserUtteranceReverted, FollowupAction
import psycopg2
import logging
import json
import uuid
import re

# Set up logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Database connection helper
try:
    from .db_utils import get_db_connection
except ImportError:
    def get_db_connection():
        import os
        from dotenv import load_dotenv
        load_dotenv()
        
        try:
            conn = psycopg2.connect(
                dbname=os.getenv("DB_NAME", "retail_db"),
                user=os.getenv("DB_USER", "postgres"),
                password=os.getenv("DB_PASSWORD", "postgres"),
                host=os.getenv("DB_HOST", "localhost"),
                port=os.getenv("DB_PORT", "5432")
            )
            logger.info("Database connection established successfully")
            return conn
        except Exception as e:
            logger.error(f"Database connection failed: {str(e)}")
            return None

# ===== CONVERSATION HANDLERS =====
class ActionHandleOrderStatus(Action):
    """Handle order status scenarios"""
    
    def name(self) -> Text:
        return "action_handle_order_status"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        tracking_number = tracker.get_slot("tracking_number")
        email = tracker.get_slot("email")
        
        if tracking_number and email:
            dispatcher.utter_message(response="utter_order_status_header")
            return [FollowupAction("action_check_order_status")]
        elif email:
            dispatcher.utter_message(response="utter_ask_tracking_number")
            return []
        else:
            dispatcher.utter_message(response="utter_ask_email_for_orders")
            return []

class ActionHandleComplaintStatus(Action):
    """Handle complaint status scenarios"""
    
    def name(self) -> Text:
        return "action_handle_complaint_status"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        complaint_id = tracker.get_slot("complaint_id")  # CHANGED: tracking_number -> complaint_id
        email = tracker.get_slot("email")
        
        if complaint_id and email:
            dispatcher.utter_message(response="utter_complaint_status_header")
            return [FollowupAction("action_check_complaint_status")]
        elif complaint_id:
            dispatcher.utter_message(response="utter_ask_email_for_complaint")
            return []
        else:
            dispatcher.utter_message(response="utter_ask_complaint_reference")
            return []
        
class ActionHandleEscalation(Action):
    """Handle escalation scenarios"""
    
    def name(self) -> Text:
        return "action_handle_escalation"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        email = tracker.get_slot("email")
        complaint_id = tracker.get_slot("complaint_id")
        
        if email and complaint_id:
            return [FollowupAction("action_escalate_to_agent")]
        elif not email:
            dispatcher.utter_message(response="utter_ask_email_for_escalation")
            return []
        else:
            dispatcher.utter_message(response="utter_ask_complaint_reference")  # CHANGED: Consistent response
            return []

class ActionHandleRecommendations(Action):
    """Handle recommendation scenarios"""
    
    def name(self) -> Text:
        return "action_handle_recommendations"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        email = tracker.get_slot("email")
        
        if email:
            dispatcher.utter_message(response="utter_recommendation_header")
            return [FollowupAction("action_recommend_products")]
        else:
            dispatcher.utter_message(response="utter_ask_email_for_recs")
            return []

# ===== VALIDATION AND UTILITY =====
class ActionValidateSlots(Action):
    """Smart slot validation that works in all contexts"""
    
    def name(self) -> Text:
        return "action_validate_slots"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Get current slots
        email = tracker.get_slot("email")
        tracking_number = tracker.get_slot("tracking_number")
        complaint_id = tracker.get_slot("complaint_id")  # ADDED: Complaint ID validation
        events = []
        
        # Validate only when slots are present
        if email and not self.validate_email(email):
            dispatcher.utter_message("❌ That email doesn't look right. Please provide a valid email address")
            events.append(SlotSet("email", None))
        
        if tracking_number and not self.validate_tracking(tracking_number):
            dispatcher.utter_message("❌ Invalid tracking number format. Should be like TRACK-ab12cd34")
            events.append(SlotSet("tracking_number", None))
        
        # ADDED: Complaint ID validation
        if complaint_id and not self.validate_complaint_id(complaint_id):
            dispatcher.utter_message("❌ Invalid complaint reference format. Should be like 4f7717b3-84aa-460d-b9e5-fea3dc2afb80")
            events.append(SlotSet("complaint_id", None))
            
        return events
    
    def validate_email(self, email: Text) -> bool:
        """Validate email format using regex"""
        if not email:
            return False
        pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$"
        return re.match(pattern, email) is not None
    
    def validate_tracking(self, tracking: Text) -> bool:
        """Validate tracking number format"""
        if not tracking:
            return False
        return tracking.startswith("TRACK-") and len(tracking) > 7
    
    # ADDED: Complaint ID validation
    def validate_complaint_id(self, comp_id: Text) -> bool:
        """Validate complaint reference format"""
        if not comp_id:
            return False
        # Validate UUID format
        uuid_pattern = r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
        return re.match(uuid_pattern, comp_id) is not None

# ===== CORE FUNCTIONALITY =====
class ActionCheckOrderStatus(Action):
    """Fetch order status from database"""
    
    def name(self) -> Text:
        return "action_check_order_status"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        tracking_number = tracker.get_slot("tracking_number")
        email = tracker.get_slot("email")
        
        if not (tracking_number and email):
            return []
        
        # Initialize connection to None
        conn = None
        try:
            conn = get_db_connection()
            if not conn:
                raise Exception("Database connection failed")
                
            with conn.cursor() as cur:
                # UPDATED QUERY: Removed product name join
                cur.execute("""
                    SELECT o.status, o.estimated_delivery
                    FROM orders o
                    JOIN customers c ON o.customer_id = c.customer_id
                    WHERE o.tracking_number = %s AND c.email = %s
                """, (tracking_number, email))
                
                if result := cur.fetchone():
                    status, delivery_date = result
                    message = (
                        f"📦 Order {tracking_number}\n"
                        f"Status: {status.upper()}\n"
                        f"Estimated Delivery: {delivery_date}"
                    )
                else:
                    message = f"❌ Order {tracking_number} not found. Please verify your details."
                    
                dispatcher.utter_message(message)
                
        except Exception as e:
            logger.error(f"Database error: {str(e)}", exc_info=True)
            dispatcher.utter_message("⚠️ Sorry, I encountered an error. Please try again later.")
        finally:
            # Only close if connection was established
            if conn:
                conn.close()
                
        return []

class ActionCheckComplaintStatus(Action):
    """Check complaint status"""
    
    def name(self) -> Text:
        return "action_check_complaint_status"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # CHANGED: Use complaint_id instead of tracking_number
        complaint_id = tracker.get_slot("complaint_id")
        email = tracker.get_slot("email")
        
        if not (complaint_id and email):
            return []
        
        # Initialize connection to None
        conn = None
        try:
            conn = get_db_connection()
            if not conn:
                raise Exception("Database connection failed")
                
            with conn.cursor() as cur:
                # UPDATED QUERY: Use complaint_id directly
                cur.execute("""
                    SELECT co.description, co.status, e.status
                    FROM complaints co
                    JOIN customers c ON co.customer_id = c.customer_id
                    LEFT JOIN escalations e ON co.complaint_id = e.complaint_id
                    WHERE co.complaint_id = %s AND c.email = %s
                """, (complaint_id, email))
                
                if result := cur.fetchone():
                    description, comp_status, esc_status = result
                    message = (
                        f"📝 Complaint {complaint_id}\n"
                        f"Issue: {description}\n"
                        f"Status: {comp_status.upper()}\n"
                        f"Escalation: {esc_status or 'Not escalated'}"
                    )
                else:
                    message = f"ℹ️ No complaints found for reference {complaint_id}"
                    
                dispatcher.utter_message(message)
                
        except Exception as e:
            logger.error(f"Complaint check error: {str(e)}", exc_info=True)
            dispatcher.utter_message("⚠️ Couldn't retrieve complaint status. Please try again.")
        finally:
            # Only close if connection was established
            if conn:
                conn.close()
                
        return []

class ActionEscalateToAgent(Action):
    """Create escalation entry"""
    
    def name(self) -> Text:
        return "action_escalate_to_agent"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        email = tracker.get_slot("email")
        complaint_id = tracker.get_slot("complaint_id")
        
        if not (email and complaint_id):
            return []
        
        # Initialize connection to None
        conn = None
        try:
            conn = get_db_connection()
            if not conn:
                raise Exception("Database connection failed")
                
            with conn.cursor() as cur:
                # Create escalation directly using complaint_id
                cur.execute("""
                    INSERT INTO escalations (complaint_id, agent_id, notes, status)
                    VALUES (%s, gen_random_uuid(), 'Escalation via chatbot', 'pending')
                    RETURNING escalation_id
                """, (complaint_id,))
                
                if esc_row := cur.fetchone():
                    esc_id = esc_row[0]
                    conn.commit()
                    dispatcher.utter_message(
                        f"🚨 Escalation created! Reference: ESC-{esc_id}\n"
                        f"An agent will contact you at {email} within 24 hours."
                    )
                else:
                    dispatcher.utter_message("⚠️ Escalation could not be created. Please try again later.")
            
        except Exception as e:
            logger.error(f"Escalation error: {str(e)}", exc_info=True)
            dispatcher.utter_message("⚠️ Couldn't escalate your issue. Please try again later.")
        finally:
            # Only close if connection was established
            if conn:
                conn.close()
                
        return [SlotSet("complaint_id", None)]

class ActionRecommendProducts(Action):
    """Generate product recommendations"""
    
    def name(self) -> Text:
        return "action_recommend_products"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        email = tracker.get_slot("email")
        category = tracker.get_slot("category")
        
        if not email:
            return []
        
        # Initialize connection to None
        conn = None
        try:
            conn = get_db_connection()
            if not conn:
                raise Exception("Database connection failed")
                
            with conn.cursor() as cur:
                # Get customer preferences
                cur.execute("""
                    SELECT preferred_categories FROM preferences
                    WHERE customer_id = (SELECT customer_id FROM customers WHERE email = %s)
                    ORDER BY last_updated DESC LIMIT 1
                """, (email,))
                
                pref_result = cur.fetchone()
                # FIX: Directly use the list instead of parsing JSON
                pref_categories = pref_result[0] if pref_result else []
                
                # Determine categories - use slot category if provided
                if category:
                    categories = [category]
                elif pref_categories:
                    categories = pref_categories
                else:
                    categories = ['electronics', 'fitness']  # Default categories
                
                # Get recommendations
                cur.execute("""
                    SELECT name, price, description FROM products
                    WHERE category = ANY(%s) ORDER BY random() LIMIT 5
                """, (categories,))
                
                if products := cur.fetchall():
                    message = "🌟 Recommended Products:\n\n"
                    for idx, (name, price, desc) in enumerate(products, 1):
                        message += f"{idx}. {name} - ${price}\n   {desc[:60]}...\n\n"
                else:
                    message = "ℹ️ No recommendations found. Try another category?"
                    
                dispatcher.utter_message(message)
                
        except Exception as e:
            logger.error(f"Recommendation error: {str(e)}", exc_info=True)
            dispatcher.utter_message("⚠️ Couldn't generate recommendations. Please try again.")
        finally:
            # Only close if connection was established
            if conn:
                conn.close()
                
        return [SlotSet("category", None)]

class SubmitComplaintForm(Action):
    """Submit complaint form data"""
    
    def name(self) -> Text:
        return "action_submit_complaint_form"
    
    async def run(self, dispatcher: CollectingDispatcher,
                  tracker: Tracker,
                  domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        # Check if we're in the submission phase (all slots filled)
        if not tracker.get_slot("requested_slot"):
            tracking_number = tracker.get_slot("tracking_number")
            comp_type = tracker.get_slot("complaint_type")
            details = tracker.get_slot("complaint_details")
            email = tracker.get_slot("email")
            
            logger.info(f"Submitting complaint with: {email}, {tracking_number}, {comp_type}, {details}")
            
            if not all([tracking_number, comp_type, details, email]):
                dispatcher.utter_message("⚠️ Missing information. Please start over.")
                return [SlotSet(slot, None) for slot in [
                    "tracking_number", "complaint_type", "complaint_details"
                ]] + [ActiveLoop(None)]
            
            # Initialize connection to None
            conn = None
            try:
                conn = get_db_connection()
                if not conn:
                    raise Exception("Database connection failed")
                    
                with conn.cursor() as cur:
                    # Generate complaint UUID
                    complaint_id = str(uuid.uuid4())
                    comp_type_str = comp_type.upper() if comp_type else "GENERAL"
                    
                    cur.execute("""
                        INSERT INTO complaints (complaint_id, customer_id, order_id, description, status)
                        SELECT %s, c.customer_id, o.order_id, %s, 'open'
                        FROM customers c
                        JOIN orders o ON o.customer_id = c.customer_id
                        WHERE c.email = %s AND o.tracking_number = %s
                        RETURNING complaint_id
                    """, (complaint_id, f"{comp_type_str}: {details}", email, tracking_number))
                    
                    if comp_row := cur.fetchone():
                        complaint_id = comp_row[0]
                        conn.commit()
                        dispatcher.utter_message(
                            f"📝 Complaint registered!\n"
                            f"Reference: {complaint_id}\n"
                            f"We'll resolve this within 3 business days."
                        )
                        
                        return [
                            SlotSet("complaint_id", complaint_id),
                            SlotSet("tracking_number", None),
                            SlotSet("complaint_type", None),
                            SlotSet("complaint_details", None),
                            ActiveLoop(None)
                        ]
                    else:
                        logger.error("No complaint ID returned after insertion")
                        dispatcher.utter_message("⚠️ Failed to submit complaint. Please verify your order details.")
                        return [ActiveLoop(None)]
                    
            except Exception as e:
                logger.error(f"Complaint submission error: {str(e)}", exc_info=True)
                dispatcher.utter_message("⚠️ Failed to submit complaint. Please try again.")
                return [ActiveLoop(None)]
            finally:
                # Only close if connection was established
                if conn:
                    conn.close()
        
        # If we're still filling slots, return empty list
        return []

class ActionFallback(Action):
    """Handle out-of-scope questions"""
    
    def name(self) -> Text:
        return "action_default_fallback"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        dispatcher.utter_message(response="utter_out_of_scope")
        return []

class ActionResetSlots(Action):
    """Reset conversation slots"""
    
    def name(self) -> Text:
        return "action_reset_slots"
    
    def run(self, dispatcher: CollectingDispatcher,
            tracker: Tracker,
            domain: Dict[Text, Any]) -> List[Dict[Text, Any]]:
        
        reset_after_actions = [
            "utter_goodbye", 
            "action_default_fallback",
            "utter_out_of_scope"
        ]
        
        if tracker.latest_action_name in reset_after_actions:
            slots_to_reset = [
                "tracking_number", "complaint_type", "complaint_details",
                "category", "email", "complaint_id"
            ]
            return [SlotSet(slot, None) for slot in slots_to_reset]
        
        return []