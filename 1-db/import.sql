--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: booking; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE booking (
    id bigint NOT NULL,
    cancellationcode character varying(255) NOT NULL,
    contactemail character varying(255) NOT NULL,
    createdon timestamp without time zone NOT NULL,
    performance_id bigint
);


ALTER TABLE public.booking OWNER TO admin;

--
-- Name: booking_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE booking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.booking_id_seq OWNER TO admin;

--
-- Name: booking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE booking_id_seq OWNED BY booking.id;


--
-- Name: event; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE event (
    id bigint NOT NULL,
    description character varying(1000) NOT NULL,
    name character varying(50) NOT NULL,
    category_id bigint NOT NULL,
    mediaitem_id bigint
);


ALTER TABLE public.event OWNER TO admin;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_id_seq OWNER TO admin;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE event_id_seq OWNED BY event.id;


--
-- Name: eventcategory; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE eventcategory (
    id bigint NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.eventcategory OWNER TO admin;

--
-- Name: eventcategory_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE eventcategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.eventcategory_id_seq OWNER TO admin;

--
-- Name: eventcategory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE eventcategory_id_seq OWNED BY eventcategory.id;


--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hibernate_sequence OWNER TO admin;

--
-- Name: mediaitem; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE mediaitem (
    id bigint NOT NULL,
    mediatype character varying(255),
    url character varying(255)
);


ALTER TABLE public.mediaitem OWNER TO admin;

--
-- Name: mediaitem_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE mediaitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mediaitem_id_seq OWNER TO admin;

--
-- Name: mediaitem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE mediaitem_id_seq OWNED BY mediaitem.id;


--
-- Name: performance; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE performance (
    id bigint NOT NULL,
    date timestamp without time zone NOT NULL,
    show_id bigint NOT NULL
);


ALTER TABLE public.performance OWNER TO admin;

--
-- Name: performance_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE performance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.performance_id_seq OWNER TO admin;

--
-- Name: performance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE performance_id_seq OWNED BY performance.id;


--
-- Name: section; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE section (
    id bigint NOT NULL,
    description character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    numberofrows integer NOT NULL,
    rowcapacity integer NOT NULL,
    venue_id bigint NOT NULL
);


ALTER TABLE public.section OWNER TO admin;

--
-- Name: section_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.section_id_seq OWNER TO admin;

--
-- Name: section_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE section_id_seq OWNED BY section.id;


--
-- Name: sectionallocation; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE sectionallocation (
    id bigint NOT NULL,
    allocated bytea,
    occupiedcount integer NOT NULL,
    version bigint NOT NULL,
    performance_id bigint NOT NULL,
    section_id bigint NOT NULL
);


ALTER TABLE public.sectionallocation OWNER TO admin;

--
-- Name: sectionallocation_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE sectionallocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sectionallocation_id_seq OWNER TO admin;

--
-- Name: sectionallocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE sectionallocation_id_seq OWNED BY sectionallocation.id;


--
-- Name: show; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE show (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    venue_id bigint NOT NULL
);


ALTER TABLE public.show OWNER TO admin;

--
-- Name: show_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE show_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.show_id_seq OWNER TO admin;

--
-- Name: show_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE show_id_seq OWNED BY show.id;


--
-- Name: ticket; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE ticket (
    id bigint NOT NULL,
    price real NOT NULL,
    number integer NOT NULL,
    rownumber integer NOT NULL,
    section_id bigint,
    ticketcategory_id bigint NOT NULL,
    tickets_id bigint
);


ALTER TABLE public.ticket OWNER TO admin;

--
-- Name: ticket_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ticket_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticket_id_seq OWNER TO admin;

--
-- Name: ticket_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ticket_id_seq OWNED BY ticket.id;


--
-- Name: ticketcategory; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE ticketcategory (
    id bigint NOT NULL,
    description character varying(255) NOT NULL
);


ALTER TABLE public.ticketcategory OWNER TO admin;

--
-- Name: ticketcategory_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ticketcategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticketcategory_id_seq OWNER TO admin;

--
-- Name: ticketcategory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ticketcategory_id_seq OWNED BY ticketcategory.id;


--
-- Name: ticketprice; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE ticketprice (
    id bigint NOT NULL,
    price real NOT NULL,
    section_id bigint NOT NULL,
    show_id bigint NOT NULL,
    ticketcategory_id bigint NOT NULL
);


ALTER TABLE public.ticketprice OWNER TO admin;

--
-- Name: ticketprice_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE ticketprice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticketprice_id_seq OWNER TO admin;

--
-- Name: ticketprice_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE ticketprice_id_seq OWNED BY ticketprice.id;


--
-- Name: userentity; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE userentity (
    id bigint NOT NULL,
    name character varying(255),
    version bigint
);


ALTER TABLE public.userentity OWNER TO admin;

--
-- Name: venue; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE venue (
    id bigint NOT NULL,
    city character varying(255),
    country character varying(255),
    street character varying(255),
    capacity integer NOT NULL,
    description character varying(255),
    name character varying(255) NOT NULL,
    mediaitem_id bigint
);


ALTER TABLE public.venue OWNER TO admin;

--
-- Name: venue_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE venue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.venue_id_seq OWNER TO admin;

--
-- Name: venue_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE venue_id_seq OWNED BY venue.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY booking ALTER COLUMN id SET DEFAULT nextval('booking_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY event ALTER COLUMN id SET DEFAULT nextval('event_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY eventcategory ALTER COLUMN id SET DEFAULT nextval('eventcategory_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY mediaitem ALTER COLUMN id SET DEFAULT nextval('mediaitem_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY performance ALTER COLUMN id SET DEFAULT nextval('performance_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY section ALTER COLUMN id SET DEFAULT nextval('section_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY sectionallocation ALTER COLUMN id SET DEFAULT nextval('sectionallocation_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY show ALTER COLUMN id SET DEFAULT nextval('show_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticket ALTER COLUMN id SET DEFAULT nextval('ticket_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticketcategory ALTER COLUMN id SET DEFAULT nextval('ticketcategory_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticketprice ALTER COLUMN id SET DEFAULT nextval('ticketprice_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY venue ALTER COLUMN id SET DEFAULT nextval('venue_id_seq'::regclass);


--
-- Data for Name: booking; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY booking (id, cancellationcode, contactemail, createdon, performance_id) FROM stdin;
\.


--
-- Name: booking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('booking_id_seq', 1, false);


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY event (id, description, name, category_id, mediaitem_id) FROM stdin;
1	Get ready to rock your night away with this megaconcert extravaganza from 10 of the biggest rock stars of the 80's	Rock concert of the decade	1	1
2	This critically acclaimed masterpiece will take you on an emotional rollercoaster the likes of which you've never experienced.	Shane's Sock Puppets	2	2
3	A friendly replay of the famous World Cup final.	Brazil vs. Italy	4	6
4	Show your colors in Friday Night Lights! Come see the Red Hot Scorpions put the sting on the winners of Sunday's Coastal Quarterfinals for all state bragging rights. Fans entering the stadium in team color face paint will receive a $5 voucher redeemable with any on-site vendor. Body paint in lieu of clothing will not be permitted for this family friendly event.	All State Football Championship	4	7
5	Every tennis enthusiast will want to see Wimbledon legend Chris Lewis as he meets archrival Deuce Wild in the quarterfinals of one of the top U.S. tournaments. Finals are already sold out, so do not miss your chance to see the real action in play on the eve of the big day!	Chris Lewis Quarterfinals	4	11
6	Join your fellow crew junkies and snarky, self-important collegiate know-it-alls from the nations snobbiest schools to see which team is in fact the fastest show on oars. (Or, if you like, just purchase a ticket and sport a t-shirt from your local community college just to tick them off -- this event promises to be SO much fun!)	Crew You	4	12
7	What else is there to say? There's snow and sun and the bravest (or craziest) guys ever to strap two feet to a board and fly off a four-story ramp of ice and snow. Who would not want to see how aerial acrobatics are being redefined by the world's top adrenaline junkies?	Extreme Snowboarding Finals	4	13
8	Hear the sounds that have the critics abuzz. Be one of the first American audiences to experience Portuguese phenomenon Arrhythmia play all the tracks from their recently-released 'Graffiti' -- the show includes a cameo with world-famous activist and graffiti artist Bansky.	Arrhythmia: Graffiti	1	8
9	That's right -- they've blown into town! Join the annual tri-state Battle of the Brass Bands and watch them 'gild' the winning band's Most Valuable Blower (MVB) -- don't worry (and don't inhale!); it's only spray paint!  Vote for your best band and revel in a day of high-energy rhythms!	Battle of the Brass Bands	1	9
10	Sit center stage as Harlequin Ayes gives another groundbreaking theater performance in the critically acclaimed Carnival Comes to Town, a monologue re-enactment of one-woman's despair at not being chosen to join the carnival she's spent her entire life preparing for.	Carnival Comes to Town	2	10
11	Get in touch with the stunning staccato and your inner Andalusian -- and put on your dancing shoes even if you're just in the audience! It's down to this one night of competition for the eight mesmerizing couples from around the globe that made it this far. Purchase VIP tickets to experience the competition and revel in the after-hours cabaret party with the world's most alluring dancers!	Flamenco Finale	2	14
12	It's one night only for this once-in-a-lifetime concert-in-the-round with Grammy winning folk and blues legend Jesse Lewis. Entirely stripped of elaborate recording production, Lewis' music stands entirely on its own and has audiences raving it's his best work ever. With limited seating this final concert, don't dare to miss this classic you can tell your grandkids about when they develop some real taste in music.	Jesse Lewis Unplugged	1	15
13	Make way for Puccini's opera in three acts and wear waterproof mascara for the dramatic tearjerker of the season. Let the voice of renowned soprano Rosino Storchio and tenor Giovanni Zenatello envelop you under the stars while you sob quietly into your handkerchief! Wine and hard liquor will be available during intermission and after the show for those seeking to drown their sorrows.	Madame Butterfly	2	16
14	Join in the region's largest and most revered demonstration of one of the most mocked arts forms of all time. Stand in stunned silence while the masters of Mime Mania thrill with dramatic gestures that far surpass the now passé "Woman in a Glass Box." See the famous, "I have 10 fingers, don't make me give you one!" and other favorites and be sure to enjoy the post-show silent auction.	Mime Mania!	2	17
15	This show is for all those who traded in Hemingway for the poetry of the Doors, but really can't remember why.  Come see a dead ringer for Jim Morrison and let the despair envelop your soul as he quotes from his tragic mentor, "I believe in a prolonged derangement of the senses in order to obtain the unknown." But be advised: Leave your ganja at home, or leave with the Po-Po	Almost (Mostly) Morrison	1	18
16	Join your fellow ballet enthusiasts for the National Ballet Company's presentation of Tutu Tchai, a tribute to Pyotr Tchaikovsky's and the expressive intensity revealed in his three most famous ballets: The Nutcracker, Swan Lake, and The Sleeping Beauty.	Tutu Tchai	2	19
17	They're out to prove it's not all about the fights! Join your favorite members of the Canadian Women's Hockey League as they compete for the title "Queen of the Slap Shot." Commonly believed to be hockey's toughest shot to execute, the speed and accuracy of slap shots will be measured on the ice. Fan participation and response will determine any ties. Proceeds will benefit local area domestic violence shelters.	Slap Shot	4	20
18	Your votes are in and the teams are assembled and coming to a stadium near you! Join Brendan 'Biceps' Owen and the rest of the NBA's leading players for this blockbuster East versus West all-star game. Who will join the rarefied air with past MVP greats like Shaquille O'Neal, LeBron James, and Kobe Bryant? Don't wait to see the highlights when you can experience it live!	Giants of the Game	4	21
19	You may not be at a British seaside but you heard right! Bring your family to witness a new twist on this traditional classic dating back to the 1600s ... only this time, Mr. Punch (and his stick) have met "The 1%." Cheer (or jeer) from the crowd when you think Punch should use his stick on Mr. 1%. Fans agree, "It's the best way to release your outrage at the wealthiest 1% without  being arrested!".	Punch and Judy (with a Twist)	2	22
\.


--
-- Name: event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('event_id_seq', 19, true);


--
-- Data for Name: eventcategory; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY eventcategory (id, description) FROM stdin;
1	Concert
2	Theatre
3	Musical
4	Sporting
5	Comedy
\.


--
-- Name: eventcategory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('eventcategory_id_seq', 5, true);


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('hibernate_sequence', 1, false);


--
-- Data for Name: mediaitem; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY mediaitem (id, mediatype, url) FROM stdin;
1	IMAGE	https://dl.dropbox.com/u/65660684/640px-Weir%2C_Bob_(2007)_2.jpg
2	IMAGE	https://dl.dropbox.com/u/65660684/640px-Carnival_Puppets.jpg
3	IMAGE	https://dl.dropbox.com/u/65660684/640px-Opera_House_with_Sydney.jpg
4	IMAGE	https://dl.dropbox.com/u/65660684/640px-Roy_Thomson_Hall_Toronto.jpg
5	IMAGE	https://dl.dropbox.com/u/65660684/640px-West-stand-bmo-field.jpg
6	IMAGE	https://dl.dropbox.com/u/65660684/640px-Brazil_national_football_team_training_at_Dobsonville_Stadium_2010-06-03_13.jpg
7	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/AllStateFootballChampionship.png
8	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/ARhythmia.png
9	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/BattleoftheBrassBands.png
10	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/CarnivalComestoTown.png
11	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/ChrisLewisQuarterfinals.png
12	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/CrewYou.png
13	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/ExtremeSnowboardingFinals.png
14	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/FlamencoFinale.png
15	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/JesseLewisUnplugged.png
16	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/MadameButterfly.png
17	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/MimeMania.png
18	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/MorrisonCover.png
19	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/TutuTchai.png
20	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/SlapShot.png
21	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/Giantsofthegame.png
22	IMAGE	https://dl.dropbox.com/u/8625587/ticketmonster/Punch%26Judy.png
23	IMAGE	http://upload.wikimedia.org/wikipedia/commons/thumb/d/dc/Paris_Opera_full_frontal_architecture%2C_May_2009.jpg/800px-Paris_Opera_full_frontal_architecture%2C_May_2009.jpg
24	IMAGE	http://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Boston_Symphony_Hall_from_the_south.jpg/800px-Boston_Symphony_Hall_from_the_south.jpg
\.


--
-- Name: mediaitem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('mediaitem_id_seq', 24, true);


--
-- Data for Name: performance; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY performance (id, date, show_id) FROM stdin;
1	2014-05-29 19:00:00	1
2	2014-05-30 19:00:00	1
3	2014-05-31 19:30:00	2
4	2014-06-01 19:30:00	2
5	2014-06-02 17:00:00	3
6	2014-06-02 19:30:00	3
7	2014-06-04 17:00:00	4
8	2014-06-04 19:30:00	4
9	2014-07-09 21:00:00	5
10	2014-05-29 19:00:00	6
11	2014-05-30 19:00:00	6
\.


--
-- Name: performance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('performance_id_seq', 11, true);


--
-- Data for Name: section; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY section (id, description, name, numberofrows, rowcapacity, venue_id) FROM stdin;
1	Premier platinum reserve	A	20	100	1
2	Premier gold reserve	B	20	100	1
3	Premier silver reserve	C	30	100	1
4	General	D	40	100	1
5	Front left	S1	50	50	2
6	Front centre	S2	50	50	2
7	Front right	S3	50	50	2
8	Rear left	S4	50	50	2
9	Rear centre	S5	50	50	2
10	Rear right	S6	50	50	2
11	Balcony	S7	1	30	2
12	Premier platinum reserve	A	40	100	3
13	Premier gold reserve	B	40	100	3
14	Premier silver reserve	C	30	200	3
15	General	D	80	200	3
16	Center	A	10	60	4
17	Left	B	10	41	4
18	Right	C	10	41	4
19	Balcony	D	6	92	4
20	Center	A	10	60	5
21	Left	B	10	41	5
22	Right	C	10	41	5
23	Balcony	D	6	92	5
\.


--
-- Name: section_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('section_id_seq', 23, true);


--
-- Data for Name: sectionallocation; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY sectionallocation (id, allocated, occupiedcount, version, performance_id, section_id) FROM stdin;
1	\N	0	1	1	1
2	\N	0	1	1	2
3	\N	0	1	1	3
4	\N	0	1	1	4
5	\N	0	1	2	1
6	\N	0	1	2	2
7	\N	0	1	2	3
8	\N	0	1	2	4
9	\N	0	1	3	5
10	\N	0	1	3	6
11	\N	0	1	3	7
12	\N	0	1	3	8
13	\N	0	1	3	9
14	\N	0	1	3	10
15	\N	0	1	3	11
16	\N	0	1	4	5
17	\N	0	1	4	6
18	\N	0	1	4	7
19	\N	0	1	4	8
20	\N	0	1	4	9
21	\N	0	1	4	10
22	\N	0	1	4	11
23	\N	0	1	5	1
24	\N	0	1	5	2
25	\N	0	1	5	3
26	\N	0	1	5	4
27	\N	0	1	6	1
28	\N	0	1	6	2
29	\N	0	1	6	3
30	\N	0	1	6	4
31	\N	0	1	7	5
32	\N	0	1	7	6
33	\N	0	1	7	7
34	\N	0	1	7	8
35	\N	0	1	7	9
36	\N	0	1	7	10
37	\N	0	1	7	11
38	\N	0	1	8	5
39	\N	0	1	8	6
40	\N	0	1	8	7
41	\N	0	1	8	8
42	\N	0	1	8	9
43	\N	0	1	8	10
44	\N	0	1	8	11
45	\N	0	1	9	12
46	\N	0	1	9	13
47	\N	0	1	9	14
48	\N	0	1	9	15
49	\N	0	1	10	20
50	\N	0	1	10	21
51	\N	0	1	10	22
52	\N	0	1	10	23
53	\N	0	1	11	20
54	\N	0	1	11	21
55	\N	0	1	11	22
56	\N	0	1	11	23
\.


--
-- Name: sectionallocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('sectionallocation_id_seq', 56, true);


--
-- Data for Name: show; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY show (id, event_id, venue_id) FROM stdin;
1	1	1
2	1	2
3	2	1
4	2	2
5	3	3
6	1	5
\.


--
-- Name: show_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('show_id_seq', 6, true);


--
-- Data for Name: ticket; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY ticket (id, price, number, rownumber, section_id, ticketcategory_id, tickets_id) FROM stdin;
\.


--
-- Name: ticket_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('ticket_id_seq', 1, false);


--
-- Data for Name: ticketcategory; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY ticketcategory (id, description) FROM stdin;
1	Adult
2	Child 0-14yrs
\.


--
-- Name: ticketcategory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('ticketcategory_id_seq', 2, true);


--
-- Data for Name: ticketprice; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY ticketprice (id, price, section_id, show_id, ticketcategory_id) FROM stdin;
1	219.5	1	1	1
2	199.5	2	1	1
3	179.5	3	1	1
4	149.5	4	1	1
5	167.75	5	2	1
6	197.75	6	2	1
7	167.75	7	2	1
8	155	8	2	1
9	155	9	2	1
10	155	10	2	1
11	122.5	11	2	1
12	157.5	5	2	2
13	187.5	6	2	2
14	157.5	7	2	2
15	145	8	2	2
16	145	9	2	2
17	145	10	2	2
18	112.5	11	2	2
19	219.5	1	3	1
20	199.5	2	3	1
21	179.5	3	3	1
22	149.5	4	3	1
23	167.75	5	4	1
24	197.75	6	4	1
25	167.75	7	4	1
26	155	8	4	1
27	155	9	4	1
28	155	10	4	1
29	122.5	11	4	1
30	219.5	12	5	1
31	199.5	13	5	1
32	179.5	14	5	1
33	149.5	15	5	1
34	219.5	20	6	1
35	199.5	21	6	1
36	110	22	6	1
37	55	23	6	1
\.


--
-- Name: ticketprice_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('ticketprice_id_seq', 37, true);


--
-- Data for Name: userentity; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY userentity (id, name, version) FROM stdin;
\.


--
-- Data for Name: venue; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY venue (id, city, country, street, capacity, description, name, mediaitem_id) FROM stdin;
1	Toronto	Canada	60 Simcoe Street	11000	Roy Thomson Hall is the home of the Toronto Symphony Orchestra and the Toronto Mendelssohn Choir.	Roy Thomson Hall	4
2	Sydney	Australia	Bennelong point	15030	The Sydney Opera House is a multi-venue performing arts centre in Sydney, New South Wales, Australia	Sydney Opera House	3
3	Toronto	Canada	170 Princes Boulevard	30000	BMO Field is a Canadian soccer stadium located in Exhibition Place in the city of Toronto.	BMO Field	5
4	Paris	France	8 Rue Scribe	1972	The Palais Garnier is a 1,979-seat opera house, which was built from 1861 to 1875 for the Paris Opera.	Opera Garnier	23
5	Boston	USA	301 Massachusetts Avenue	1972	Designed by McKim, Mead and White, it was built in 1900 for the Boston Symphony Orchestra, which continues to make the hall its home. The hall was designated a U.S. National Historic Landmark in 1999.	Boston Symphony Hall	24
\.


--
-- Name: venue_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('venue_id_seq', 5, true);


--
-- Name: booking_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY booking
    ADD CONSTRAINT booking_pkey PRIMARY KEY (id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: eventcategory_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY eventcategory
    ADD CONSTRAINT eventcategory_pkey PRIMARY KEY (id);


--
-- Name: mediaitem_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY mediaitem
    ADD CONSTRAINT mediaitem_pkey PRIMARY KEY (id);


--
-- Name: performance_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY performance
    ADD CONSTRAINT performance_pkey PRIMARY KEY (id);


--
-- Name: section_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY section
    ADD CONSTRAINT section_pkey PRIMARY KEY (id);


--
-- Name: sectionallocation_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY sectionallocation
    ADD CONSTRAINT sectionallocation_pkey PRIMARY KEY (id);


--
-- Name: show_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY show
    ADD CONSTRAINT show_pkey PRIMARY KEY (id);


--
-- Name: ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (id);


--
-- Name: ticketcategory_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY ticketcategory
    ADD CONSTRAINT ticketcategory_pkey PRIMARY KEY (id);


--
-- Name: ticketprice_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY ticketprice
    ADD CONSTRAINT ticketprice_pkey PRIMARY KEY (id);


--
-- Name: uk_25wlm457x8dmc00we5uw7an3s; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY sectionallocation
    ADD CONSTRAINT uk_25wlm457x8dmc00we5uw7an3s UNIQUE (performance_id, section_id);


--
-- Name: uk_43455ipnchbn6r4bg8pviai3g; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY ticketcategory
    ADD CONSTRAINT uk_43455ipnchbn6r4bg8pviai3g UNIQUE (description);


--
-- Name: uk_4hr5wsvx6wqc3x7f62hi4icwk; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY mediaitem
    ADD CONSTRAINT uk_4hr5wsvx6wqc3x7f62hi4icwk UNIQUE (url);


--
-- Name: uk_ij7n685n8qbung3jvhw3rifm7; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY event
    ADD CONSTRAINT uk_ij7n685n8qbung3jvhw3rifm7 UNIQUE (name);


--
-- Name: uk_k049njfy1fdk2svm5m54ulorx; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY venue
    ADD CONSTRAINT uk_k049njfy1fdk2svm5m54ulorx UNIQUE (name);


--
-- Name: uk_o9uuea91geqwv8cnwi1uq625w; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY performance
    ADD CONSTRAINT uk_o9uuea91geqwv8cnwi1uq625w UNIQUE (date, show_id);


--
-- Name: uk_pcd6hbptlq9jx8t5l135k2mev; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY eventcategory
    ADD CONSTRAINT uk_pcd6hbptlq9jx8t5l135k2mev UNIQUE (description);


--
-- Name: uk_pn5wxc4yrspdflf414rp2337c; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY show
    ADD CONSTRAINT uk_pn5wxc4yrspdflf414rp2337c UNIQUE (event_id, venue_id);


--
-- Name: uk_ruosqireipse41rdsuvhqj050; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY section
    ADD CONSTRAINT uk_ruosqireipse41rdsuvhqj050 UNIQUE (name, venue_id);


--
-- Name: uk_rvx1s1nf4ihydinnk09u2udu5; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY ticketprice
    ADD CONSTRAINT uk_rvx1s1nf4ihydinnk09u2udu5 UNIQUE (section_id, show_id, ticketcategory_id);


--
-- Name: userentity_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY userentity
    ADD CONSTRAINT userentity_pkey PRIMARY KEY (id);


--
-- Name: venue_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY venue
    ADD CONSTRAINT venue_pkey PRIMARY KEY (id);


--
-- Name: fk_2ad0jk30a6hi0twn2xxso6g71; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY performance
    ADD CONSTRAINT fk_2ad0jk30a6hi0twn2xxso6g71 FOREIGN KEY (show_id) REFERENCES show(id);


--
-- Name: fk_2c9wphvw1mi32yr614p4u7cuf; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY venue
    ADD CONSTRAINT fk_2c9wphvw1mi32yr614p4u7cuf FOREIGN KEY (mediaitem_id) REFERENCES mediaitem(id);


--
-- Name: fk_5dwueehoc18d429a6ma2e7t6; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY sectionallocation
    ADD CONSTRAINT fk_5dwueehoc18d429a6ma2e7t6 FOREIGN KEY (performance_id) REFERENCES performance(id);


--
-- Name: fk_5nymmio04sew5y7o7wvtv82na; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY event
    ADD CONSTRAINT fk_5nymmio04sew5y7o7wvtv82na FOREIGN KEY (category_id) REFERENCES eventcategory(id);


--
-- Name: fk_7m3eentl362woisklouu1ub5a; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY show
    ADD CONSTRAINT fk_7m3eentl362woisklouu1ub5a FOREIGN KEY (event_id) REFERENCES event(id);


--
-- Name: fk_7o36hepy47tlyk1ta3ksix9fv; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticketprice
    ADD CONSTRAINT fk_7o36hepy47tlyk1ta3ksix9fv FOREIGN KEY (ticketcategory_id) REFERENCES ticketcategory(id);


--
-- Name: fk_a9mnact8eh853y0kel611i2ak; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY show
    ADD CONSTRAINT fk_a9mnact8eh853y0kel611i2ak FOREIGN KEY (venue_id) REFERENCES venue(id);


--
-- Name: fk_b4y5fuevgavs3drls31ni6wd3; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticketprice
    ADD CONSTRAINT fk_b4y5fuevgavs3drls31ni6wd3 FOREIGN KEY (section_id) REFERENCES section(id);


--
-- Name: fk_bpuwo340e2jxwlwyf8qai3gql; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY section
    ADD CONSTRAINT fk_bpuwo340e2jxwlwyf8qai3gql FOREIGN KEY (venue_id) REFERENCES venue(id);


--
-- Name: fk_cck2yno71efp1ghlfme4ophux; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY event
    ADD CONSTRAINT fk_cck2yno71efp1ghlfme4ophux FOREIGN KEY (mediaitem_id) REFERENCES mediaitem(id);


--
-- Name: fk_ds4sl29sqh0snk7hw733p3fx0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY sectionallocation
    ADD CONSTRAINT fk_ds4sl29sqh0snk7hw733p3fx0 FOREIGN KEY (section_id) REFERENCES section(id);


--
-- Name: fk_fphjem4g2orlpfeabeuxkhycx; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticket
    ADD CONSTRAINT fk_fphjem4g2orlpfeabeuxkhycx FOREIGN KEY (tickets_id) REFERENCES booking(id);


--
-- Name: fk_jvudijc5qlti0547g3fuoctis; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticket
    ADD CONSTRAINT fk_jvudijc5qlti0547g3fuoctis FOREIGN KEY (ticketcategory_id) REFERENCES ticketcategory(id);


--
-- Name: fk_leaf9xapkf0xcql0rj1ju6a3r; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY booking
    ADD CONSTRAINT fk_leaf9xapkf0xcql0rj1ju6a3r FOREIGN KEY (performance_id) REFERENCES performance(id);


--
-- Name: fk_ntne1lqkfmtmke809budx5itq; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticketprice
    ADD CONSTRAINT fk_ntne1lqkfmtmke809budx5itq FOREIGN KEY (show_id) REFERENCES show(id);


--
-- Name: fk_pdk8eed2puqot8lx8c90ledjn; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY ticket
    ADD CONSTRAINT fk_pdk8eed2puqot8lx8c90ledjn FOREIGN KEY (section_id) REFERENCES section(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

