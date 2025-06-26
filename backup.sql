--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: complaints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.complaints (
    complaint_id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid,
    order_id uuid,
    description text NOT NULL,
    status character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT complaints_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'in_progress'::character varying, 'resolved'::character varying, 'escalated'::character varying])::text[])))
);


ALTER TABLE public.complaints OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    customer_id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255) NOT NULL,
    name character varying(100) NOT NULL,
    phone character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: escalations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.escalations (
    escalation_id uuid DEFAULT gen_random_uuid() NOT NULL,
    complaint_id uuid,
    agent_id uuid,
    notes text,
    status character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT escalations_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'in_progress'::character varying, 'resolved'::character varying])::text[])))
);


ALTER TABLE public.escalations OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid,
    order_date date NOT NULL,
    status character varying(20),
    tracking_number character varying(50),
    estimated_delivery date,
    CONSTRAINT orders_status_check CHECK (((status)::text = ANY ((ARRAY['processing'::character varying, 'shipped'::character varying, 'delivered'::character varying, 'cancelled'::character varying])::text[])))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: preferences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.preferences (
    preference_id uuid DEFAULT gen_random_uuid() NOT NULL,
    customer_id uuid,
    viewed_products jsonb,
    purchased_items jsonb,
    preferred_categories jsonb,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.preferences OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    category character varying(50),
    tags jsonb
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Data for Name: complaints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.complaints (complaint_id, customer_id, order_id, description, status, created_at) FROM stdin;
f4276456-e6e3-4028-a9e7-8638b447cf4b	251eb966-d536-4b23-a889-569979bb4eb0	bf171241-6164-48b4-a677-192d2560e2d7	Delivery delayed beyond estimated date	in_progress	2025-06-21 21:32:47.886069
4f7717b3-84aa-460d-b9e5-fea3dc2afb80	8182ba62-b008-46c8-a2ef-c7d1b8109398	bd1b4271-f7c4-45f0-a1f3-dae8759f9966	Wrong item received	resolved	2025-06-21 21:32:47.886069
ff45ce99-ab68-46ea-be61-f27ba8d30b96	ebd21659-0ea4-4f97-a19f-debd1ded11ff	0d1c44e3-ec31-4f0c-b5a1-85c0bcc9ea88	Item arrived damaged	resolved	2025-06-21 21:32:47.886069
916bdb56-e3a8-4444-8fd8-81a905490b21	101ac4fe-1202-41c4-ade0-83487aeaba49	3371ca79-233c-488b-966f-0c74e5d696f8	Delivery delayed beyond estimated date	in_progress	2025-06-21 21:32:47.886069
2d9de327-eed3-48fe-ab80-614ae4f28eaa	16b904ca-5964-4a6d-b583-8e3a9b14ab66	e1293f12-afc8-4005-9d28-6a7611640269	Wrong item received	resolved	2025-06-21 21:32:47.886069
dd85a55c-16b2-4bf2-a282-0830e01158d3	0f8e3a2e-ec17-4c00-9b1b-cc3ee6836c69	09164844-c930-45b9-9031-c7245cf884f9	Delivery delayed beyond estimated date	open	2025-06-21 21:32:47.886069
a2b2414c-f3bd-4d8d-b3ab-ec6d87ba7713	a90db6f9-6abb-446c-b829-ffe4298dbabf	0d66efa6-005c-4e32-a3c4-1b523c040268	Item arrived damaged	in_progress	2025-06-21 21:32:47.886069
600b6ed8-b589-44f8-86c8-997b51b07608	101ac4fe-1202-41c4-ade0-83487aeaba49	b84b88e7-8b2b-4cc4-b2af-580342eea52d	Wrong item received	in_progress	2025-06-21 21:32:47.886069
291b7c17-be07-48b8-a0b8-72c4d49e7158	77c9a8d8-7c7f-4ee8-bc12-f752160f4621	e96bcef0-dc3f-4c51-90bb-b3b1c8b16325	Wrong item received	resolved	2025-06-21 21:32:47.886069
aeb70520-bc71-47fa-8b67-f24c23c0142d	251eb966-d536-4b23-a889-569979bb4eb0	5361ab80-4576-4e61-9616-820b91118d86	Wrong item received	resolved	2025-06-21 21:32:47.886069
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (customer_id, email, name, phone, created_at) FROM stdin;
a90db6f9-6abb-446c-b829-ffe4298dbabf	kane@gmail.com	Kane Jacobs	+1267895432	2025-06-21 19:49:29.343284
8182ba62-b008-46c8-a2ef-c7d1b8109398	randy@gmail.com	Randy Orton	+1832514628	2025-06-21 19:49:29.343284
ebd21659-0ea4-4f97-a19f-debd1ded11ff	lita@gmail.com	Lita Chefin	+1186492356	2025-06-21 19:49:29.343284
16b904ca-5964-4a6d-b583-8e3a9b14ab66	trish@gmail.com	Trish Strutus	+65429869012	2025-06-21 19:49:29.343284
77c9a8d8-7c7f-4ee8-bc12-f752160f4621	vince@gmail.com	Vince Macmohan	+9102764525	2025-06-21 19:49:29.343284
101ac4fe-1202-41c4-ade0-83487aeaba49	ddp@gmail.com	Diamond Dollas	+9784501234	2025-06-21 19:49:29.343284
07460a45-5339-4047-ad9a-17afedf2d556	austin@gmail.com	Steve Austin	+8364126496	2025-06-21 19:49:29.343284
251eb966-d536-4b23-a889-569979bb4eb0	walter@gmail.com	Walter White	+49527354672	2025-06-21 19:49:29.343284
586dd311-7ab8-4472-b8bf-93da920fd8ca	guilio@gmail.com	Guilio Martham	+5623568752	2025-06-21 19:49:29.343284
0f8e3a2e-ec17-4c00-9b1b-cc3ee6836c69	andre@gmail.com	Andre Nel	+2341567834	2025-06-21 19:49:29.343284
\.


--
-- Data for Name: escalations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.escalations (escalation_id, complaint_id, agent_id, notes, status, created_at) FROM stdin;
047df0c4-0452-44de-badf-54e53a8e612d	f4276456-e6e3-4028-a9e7-8638b447cf4b	34efb01b-f408-495c-b674-9286ff6d30d7	Customer requested manager callback	resolved	2025-06-21 22:11:44.148714
2ddb9d91-6332-4c38-89dc-31b815aac822	600b6ed8-b589-44f8-86c8-997b51b07608	d9c32266-dd06-4432-9c98-6d0a81c6ac14	High-value customer - prioritize resolution	resolved	2025-06-21 22:11:44.148714
db94965f-3c36-498a-bde7-2e5e7a1a8729	916bdb56-e3a8-4444-8fd8-81a905490b21	3b487b08-27fd-4e7e-b7c8-be12ac9d3764	Urgent resolution required	in_progress	2025-06-21 22:11:44.148714
0cac4643-4096-40d5-b65d-7a286dfa9284	2d9de327-eed3-48fe-ab80-614ae4f28eaa	37e8b488-637b-4e49-aa48-a407fddfcc9a	High-value customer - prioritize resolution	resolved	2025-06-21 22:11:44.148714
daf2757b-8da9-4d67-8053-0ea0d2d58322	aeb70520-bc71-47fa-8b67-f24c23c0142d	6d7c075a-401e-42dc-be91-758a77bdeffa	Customer requested manager callback	pending	2025-06-21 22:11:44.148714
fb812e05-a064-45df-a368-64bcb14896e1	a2b2414c-f3bd-4d8d-b3ab-ec6d87ba7713	81e51517-ea64-429a-b410-4c76387fbe87	Customer requested manager callback	resolved	2025-06-21 22:11:44.148714
d7ec81a4-fe64-4c61-93a5-c47ffbd45712	4f7717b3-84aa-460d-b9e5-fea3dc2afb80	a701d870-c446-42ad-a9fe-c711a18fdd21	Customer requested manager callback	pending	2025-06-21 22:11:44.148714
71966628-a987-4ef1-9734-b90414424f37	ff45ce99-ab68-46ea-be61-f27ba8d30b96	04ef8765-7986-47a7-b1a9-81dcaa04dfe8	Urgent resolution required	resolved	2025-06-21 22:11:44.148714
47c48329-9c3d-4d5b-943d-86aeb6390814	291b7c17-be07-48b8-a0b8-72c4d49e7158	ecb693e2-261b-4583-8ff8-79a0a849ef40	Urgent resolution required	in_progress	2025-06-21 22:11:44.148714
1de4026a-81d6-4f15-af8f-8c17e367b29f	dd85a55c-16b2-4bf2-a282-0830e01158d3	f346988c-41b4-4ee0-9553-5fd10eaee4cb	Customer requested manager callback	in_progress	2025-06-21 22:11:44.148714
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, customer_id, order_date, status, tracking_number, estimated_delivery) FROM stdin;
0d66efa6-005c-4e32-a3c4-1b523c040268	a90db6f9-6abb-446c-b829-ffe4298dbabf	2024-05-04	delivered	TRACK-092c6f9c	2024-05-16
03d1a785-c80f-4251-b006-c3060bef7f5c	8182ba62-b008-46c8-a2ef-c7d1b8109398	2024-05-06	processing	TRACK-ea86e2d8	2024-05-15
c58f0b15-1a47-4071-ac6d-7712bf62f7af	ebd21659-0ea4-4f97-a19f-debd1ded11ff	2024-05-19	delivered	TRACK-3ac6ac10	2024-05-18
e1293f12-afc8-4005-9d28-6a7611640269	16b904ca-5964-4a6d-b583-8e3a9b14ab66	2024-05-23	processing	TRACK-1ebe24d9	2024-05-21
e96bcef0-dc3f-4c51-90bb-b3b1c8b16325	77c9a8d8-7c7f-4ee8-bc12-f752160f4621	2024-05-22	processing	TRACK-86f27f00	2024-05-10
b84b88e7-8b2b-4cc4-b2af-580342eea52d	101ac4fe-1202-41c4-ade0-83487aeaba49	2024-05-13	delivered	TRACK-4d07dda3	2024-05-21
d475bb0b-2353-40b8-99c8-81194286e7b5	07460a45-5339-4047-ad9a-17afedf2d556	2024-05-14	processing	TRACK-79835885	2024-05-16
5361ab80-4576-4e61-9616-820b91118d86	251eb966-d536-4b23-a889-569979bb4eb0	2024-05-22	cancelled	TRACK-6ec5f5ce	2024-05-21
79e5959d-1752-4d1c-9e93-ba685d8e7143	586dd311-7ab8-4472-b8bf-93da920fd8ca	2024-05-29	cancelled	TRACK-8fa622a1	2024-05-25
09164844-c930-45b9-9031-c7245cf884f9	0f8e3a2e-ec17-4c00-9b1b-cc3ee6836c69	2024-05-21	cancelled	TRACK-7e78e821	2024-05-14
c4a786cd-772c-4064-a17c-5b468dd71e1d	a90db6f9-6abb-446c-b829-ffe4298dbabf	2024-05-10	cancelled	TRACK-da89b04c	2024-05-22
bd1b4271-f7c4-45f0-a1f3-dae8759f9966	8182ba62-b008-46c8-a2ef-c7d1b8109398	2024-05-30	shipped	TRACK-e04916f0	2024-05-22
0d1c44e3-ec31-4f0c-b5a1-85c0bcc9ea88	ebd21659-0ea4-4f97-a19f-debd1ded11ff	2024-05-02	delivered	TRACK-0645280f	2024-05-19
810ba47b-97cd-44af-8c16-ca2a940308f0	16b904ca-5964-4a6d-b583-8e3a9b14ab66	2024-05-30	delivered	TRACK-df3294c7	2024-05-20
80347bf8-13dd-4fab-9f18-8cf4a75601a5	77c9a8d8-7c7f-4ee8-bc12-f752160f4621	2024-05-27	shipped	TRACK-26c871d9	2024-05-24
3371ca79-233c-488b-966f-0c74e5d696f8	101ac4fe-1202-41c4-ade0-83487aeaba49	2024-05-10	cancelled	TRACK-164ec1c4	2024-05-11
534a8019-56a0-4091-8e59-2a93319b7089	07460a45-5339-4047-ad9a-17afedf2d556	2024-05-04	shipped	TRACK-6753db9f	2024-05-19
bf171241-6164-48b4-a677-192d2560e2d7	251eb966-d536-4b23-a889-569979bb4eb0	2024-05-16	cancelled	TRACK-4d063088	2024-05-19
49f0cd49-4ee1-4b18-9e2b-13ee1250ee92	586dd311-7ab8-4472-b8bf-93da920fd8ca	2024-05-09	cancelled	TRACK-51d17c7a	2024-05-23
0e526fc8-eb35-409b-b94e-2e4dba54686f	0f8e3a2e-ec17-4c00-9b1b-cc3ee6836c69	2024-05-06	delivered	TRACK-3b59f54a	2024-05-20
\.


--
-- Data for Name: preferences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.preferences (preference_id, customer_id, viewed_products, purchased_items, preferred_categories, last_updated) FROM stdin;
3a1a7170-9980-49af-9fd6-678dd79833e7	a90db6f9-6abb-446c-b829-ffe4298dbabf	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "97c93485-3d01-432f-98f0-dd18c55c927f", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics"]	2025-06-21 22:10:40.921249
12389c2c-7f8f-4fa7-8010-cb8f9b0a8232	8182ba62-b008-46c8-a2ef-c7d1b8109398	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness", "footwear"]	2025-06-21 22:10:40.921249
3d681bc7-8c0a-4c8e-8299-59f82fedaa4e	ebd21659-0ea4-4f97-a19f-debd1ded11ff	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["home", "kitchen"]	2025-06-21 22:10:40.921249
5b654419-75cd-4a2f-99a0-7790c9e5f91b	16b904ca-5964-4a6d-b583-8e3a9b14ab66	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness", "travel"]	2025-06-21 22:10:40.921249
91ffd474-5dd2-43d1-821b-5a546d5428bd	77c9a8d8-7c7f-4ee8-bc12-f752160f4621	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics", "home"]	2025-06-21 22:10:40.921249
1024a70b-8dc1-4553-bc33-a6e3f06cfcb1	101ac4fe-1202-41c4-ade0-83487aeaba49	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["home", "kitchen"]	2025-06-21 22:10:40.921249
8b7a636e-488a-4e45-bcf9-eec970f67a7a	07460a45-5339-4047-ad9a-17afedf2d556	["b1bedeb5-9cd4-4795-948b-9f21895512e8"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["footwear"]	2025-06-21 22:10:40.921249
4d153370-798c-4e12-9a79-7aec7b74daf8	251eb966-d536-4b23-a889-569979bb4eb0	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "89433f43-0528-4fea-9928-437d058eb28d", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["kitchen"]	2025-06-21 22:10:40.921249
96823c41-7fcd-437a-b845-ba201ca7eafb	586dd311-7ab8-4472-b8bf-93da920fd8ca	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness"]	2025-06-21 22:10:40.921249
f6d33508-7a4c-4f67-8f44-6adb38627230	0f8e3a2e-ec17-4c00-9b1b-cc3ee6836c69	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "97c93485-3d01-432f-98f0-dd18c55c927f", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics"]	2025-06-21 22:10:40.921249
713bae8d-6142-425a-9600-a7e77b86ec3f	a90db6f9-6abb-446c-b829-ffe4298dbabf	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "97c93485-3d01-432f-98f0-dd18c55c927f", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics"]	2025-06-21 22:10:40.921249
0310f8c4-a9b7-437c-9b2a-12d3129c2f26	8182ba62-b008-46c8-a2ef-c7d1b8109398	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness", "footwear"]	2025-06-21 22:10:40.921249
d1e0c2ce-fca9-44a3-8711-d04abff28ed1	ebd21659-0ea4-4f97-a19f-debd1ded11ff	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["home", "kitchen"]	2025-06-21 22:10:40.921249
102757ca-ad13-4043-b951-e49b20945945	16b904ca-5964-4a6d-b583-8e3a9b14ab66	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness", "travel"]	2025-06-21 22:10:40.921249
4d234861-a252-4f19-aa72-ffadc98d9295	77c9a8d8-7c7f-4ee8-bc12-f752160f4621	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics", "home"]	2025-06-21 22:10:40.921249
d4394491-0ce8-4764-af36-4951b1e38f7e	101ac4fe-1202-41c4-ade0-83487aeaba49	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["home", "kitchen"]	2025-06-21 22:10:40.921249
025628f0-62f3-45ce-a1b8-151c4ca210ed	07460a45-5339-4047-ad9a-17afedf2d556	["b1bedeb5-9cd4-4795-948b-9f21895512e8"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["footwear"]	2025-06-21 22:10:40.921249
70867f46-733f-420b-9610-f44af8e97d83	251eb966-d536-4b23-a889-569979bb4eb0	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "89433f43-0528-4fea-9928-437d058eb28d", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["kitchen"]	2025-06-21 22:10:40.921249
81a7b8f1-8917-4d89-95a0-acace96345b3	586dd311-7ab8-4472-b8bf-93da920fd8ca	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness"]	2025-06-21 22:10:40.921249
7d466ac7-4730-4858-b28e-132981279386	0f8e3a2e-ec17-4c00-9b1b-cc3ee6836c69	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "97c93485-3d01-432f-98f0-dd18c55c927f", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics"]	2025-06-21 22:10:40.921249
e9f7c1f3-ccff-4ef2-ace3-867f351a9302	a90db6f9-6abb-446c-b829-ffe4298dbabf	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "97c93485-3d01-432f-98f0-dd18c55c927f", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics"]	2025-06-21 22:10:40.921249
69924554-f9e2-41d8-9556-1a451621407d	8182ba62-b008-46c8-a2ef-c7d1b8109398	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness", "footwear"]	2025-06-21 22:10:40.921249
28027aa3-31fb-4eed-bee8-5a4ea8e852b3	ebd21659-0ea4-4f97-a19f-debd1ded11ff	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["home", "kitchen"]	2025-06-21 22:10:40.921249
c687c7ef-c1c5-4561-bfcb-65f099e3c284	16b904ca-5964-4a6d-b583-8e3a9b14ab66	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness", "travel"]	2025-06-21 22:10:40.921249
fee42897-7cbb-41b5-955b-400f8ab20322	77c9a8d8-7c7f-4ee8-bc12-f752160f4621	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics", "home"]	2025-06-21 22:10:40.921249
bdef4619-b08f-429f-bcf2-ad9c57baba4e	101ac4fe-1202-41c4-ade0-83487aeaba49	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["home", "kitchen"]	2025-06-21 22:10:40.921249
7b5cd1fc-017e-451b-973f-dbe95b8397a8	07460a45-5339-4047-ad9a-17afedf2d556	["b1bedeb5-9cd4-4795-948b-9f21895512e8"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["footwear"]	2025-06-21 22:10:40.921249
3e123934-7761-4dc5-8152-9de4c5d7b904	251eb966-d536-4b23-a889-569979bb4eb0	["e8deafed-890a-45af-9d57-2b8b3739c64b", "c00293e1-90ff-4204-a926-efd53006ae16", "89433f43-0528-4fea-9928-437d058eb28d", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["kitchen"]	2025-06-21 22:10:40.921249
71f9503a-5075-48fc-aa84-f96d50944678	586dd311-7ab8-4472-b8bf-93da920fd8ca	["8ecca9f8-d316-4ab3-b41e-34fa8e360734", "ab622baf-837d-4ca3-9d51-36349f2a6972", "85a55068-c8ae-4d5e-9aeb-53918249d043", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["fitness"]	2025-06-21 22:10:40.921249
5ce941b2-dc62-49cb-8eaa-6704e02c6409	0f8e3a2e-ec17-4c00-9b1b-cc3ee6836c69	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "97c93485-3d01-432f-98f0-dd18c55c927f", "29d4b0a7-c101-47be-9496-510c21356d09", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "3f596f51-5f7e-4ff4-90cc-05743ceac60c"]	["55e621d5-ee28-4694-8a4b-5eecafb941ed", "8ecca9f8-d316-4ab3-b41e-34fa8e360734", "e8deafed-890a-45af-9d57-2b8b3739c64b", "ab622baf-837d-4ca3-9d51-36349f2a6972", "01fe1091-1a4e-4bab-bf63-0c6d2cfff104", "c00293e1-90ff-4204-a926-efd53006ae16", "b1bedeb5-9cd4-4795-948b-9f21895512e8", "81f19ef5-e57d-4d02-bee0-b0afb4305443", "cdd56c7a-9c4d-43be-8a65-bebaccdc3dab", "89433f43-0528-4fea-9928-437d058eb28d", "85a55068-c8ae-4d5e-9aeb-53918249d043", "97c93485-3d01-432f-98f0-dd18c55c927f", "aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010", "9390889b-fc7e-4f4c-8d90-aeb75a254441", "29d4b0a7-c101-47be-9496-510c21356d09", "f4bcc771-a107-4e34-a076-b2bb1ca08ea2", "9c40bc93-c2e9-4285-ac91-4a9ec562ee44", "49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c", "3f596f51-5f7e-4ff4-90cc-05743ceac60c", "853ffd5d-2b37-456f-afe0-89e3f9966e25"]	["electronics"]	2025-06-21 22:10:40.921249
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (product_id, name, description, price, category, tags) FROM stdin;
55e621d5-ee28-4694-8a4b-5eecafb941ed	Wireless Earbuds	True wireless earbuds with 24hr battery	129.99	electronics	["audio", "wireless"]
8ecca9f8-d316-4ab3-b41e-34fa8e360734	Fitness Tracker	Heart rate monitor + sleep tracking	89.99	fitness	["wearable", "health"]
e8deafed-890a-45af-9d57-2b8b3739c64b	Electric Kettle	1.7L quick-boil stainless steel kettle	49.99	kitchen	["appliance", "beverage"]
ab622baf-837d-4ca3-9d51-36349f2a6972	Yoga Block Set	2 eco-friendly cork yoga blocks	24.99	fitness	["yoga", "accessories"]
01fe1091-1a4e-4bab-bf63-0c6d2cfff104	Bluetooth Speaker	Waterproof portable speaker	79.99	electronics	["audio", "outdoor"]
c00293e1-90ff-4204-a926-efd53006ae16	Coffee Grinder	Adjustable burr grinder	64.99	kitchen	["coffee", "appliance"]
b1bedeb5-9cd4-4795-948b-9f21895512e8	Running Shoes	Lightweight trail running shoes	119.99	footwear	["running", "outdoor"]
81f19ef5-e57d-4d02-bee0-b0afb4305443	Backpack	30L waterproof hiking backpack	89.99	travel	["outdoor", "hiking"]
cdd56c7a-9c4d-43be-8a65-bebaccdc3dab	Smart Thermostat	WiFi-enabled home thermostat	129.99	home	["smart home", "energy"]
89433f43-0528-4fea-9928-437d058eb28d	Air Fryer	5.8L digital air fryer	109.99	kitchen	["appliance", "healthy"]
85a55068-c8ae-4d5e-9aeb-53918249d043	Resistance Bands	Set of 5 latex-free bands	34.99	fitness	["gym", "home workout"]
97c93485-3d01-432f-98f0-dd18c55c927f	E-Reader	6" HD display with backlight	139.99	electronics	["reading", "books"]
aa7a1d79-5a8d-4f8a-b192-8ed9f8ebb010	Desk Lamp	Adjustable LED desk lamp	45.99	home	["office", "lighting"]
9390889b-fc7e-4f4c-8d90-aeb75a254441	Dumbbell Set	2x20kg adjustable dumbbells	149.99	fitness	["weights", "gym"]
29d4b0a7-c101-47be-9496-510c21356d09	Noise Cancelling Headphones	Over-ear Bluetooth headphones	199.99	electronics	["audio", "travel"]
f4bcc771-a107-4e34-a076-b2bb1ca08ea2	Juicer	Cold press slow juicer	179.99	kitchen	["health", "appliance"]
9c40bc93-c2e9-4285-ac91-4a9ec562ee44	Smart Watch	Fitness tracking + notifications	249.99	electronics	["wearable", "smart"]
49dd95a5-b6e0-4e5e-a13c-fd6f9913e35c	Cookware Set	10-piece non-stick set	189.99	kitchen	["cooking", "utensils"]
3f596f51-5f7e-4ff4-90cc-05743ceac60c	Gaming Mouse	RGB programmable mouse	59.99	electronics	["gaming", "computer"]
853ffd5d-2b37-456f-afe0-89e3f9966e25	Water Bottle	1L insulated stainless steel	29.99	fitness	["hydration", "outdoor"]
\.


--
-- Name: complaints complaints_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_pkey PRIMARY KEY (complaint_id);


--
-- Name: customers customers_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_email_key UNIQUE (email);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (customer_id);


--
-- Name: escalations escalations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.escalations
    ADD CONSTRAINT escalations_pkey PRIMARY KEY (escalation_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: preferences preferences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_pkey PRIMARY KEY (preference_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: idx_complaints_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_complaints_order ON public.complaints USING btree (order_id);


--
-- Name: idx_orders_customer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_customer ON public.orders USING btree (customer_id);


--
-- Name: complaints complaints_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: complaints complaints_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.complaints
    ADD CONSTRAINT complaints_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id);


--
-- Name: escalations escalations_complaint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.escalations
    ADD CONSTRAINT escalations_complaint_id_fkey FOREIGN KEY (complaint_id) REFERENCES public.complaints(complaint_id);


--
-- Name: orders orders_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- Name: preferences preferences_customer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.preferences
    ADD CONSTRAINT preferences_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);


--
-- PostgreSQL database dump complete
--

