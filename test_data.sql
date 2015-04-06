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
-- Name: annotation; Type: TABLE; Schema: public; Owner: testuser; Tablespace: 
--

CREATE TABLE annotation (
    annotation_id bigint NOT NULL,
    request_id bigint NOT NULL,
    article_id bigint NOT NULL,
    annotation_answer text,
    date_answered timestamp without time zone,
    votes integer DEFAULT 0,
    refs text
);


ALTER TABLE annotation OWNER TO testuser;

--
-- Name: annotation_annotation_id_seq; Type: SEQUENCE; Schema: public; Owner: testuser
--

CREATE SEQUENCE annotation_annotation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE annotation_annotation_id_seq OWNER TO testuser;

--
-- Name: annotation_annotation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testuser
--

ALTER SEQUENCE annotation_annotation_id_seq OWNED BY annotation.annotation_id;


--
-- Name: article; Type: TABLE; Schema: public; Owner: testuser; Tablespace: 
--

CREATE TABLE article (
    article_id bigint NOT NULL,
    article_url character varying(200) NOT NULL,
    article_title character varying(100) NOT NULL,
    article_text text NOT NULL,
    article_date timestamp without time zone,
    date_added timestamp without time zone
);


ALTER TABLE article OWNER TO testuser;

--
-- Name: article_article_id_seq; Type: SEQUENCE; Schema: public; Owner: testuser
--

CREATE SEQUENCE article_article_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE article_article_id_seq OWNER TO testuser;

--
-- Name: article_article_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testuser
--

ALTER SEQUENCE article_article_id_seq OWNED BY article.article_id;


--
-- Name: entity; Type: TABLE; Schema: public; Owner: testuser; Tablespace: 
--

CREATE TABLE entity (
    entity_id bigint NOT NULL,
    entity_name character varying(100) NOT NULL,
    dbpedia_url character varying(200),
    type character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE entity OWNER TO testuser;

--
-- Name: entity_article; Type: TABLE; Schema: public; Owner: testuser; Tablespace: 
--

CREATE TABLE entity_article (
    article_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    relevance numeric(7,6),
    count integer DEFAULT 1,
    text character varying(100)
);


ALTER TABLE entity_article OWNER TO testuser;

--
-- Name: entity_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: testuser
--

CREATE SEQUENCE entity_entity_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE entity_entity_id_seq OWNER TO testuser;

--
-- Name: entity_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testuser
--

ALTER SEQUENCE entity_entity_id_seq OWNED BY entity.entity_id;


--
-- Name: play_evolutions; Type: TABLE; Schema: public; Owner: testuser; Tablespace: 
--

CREATE TABLE play_evolutions (
    id integer NOT NULL,
    hash character varying(255) NOT NULL,
    applied_at timestamp without time zone NOT NULL,
    apply_script text,
    revert_script text,
    state character varying(255),
    last_problem text
);


ALTER TABLE play_evolutions OWNER TO testuser;

--
-- Name: request; Type: TABLE; Schema: public; Owner: testuser; Tablespace: 
--

CREATE TABLE request (
    request_id bigint NOT NULL,
    article_id bigint NOT NULL,
    request_text_surroundings text NOT NULL,
    request_text text NOT NULL,
    date_asked timestamp without time zone
);


ALTER TABLE request OWNER TO testuser;

--
-- Name: request_request_id_seq; Type: SEQUENCE; Schema: public; Owner: testuser
--

CREATE SEQUENCE request_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE request_request_id_seq OWNER TO testuser;

--
-- Name: request_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: testuser
--

ALTER SEQUENCE request_request_id_seq OWNED BY request.request_id;


--
-- Name: annotation_id; Type: DEFAULT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY annotation ALTER COLUMN annotation_id SET DEFAULT nextval('annotation_annotation_id_seq'::regclass);


--
-- Name: article_id; Type: DEFAULT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY article ALTER COLUMN article_id SET DEFAULT nextval('article_article_id_seq'::regclass);


--
-- Name: entity_id; Type: DEFAULT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY entity ALTER COLUMN entity_id SET DEFAULT nextval('entity_entity_id_seq'::regclass);


--
-- Name: request_id; Type: DEFAULT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY request ALTER COLUMN request_id SET DEFAULT nextval('request_request_id_seq'::regclass);


--
-- Data for Name: annotation; Type: TABLE DATA; Schema: public; Owner: testuser
--

COPY annotation (annotation_id, request_id, article_id, annotation_answer, date_answered, votes, refs) FROM stdin;
19	20	8	The Internet of Things (IoT) is the network of physical objects or "things" embedded with electronics, software, sensors and connectivity to enable it to achieve greater value and service by exchanging data with the manufacturer, operator and/or other connected devices. Each thing is uniquely identifiable through its embedded computing system but is able to interoperate within the existing Internet infrastructure.	2015-04-06 14:04:27.464	0	[]
20	20	8	The everything-is-connected tech Valhalla	2015-04-06 14:09:46.92	1	["http://www.bloomberg.com/news/articles/2015-01-06/samsungs-smart-home-master-plan-leave-the-door-open-for-others"]
\.


--
-- Name: annotation_annotation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testuser
--

SELECT pg_catalog.setval('annotation_annotation_id_seq', 22, true);


--
-- Data for Name: article; Type: TABLE DATA; Schema: public; Owner: testuser
--

COPY article (article_id, article_url, article_title, article_text, article_date, date_added) FROM stdin;
8	http://www.bloomberg.com/news/articles/2014-06-21/google-s-nest-buying-security-company-dropcam-for-555-million	google s nest buying security company dropcam for 555 million	     June 21 (Bloomberg) -- Google Inc.’s Nest Labs is acquiring Dropcam Inc. for $555 million to boost its offerings for the connected home. \nThe deal will be in cash and subject to adjustments, Nest said in a statement yesterday. Dropcam makes in-home cameras that can be checked from a smartphone anywhere in the world, an offering that would broaden Nest’s product line-up into home security. Nest sells digital thermostats and smoke alarms that can also be checked and adjusted remotely from mobile gadgets. \n“We care very deeply about helping people stay connected to their home, especially when they’re not in their home,” said Matt Rogers, co-founder of Nest, which is based in Palo Alto, California, in an interview. “This is another offering that helps people get insights into their home.” \nThe purchase underlines how Nest, which Google bought for about $3.2 billion earlier this year, is working to become a bigger player of connected devices for consumers. The trend is part of a technology movement dubbed the “Internet of things,” where more gadgets and everyday items are connected to the Web and can deliver data and be controlled by mobile devices. \nThe products gather data on consumer habits and usage. Privacy experts have questioned how Google, the world’s largest search engine, would use Nest’s data. Nest has said its information will remain separate from its parent company. \nDropcam’s data will also remain distinct from Google, Rogers said. \nThe acquisition adds to a growing list of purchases by Google this year as it looks beyond its own engineers for new capabilities. The Mountain View, California-based company disclosed at least five purchases in May and has announced at least three more in June. One of those was was a $500 million deal for Skybox Imaging Inc., which designs satellites that can help Google’s efforts around mapping and Internet access. \nNest, which was co-founded by former Apple Inc. executive Tony Fadell, has run into product challenges recently. In April, Nest said it was suspending sales of its smoke alarms after it determined the units could be switched off unintentionally. The products are now back on the market. \n‘Kindred Spirits’ \nDropcam, which was founded in 2009, lets users place cameras throughout a home for live-viewing and recording. The cameras also include options for night vision and two-way talking with built-in microphones. The San Francisco-based company’s backers include Accel Partners and Menlo Ventures. \nDeal discussions began a little more than a month ago after Nest approached Dropcam, which wasn’t looking to sell, said Mark Siegel, managing director at Menlo Ventures. The talks were led by Fadell and Rogers, he said. Menlo Ventures invested about $8 million in Dropcam in 2012 when the startup was valued at around $50 million. \n“There’s very much of a shared vision there,” Siegel said in an interview. “Had this not been Nest, I think it might have made it a harder decision to make.” \nAs part of the acquisition, Dropcam’s staff will move to Nest’s Palo Alto offices. Dropcam’s co-founders include Chief Executive Officer Greg Duffy and Chief Operating Officer Aamir Virani. \n“Nest and Dropcam are kindred spirits,” Duffy wrote in a blog post about the deal. “Both were born out of frustration with outdated, complicated products that do the opposite of making life better.” \nThere could be Nest and Dropcam offerings that are tied together after the acquisition, Rogers said. \n“Given how closely aligned the teams are, in terms of our product philosophy -- we see lots of product offerings and tie-ins we could do in the future,” he said. “We haven’t figured it out yet.” \nTo contact the reporter on this story: Brian Womack in San Francisco at  bwomack1@bloomberg.net \nTo contact the editors responsible for this story: Pui-Wing Tam at  ptam13@bloomberg.net Reed Stevenson \n	2014-06-21 00:00:00	2015-04-06 12:32:03.189
9	http://www.bloomberg.com/news/articles/2015-01-25/samsung-s-63-billion-cash-pile-augurs-tech-takeovers-real-m-a	samsung s 63 billion cash pile augurs tech takeovers real m a	     (Bloomberg) -- Whether or not Samsung Electronics Co. has BlackBerry Ltd. in its sights, it should spend some of its $63 billion of cash on takeovers. \nSamsung, which has an alliance with BlackBerry, this month denied reports it proposed buying the Canadian smartphone maker for as much as $7.5 billion. Even so, a takeover would give Samsung the software to help its products communicate, according to Current Analysis Inc. \nThe $190 billion South Korean conglomerate makes dozens of consumer goods, from phones and televisions to vacuum cleaners and ovens. What it needs is technology to link all the devices together online in the wireless homes of the future. Other potential targets include Atmel Corp. and Freescale Semiconductor Ltd., whose chips help devices talk to each other, said CM Research Ltd. \n“Samsung is a hardware company caught up in a software revolution,” said Cyrus Mewawalla, managing director at London-based CM Research. “So it needs to make acquisitions.” \nThe goal is to profit from what’s known as the Internet of Things, a world where everyday items, from toasters and washing machines to phones and printers, are sewn together online and controlled by devices. The market for the Internet of Things could reach $7.1 trillion by 2020, research firm IDC has said. \n“There are many areas in Internet of Things,” from sensor technology to components, Samsung said in an e-mailed statement. “Samsung regards M&A as one of our key business strategies, in conjunction with organic growth, and we continue to remain open to partnership and acquisition opportunities.” \nShares of Samsung rose 0.2 percent to 1,389,000 won at the close of trade in Seoul. The stock has gained 7.5 percent in the past year. \nThe Suwon-based company in August bought SmartThings, a startup that makes mobile applications to remotely control household goods. And the previous year, Samsung bought Novaled AG, a German maker of material to light up a gadget’s screen, and MOVL, which has developed a service that allows users to share content between devices such as phones and TVs. \nThose deals don’t go far enough, said Neil Shah, research director for devices and ecosystems at Counterpoint Research. \n“Samsung has the vision of how the connected future will be, but still lacks the expertise and capabilities to tie all the assets together,” Shah, who is based in Mumbai, said in an e-mail. \nSamsung said in November 2013 it would be more aggressive in pursuing targets after spending only $1 billion on takeovers in three years. The earnings power from its Galaxy smartphone lineup is fading and Apple Inc. and Xiaomi Corp. are gaining ground. Samsung’s own Tizen software platform has struggled to gain traction. \n“In the near term, it’s hard to see the pressure coming off them from Xiaomi and all the others,” said Dan Baker, an analyst at Morningstar Inc. in Hong Kong. “Samsung at the moment doesn’t really have a software advantage.” \nBlackBerry could “potentially be a great acquisition,” Shah at Counterpoint Research said. BlackBerry has messaging software that could be rolled out to connect a chain of Samsung products, and a software program that manages different devices at once. BlackBerry’s QNX automotive software, which enables drivers to make hands-free calls, sports three-dimensional navigation and 3-D gaming for rear seats, is also a draw, he said. \nSamsung co-Chief Executive Officer Shin Jong Kyun said this month he wanted to develop the two companies’ alliance, rather than pursue an outright purchase of BlackBerry. Both denied a Reuters report that Samsung had made a takeover offer. \nWhile Samsung is the world’s second-largest semiconductor maker, it still could make acquisitions in this area to boost its capabilities. \nLast week, people with knowledge of the matter said Samsung will use its own chips in the next Galaxy S smartphone and drop a Qualcomm Inc. unit. That’s a sign Samsung wants more control of the processors in its products, Morningstar’s Baker said. San Jose, California-based Atmel, which has a market value of $3.5 billion, and the $7.9 billion Freescale, are both feasible chipmaking targets for Samsung, he said. \nAtmel is among chipmakers focusing on the Internet of Things, developing technologies that help machines talk to each other and building wireless-radio capabilities. Atmel’s chips power washing machines and cookers as well as car doors and windows. Freescale’s semiconductors are used in everything from space hardware to household goods. \nA representative for Atmel declined to comment on whether it’s been approached by buyers or has explored a sale. A representative for Austin, Texas-based Freescale didn’t respond to a phone call or e-mail seeking comment. \nOther targets that Samsung might consider: Opera Software ASA, a Norwegian maker of Internet browsers for phones, tablets and computers, which has a market value of $1.9 billion; and closely held AlertMe Ltd., a U.K. company that has developed technology to control dozens of devices from different manufacturers on a single network, according to Mewawalla at CM Research. \nSensor makers would also make sense as targets, said Park Hyun Je, a creative planner at a research and development center under the South Korea’s science ministry. \nFor companies attempting to profit from the Internet of Things, it’s tough to pick the right targets because the concept is in its infancy, said Avi Greengart, research director for consumer devices at Sterling, Virginia-based Current Analysis. \n“It’s not clear which layer of the technology stack will provide the most value and control,” Greengart said in an e-mail. “Any investment, whether homegrown or via acquisition, may lead to dead ends.” \nSamsung is willing to spend. The company this month said it will invest more than $100 million in developers of smart technology for homes and devices. Samsung Ventures, a venture capital firm, led a $20 million funding round for Israel’s EarlySense Ltd., the companies said in a Jan. 20 statement. \nAll the same, takeovers might be the fastest way for Samsung to prepare for the explosion of connected devices that’s expected this decade. \nWhen it comes to software, Samsung “looks far behind its competitors,” said Mewawalla at CM Research. \nTo contact the reporters on this story: Jungah Lee in Seoul at  jlee1361@bloomberg.net; Angus Whitley in Sydney at  awhitley1@bloomberg.net \nTo contact the editors responsible for this story: Michael Tighe at  mtighe4@bloomberg.net; Beth Williams at  bewilliams@bloomberg.net Beth Williams, Elizabeth Wollman \n	2015-01-25 00:00:00	2015-04-06 12:32:29.5
10	http://www.bloomberg.com/news/articles/2015-01-06/samsungs-smart-home-master-plan-leave-the-door-open-for-others	samsungs smart home master plan leave the door open for others	The most important product at the 2015 Consumer Electronics Show may not actually be a product at all. It’s a policy. Samsung Electronics has pledged that 90 percent of all devices it creates, including televisions and mobile devices, will be Internet-enabled by 2017—just two short years away. The remaining 10 percent will come on board by 2020. Considering that in 2014 Samsung delivered more than 665 million products to consumers around the world, it’s hard to understate how important this is to the overall move to turn the Internet of Things—the everything-is-connected tech Valhalla—from a plaything for early adopters into the mainstream of moms and microwaves.\nThere's more: In addition to building this functionality into its own products, Samsung's platform will be entirely open, rolling out the red carpet for developers and other software and hardware manufacturers to, basically, have at it. Samsung's smart-home push has been anticipated for a long time, particularly since it acquired smart-home sensation SmartThings in August 2014, but few expected this level of openness. Samsung could have just as easily created a walled garden, forcing users to choose from Samsung or a specific partner devices to assemble a networked life of automatic temperature adjustments and TV-based alerts.\n“The Internet of Things is not about things, it is about people,” said Samsung Chief Executive Yoon Boo Keun early in a keynote address on Monday, hitting on a sentiment he would repeat over and over again. Creating an Internet of Things that did not place improving people’s lives at the core of its mission would be “like a bedtime story for robots.”\nNot everyone allows so many types of interactions. On Monday, Google's Nest announced its own smart-home ecosystem, but its Works with Nest protocol places restrictions on the types of data that can be shared, how long those data can be stored, and how they can be used. For Samsung, Yoon said, an opposite approach has its benefits: It hopes an “open ecosystem” will lead consumer needs and desires to optimize Samsung products in ways that might not have been thought of in Seoul. Samsung has also committed $100 million dollars to invest in development of a connected ecosystem, meaning everything from creating infrastructure, to funding startups, to facilitating conversations between existing players.\nThe move comes as Samsung's hugely successful smartphone business is under significant pressure, particularly from lower-cost competitors in China. "When the mobile business ceases to be profitable, Samsung will have to force its way into some other industry that requires a lot of upfront capital and expertise in mass-manufacturing," my colleague Sam Grobart wrote in Bloomberg Businessweek almost two years ago. At the time, Samsung had announced its intentions in medical devices, solar panels, LED lighting, and batteries for electric cars. The Internet of Things fits right in. Samsung, with its unique combination of technological breadth and depth, can create the Things at scale: They already make sophisticated electronic components and circuitry and a full suite of household appliances. Its ability to design, produce, and market what it makes is already global in scale. This is a level of integration the company would appear to be quite comfortable with. \nSmartThings is still at the core of Samsung’s push forward. Though Yoon didn't emphasize it in his keynote, SmartThings unveiled the second version of its core Hub product—its version of a central command center for your house—earlier in the day, along with updates to its other hardware offerings. But in an interview after Yoon's keynote, SmartThings CEO Alex Hawkinson reiterated that “SmartThings is, at its heart, a software company.” Specifically, it's the  software that allows everything to work together, from Samsung’s connected wine cellar, to its latest smartphone, to an August lock, to a Jawbone UP. SmartThings’ Hub essentially takes all the data coming in from all of these different sources and allows them to speak with one another. Your sleep tracker can tell you what not to watch on TV before bed; your lock tells the lights when you’re gone for the day.\nOpen systems can have their drawbacks. Users might not notice, but in the beginning, a jumble of protocols and languages will most likely compete on the back end. Hawkinson is confident that, over time, Samsung's and SmartThings’ approach will allow certain protocols to rise to the top and that market dynamics will consolidate standards. If that process is relatively smooth and speedy, it will result in lower-cost, lower-friction development. If not, it's a long messy haul, which could discourage the very kind of participation that Samsung needs to lift the whole effort off the ground. \nServices also stand to be a big part of the Internet of Things marketplace as Samsung envisions it. SmartThings will offer the first, a premium subscription service (price to be announced) that will allow users to configure message and phone call alerts that can be escalated to friends and family. If you leave the oven on, you might get an alert; if the security alarm goes off, your down-the-street neighbors might get one, too. Without rigid boundaries between different manufacturers' devices, it wouldn't be surprising to see third parties figure out how to squeeze more functionality out of them for a fee. This is the Google Play store for your kitchen instead of your Galaxy.\nThere's still a long way to go before this is all a reality. Samsung gave itself a two-year runway, and it'll take a good bit of time after that for homeowners to embrace the devices. Buying a new smartphone is a lot easier than swapping out all your home appliances. For now, Samsung’s pledge of a well-developed, truly open Internet of Things starts with the SmartThings Hub, some well-credentialed corporate partners, and a lot of people who really want to see this succeed.\n	2015-01-06 00:00:00	2015-04-06 12:32:50.604
11	http://www.bloomberg.com/news/articles/2015-01-20/sierra-wireless-leads-in-race-for-internet-of-everything	sierra wireless leads in race for internet of everything	     (Bloomberg) -- Sierra Wireless Inc. was selling equipment that allowed trains to be tracked online before the Internet of Things became the latest technology buzzword. Now that phrase is helping the company’s stock trade near a 10-year high. \nSierra Wireless, the biggest seller of equipment to connect machines over cellular networks, was the third-best performing stock on Canada’s benchmark equity index in 2014 as revenue rose six straight quarters. The company’s shares have soared more than six-fold over the past two years, outstripping Ubiquiti Networks Inc., which tripled over that time for the next biggest gain among peers, according to data compiled by Bloomberg. \n“This is all we do,” Chief Executive Officer Jason Cohenour said in a Jan. 9 interview at the company’s Richmond, British Columbia headquarters. “We’re probably the most focused company in the business.” \nCisco Systems Inc., General Electric Co. and BlackBerry Ltd. have all said connected devices are an integral part of their future. Cisco predicts 50 billion “things” will be connected by 2020, creating $14.4 trillion in value for companies between 2013 to 2022 in lower costs and higher revenues. \nSierra says it has already connected 100 million devices and is the leader in sales of cellular machine-to-machine modules, according to a report last year from technology research firm ABI Research of Oyster Bay, New York. Their closest competitors are Italy-based Telit Communications Plc and Amsterdam-based Gemalto NV, ABI analyst Dan Shey said in a phone interview. \nSierra Wireless bought Karlskrona, Sweden-based Wireless Maingate AB in December for $90 million to allow it to provide wireless coverage and services to its hardware customers, instead of having to go through a phone company. \nThe company still has $50 million in cash it could use for takeovers and could raise more if needed, the CEO said. “If we find the right targets, and we’re convinced we can create value by adding those targets, I believe they are imminently financible beyond our current cash position,” he said. \nThe company has been focused on the Internet of Things since 2008 when it bought Wavecom SA of France. \n“Basically the low point of the stock market, when the world was coming to an end, this current CEO of Sierra, Jason Cohenour, bet the entire company on the Internet of Things,” said Michael Walkley, an analyst at Canaccord Genuity Inc. in Minneapolis who’s covered the company since 1999. \n“They’ve really had better-than-expected revenue growth,” he said. “We think they’ll be able to grow 20 percent plus in the next year or two.” The company has posted average quarterly sales growth of 18 percent year over year in the past six quarters. \nIt’s unlikely competitors will elbow out smaller manufacturers like Sierra Wireless, said Anindya Ghose, a professor at New York University who studies how the trend will affect businesses. \nInstead, smaller companies could become acquisition targets for technology giants looking to build out their presence in connected devices, Ghose said in an interview from New Delhi, declining to comment on whether Sierra would be a target. \n“There’s no silver bullet for a major platform provider, chip-set supplier and there’s no silver bullet for a big IT guy like IBM or Cisco either,” Cohenour said. \nAfter Sierra’s rapid stock gain, some analysts are starting to question the company’s value. Only two of 16 analysts surveyed by Bloomberg recommend buying the stock, compared with more than 60 percent of those surveyed in September 2013. There are currently nine holds and four sells on the company. \nThe shares fell 1.8 percent to C$48.22 at the close in Toronto for a market value of C$1.53 billion ($1.26 billion), down from a high this year of C$56.37 on Jan. 2. The shares have risen 508 percent in the past 24 months. They peaked at about C$216 at the height of the technology boom when the company built modems for laptops. \n“I just think the stock is ahead of itself,” said Steven Li, an analyst at Raymond James Financial Inc., who downgraded it to “underperform,” the equivalent of a sell, earlier this month. \n“Part of those revenue gains came from market share gains. They had two of their major competitors exiting the market,” Li said. “I’ll take that any day, but it’s not repeatable.” \nThe company should focus on its plans to sell software to help companies manage all those connections and offer their own wireless networks to set itself apart from others jumping onto the Internet of Things trend, Li said. \nEven as excitement grows around the Internet of Things, the market is still wide open, Cohenour said. None of the 10 markets Sierra Wireless sells into such as connected cars or mobile payments are anywhere close to being fully tapped, he said. \n“There’s a long way to go,” he said. “We don’t fear saturation at any point in the next decade plus.” \nTo contact the reporter on this story: Gerrit De Vynck in Toronto at  gdevynck@bloomberg.net \nTo contact the editors responsible for this story: Sarah Rabil at  srabil@bloomberg.net Jacqueline Thorpe \n	2015-01-20 00:00:00	2015-04-06 12:33:06.551
12	http://www.bloomberg.com/news/articles/2015-03-04/google-challenge-to-iphone-reign-opens-platform-door-for-toshiba	google challenge to iphone reign opens platform door for toshiba	     (Bloomberg) -- Google Inc.’s key ally in its challenge to the smartphone status quo is a company that Apple Inc.’s iPhone drove out of the market. \nToshiba Corp. makes the chips that power Google’s Project Ara modular handset, which will let users swap out displays, cameras and batteries as easily as snapping on Lego bricks. \nAra phones have the potential to disrupt the two-year product cycle of Apple and Samsung Electronics Co., which rely on upgrades and features to lure consumers to new models, according to Bloomberg Intelligence analysts John Butler and Matthew Kanterman. They would also loosen smartphone makers’ grip on suppliers and allow parts manufacturers like Toshiba to sell components directly to end users. \n“Right now, you either have a place in an Apple device or you’ve got nothing,” Takeshi Oto, a senior fellow at Toshiba’s logic chip division, said in an interview in Tokyo on Feb. 19. “When the barriers for installing new functions are lowered, component makers like us will benefit.” \nThe Ara platform is used to make an electronic endoskeleton with magnetically attached components. Toshiba’s switch chip lives in that chassis, routing signals between parts that contain its bridge chips. The Tokyo-based chipmaker and industrial group is also behind the technology to transmit data within devices without a physical contact. \nGoogle has exclusive rights to sell the switch chip, while Toshiba is free to sell bridge chips to any module maker, Oto said. Ara devices on the drawing board include a game controller, laser pointers and a night-vision module, according to the projectaraforum blog. \nAn Ara smartphone prototype that will debut in a trial in Puerto Rico later this year will carry a camera block designed by Toshiba, Oto said. That’s a win for the company in a market dominated by Sony Corp.’s image sensors. Toshiba is also developing wireless charging and data transfer modules, he said. \nToshiba sold its mobile phone operations to Fujitsu Ltd. in 2012, succumbing to the iPhone’s dominance, and now relies on memory and logic semiconductors for about 80 percent of its operating profit. Its NAND flash chips are found in devices from Samsung’s Galaxy to Apple’s iPad Mini, according to iFixit tear downs. \nThe Japanese company’s shares were little changed at 487 yen at the close in Tokyo on Wednesday. The stock is trading at about a third of its 1,275 yen peak in 2000. \nAra gives the conglomerate -- which makes everything from medical scanners to nuclear power components, notebook computers and televisions -- a chance to move up the food chain in the smartphone industry, Toshiba’s Oto said. \n“Google is going for a paradigm shift in trying to democratize smartphone hardware, and that’s something worth investing in,” he said. \nModularity does come at a price. Because conventional phones have advantages in power, cost and size, Ara will have to deliver compelling new functions, Oto said. The handicap may be less significant when the platform evolves beyond the smartphone form factor to encompass a variety of devices, he said. \n“Once you have standardized interfaces, there is no reason why it has to stop with the phones,” he said. “We are looking ahead to the Internet of Things.” \n(A previous version of this story corrected the spelling of Takeshi Oto’s name.) \nTo contact the reporters on this story: Pavel Alpeyev in Tokyo at  palpeyev@bloomberg.net; Takashi Amano in Tokyo at  tamano6@bloomberg.net \nTo contact the editors responsible for this story: Michael Tighe at  mtighe4@bloomberg.net Dave McCombs \n	2015-03-04 00:00:00	2015-04-06 12:33:23.204
13	http://www.bloomberg.com/news/articles/2015-02-10/hitachi-to-buy-pentaho-to-bolster-data-analysis-software-tools	hitachi to buy pentaho to bolster data analysis software tools	     (Bloomberg) -- Hitachi Ltd.’s enterprise-technology unit plans to acquire data-management company Pentaho Corp. for $500 million to $600 million, a person with knowledge of the matter said. \nHitachi Data Systems will merge Pentaho’s data analysis and management tools into its products, while other technologies will be used in Hitachi’s ventures in areas such as the Internet-of-things and large-scale data processing, the companies said in a statement today. \nEnterprise information-technology companies are seeking to better respond to growing amounts of data that companies need to analyze by buying up firms with expertise in information  analysis. Other recent deals include Microsoft Corp.’s agreement  to acquire Revolution Analytics last month, and Salesforce.com  Inc.’s purchase of e-mail-analysis startup RelateIQ for about  $400 million in July. \nJoseph Beare, a spokesman for Hitachi Data Systems, and Katie Watson, a spokeswoman for Pentaho, declined to comment on the deal price. Pentaho’s open-source software will continue to be free following the acquisition, which is scheduled to close in June this year. \nPentaho, based in Orlando, Florida, is Hitachi’s 12th-largest acquisition to date, according to data compiled by Bloomberg. Hitachi has been reselling Pentaho’s technology for the past year before the deal, according to Kevin Eggleston, Hitachi Data Systems senior vice president of Social Innovation and Global Industries. \n“We’re taking their capabilities, especially data blending, data on the ingest side, data orchestration and will be using it as part of our stack in big data and Internet of things,” Eggleston said. \nPentaho, which has 285 employees, was founded in 2004 and had $60 million in venture funding to date from investors including New Enterprise Associates, Index Ventures, Benchmark and DAG Ventures. \nTo contact the reporter on this story: Jack Clark in San Francisco at  jclark185@bloomberg.net \nTo contact the editors responsible for this story: Pui-Wing Tam at  ptam13@bloomberg.net Reed Stevenson, John Lear \n	2015-02-10 00:00:00	2015-04-06 12:33:35.943
14	http://www.bloomberg.com/news/articles/2015-02-19/mark-zuckerberg-q-a-the-full-interview-on-connecting-the-world	mark zuckerberg q a the full interview on connecting the world	Facebook Chief Executive Officer Mark Zuckerberg has a big, expensive goal: to connect the world to the Internet. He spoke with Emily Chang about his plans, after returning from a trip through Southeast Asia and India last year as part of his Internet.org initiative. The interview airs Feb. 19 on Bloomberg Television's Studio 1.0. The transcript below has been lightly edited.\nYou are a year and half into this. Tell me your vision; tell me what inspired you to do this.\nZuckerberg: When people are connected, we can just do some great things. They have the opportunity to get access to jobs, education, health, communications. We have the opportunity to bring the people we care about closer to us. It really makes a big difference. The Internet is how we connect to the modern world, but today, unfortunately, only a little more than a third of people have access to the Internet at all. It’s about 2.7 billion people, and that means two-thirds of people don’t have any access to the Internet. So that seems really off to me.\nThere are all these studies that show that in developing countries, more than 20 percent of GDP growth is driven by the Internet. There have been studies that show if we connected a billion more people to the Internet, 100 million more jobs would be created, and more than that would be lifted out of poverty. So there is just this deep belief here at Facebook that technology needs to serve everyone. Connectivity just can't be a privilege for people in the richest countries. We believe that connecting everyone in the world is one of the great challenges of our generation, and that’s why we are happy to play whatever small part in that that we can.\nWhat has been your single greatest achievement, and what has been your biggest setback?\nThe last period has mostly been about learning. We’ve been working on this for a few years so far, and what we’ve really learned is that there are a few major barriers to connectivity, and they are not necessarily what you would have thought of upfront. The first one is that a lot of people just don’t have any access to a network, so it’s a technical barrier. So even if they had a phone and could pay for data, there would be no equivalent to a cell phone tower near them to access that. That’s what a lot of people think about when they think about not having connectivity, and there are projects like satellites and drones and things like that that we are working on that can create connectivity and solutions in areas where they aren’t today. And that’s important. But it turns out that’s actually a pretty small part of the problem. Only about 15 percent of people who aren’t connected aren’t connected because of a technical barrier\nThe next barrier is affordability. And a lot of the people who have access can’t afford to pay for it. So the solution to that is to make it more efficient. Make it so the network of infrastructure operators are using is more efficient, so the apps people use consume less data. And there’s a lot of work that is going into that. You know, we’ve made the Facebook app on Android, for example. I think it uses about five times less data than it did last year. So that directly goes to being cheaper for people to use, and we’ve made a bunch of these tools open for other people to use as well.\nBut it turns out that the biggest hurdle isn’t technical or affordability—it’s the social challenge, where the majority of people who aren’t connected are actually within range of a network and can afford it, but they don’t know what they would want to use the Internet for. And that kind of makes sense if you think about it. If you grew up, and you never had a computer, and you’ve never used the Internet, and someone asked you if you wanted to buy a data plan, your response would be “What’s a data plan, and why would I want to use this?” And I think that ends up being the biggest challenge and one where we can create the most value and help people out the most by giving people some free basic services by working with operators and governments and helping people understand what they can use the Internet for, to on-ramp for everyone.\nFacebook is a for-profit company. Why call it Internet.org? Is this a nonprofit? Is this a charity?\nIf we were primarily focused on profits, the reasonable thing for us to do would really just be to focus on the first billion people using our products. The world isn’t set up equally, and the first billion people using Facebook have way more money than the rest of the world combined. So from a biz perspective, it doesn’t make a whole lot of sense for us to put the emphasis into this that we are right now. The reason why we are doing it is two things. One is mission. We are here to help connect the world, and we take that really seriously. You know, you can’t even do that if two-thirds of the world doesn’t have access to the Internet. We just turned 10 as a company, and we decided that in the next 10 years, we want to take on some really big challenges in the world, like helping everyone get online. And that’s just an important thing for us and, I think, for other Internet companies in fulfilling this mission overall.\nIn the long term, I do think it could be good for our company, as well, if you look at it in a 10-, 20-, 30-year time horizon because a lot of these countries and economies will develop, and over time will be important. But most people who are running businesses don’t make investments for 30 years down the line in terms of products that they are going to build.\nDo you have a better idea of when this will become profitable?\nNo, I don’t have a better idea. The reality is just that a lot people can’t afford to pay for data access in some of these areas; then they probably aren’t ad markets, and it's probably not going to be a place where it’s going to be particularly profitable in the near term. In fact, we’ll probably lose a bunch of money—just because supporting Facebook as a service, and storing the photos and content that people want to share, costs money. We probably won’t offset it by making much. But there’s this mission belief that connecting the world is really important, and that is something that we want to do. That is why Facebook is here on this planet.\nAnd then there is this longer-term belief that this is going to be good for these countries if people have access to these tools, and over time, if you do good things, then some of that comes back to you. But you just have to be patient, and you can’t always know what the plan is going to be upfront.\nYou’ve said connectivity is a human right; you want to do good things. If that’s the case, why not just give access to the complete Internet? Why just a few apps?\nYeah, it’s a good question. So it comes down to the economics of how this works. It turns out that most of the Internet consumed is rich media, especially videos. So if you look at things like text, text-message services like search or Wikipedia, or basic financial or health information, can be delivered relatively cheaply and can consume less than 1 percent of the overall infrastructure. So if you are thinking about building something that operators can offer for free, it needs to be pretty cheap for them to do. And we’ve basically figured out a series of services that people can offer, and it actually ends up being profitable for the operators. The model that we consider this to be most similar to is 911 in the U.S. So even if you haven’t paid for a phone plan, you can always dial 911, and if there is a crime or a health emergency or a fire, you get basic help, and we think there should be an equivalent of this for the Internet as well—where even if you haven’t paid for a data plan, you can get access to basic health information or education or job tools or basic communication tools, and it will vary, country by country.\nFor example, when we launched in Zambia, there, you know, HIV is a really big deal. So one of the services that the government and folks wanted to include were services so you can learn about HIV, learn about different aspects of maternal health. That ended up being very important. And in different places, there are going to be different tools that are important for this kind of 911 for the Internet.\nWe’ve spoken to ad executives who are excited to advertise on Internet.org. How does that benefit users?\nI’m not sure it’s a big part of the solution in the near term, to be honest. What we need to do is work out a model with operators and governments and local partners that is profitable for them so we can continue growing the Internet. What we have found in some of these early countries that we have worked in—Indonesia, the Philippines, Zambia, Kenya—is you offer a little bit of the Internet free, and more people start using data, and more people can access the Internet and access these tools, but also more people start paying for data once they understand what they would use the Internet for. The people understand why they would want to pay for data, and these operators end up making more money, and it ends up being more profitable, and it ends up taking that money and reinvesting that in better Internet and infrastructure for everyone in their country. So that ends up being very important, and a lot of what we have focused on for the past couple of years is just: How do you build a model that is sustainable for everyone and delivers free Internet to people?\nOriginally, we thought that maybe working with other kinds of partners would be important, but at this point, we think we have a sustainable model that is working in multiple countries now, and there’s a lot of momentum and a lot of countries coming online now, and a lot of other countries are coming to us to roll out the Internet.org model. So I expect to see a lot more over the next year.\nDoes that mean no advertising?\nIn a lot of these countries, there isn’t a very big ad market yet. So it's not that we won’t do it eventually, but for right now and our business, the main thing that we need to continue to do is focus on the quality of the ads and doing that in the developed world—in the U.S. and Europe and Asia and a lot of places that are actually going to be the driver of our own profitability and revenue—not trying to make ad markets out of countries that are just coming online.\nNow, once you get people connected and once you have that power, how do you use that power?\nFor us, it's all about enabling people. We worked with Airtel in Zambia. They were our first partner to roll out the suite of free basic services. And within weeks, we started hearing these pretty amazing stories coming in of people using the Internet—an expectant mother using the Internet for the first time to look up safety and health information for how to raise her child; a poultry farmer using Facebook and setting up a page in order to sell multiple times more chickens than he had been able to before; a university student using the Internet, using Wikipedia to look up information and save money on books that she needed for an exam. It’s pretty crazy.\nWhat kind of data are you collecting about these users, and how do you use that data?\nI don’t think it's anything different than how people use Facebook normally. The biggest thing we’ve had to do to make Internet.org work is connect with the different operators in these countries—for example, Airtel in Zambia—to make it so people have a very easy way to go buy data when they want to do more things.\nFor example, you might be browsing Facebook and see a link to news, or you see some video that you want to watch—that can’t be covered for free, but we make it so if you tap on that, it's very easy to online pay, and that’s good for everyone. It makes it so people can discover why they would want to consume content on the Internet. It makes it so Airtel and our partners can make more profits, and continue investing, and building out a faster and broader Internet, and it gets everyone online.\nGoogle is working on Project Loon and Google Fiber. What do you think of Google’s approach?\nConnecting everyone is going to be something that no single company can do by themselves. So I’m really glad that they and a lot of other companies are working on this. Internet.org is a partnership between a number of different technology companies and nonprofits and governments. There are companies that are doing things that are separate, and that’s going to be necessary, right?\nHave you had talks with Google about partnering with them? Would you ever partner with Google?\nYeah, our team is in contact with them frequently, and I talk to a number of folks over there. When we launched in Zambia, Google was actually one of the services that was in the Internet.org suite, and that’s valuable. In addition to health services and education, jobs and different government services and communication tools, people need to be able to search and find information. And whether we work with Google or others on that in all of these other countries, I think that is an important thing. I’d love to work with Google. They are a great search product.\nBill Gates criticized Google's Project Loon. How do you respond to that?\nYeah, Bill and I have had a few conversations about this and other things that we have worked on together. And I think the reality is that people need a lot of things in order to have good lives, right? Health is certainly extremely important, and we’ve done a number of things at Facebook to help improve global health and work in that area, and I am excited to do more there, too. But the reality is that it’s not an either-or. People need to be healthy and be able to have the Internet as a backbone to connect them to the whole economy. The Internet creates jobs. It actually is one of the things that facilitates health.\nFor example, in the most recent Ebola outbreak, one of the things that Facebook tried to do was we asked a bunch of folks who were involved in containing the outbreak, “What can we do to help?” and the No. 1 thing that they said was "Help us get connectivity because we need to be able to wire up all these different Ebola treatment units to make it so we can coordinate the response, so people know and can count the people who have come into contact with the people who have Ebola." So it ends up being important. I’m certainly not here saying connectivity is more important than health. I mean, that would be ridiculous, but I hope that we can help out with all of these things over time.\nSo, drones and lasers—you’ve got a whole, big lab working on this. When will Facebook drones and lasers be ready for launch?\nWe are going to be testing some in the near future, so I think I'll probably be mistaken if I give you an exact date on this. But that’s one of the big technical barriers, right? There are a lot of people who don’t live within range of a network, and drones and satellites and communications lasers is one way to do it. Microwave communication is another.\nYou made it clear on the earnings call that Facebook is going to be ramping up spending. How much of that is going to Internet.org and these efforts—the NASA Jet Propulsion Lab—and where are you working on all of this other cool technology?\nWe’re definitely investing a bunch in this.\nHave you flown a drone yet?\nMe, personally?\nYeah.\nWell, I think the nature of a drone is the person doesn’t fly it.\nIn some cases, you pilot it, or you watch it go up?\nThat’s right. No, I have not.\nYou have not, OK.\nI’ll let our team of experts do that.\nWe were talking about China. Your Mandarin has gotten pretty good. What's the likelihood that Internet.org could help you get back into China, get Facebook back into China?\nThat’s not something that we are focused on right now with Internet.org. There are countries where they reach out to us and say, “Connectivity is a national priority, and a lot of people in our country use Facebook—and if there is a way to work together to do that ...” For example, Malaysia—I was meeting with one of the leaders in the government there. Making it so that everyone in their country is connected is one of the top national priorities, similar to Indonesia. It makes sense that we prioritize countries that are reaching out to us actively for this.\nHow will you judge whether this has been a success?\nThe goal here is to make it so that a person can walk into a store in any developing country and buy a phone and get access to some free basic Internet service, and that’s the primary goal for people around the world. Once we’ve made it so this system is working in every country, that will be step one, and step two will be making it so that people will use it, which will be its own multiyear challenge, just because the Internet is one of the best ways to teach people about what services are out there.\nA secondary goal is to make it so this is a profitable thing for the whole international operator community, because that’s how you make this sustainable. This can’t be something that is just charity for these operators around the world. This will work if providing free basic services actually ends up being a way for them to get more paying customers and more people online, and then they spend more money to invest and build faster networks and reach more people.\nThe signs that we have from the early countries that we are in suggest that both of those things are true, and that’s what I look forward to over the next 10 years. If we can make it so more free basic services are available in a hundred or more countries and a billion or more people can get connected, then that is going to be a huge win for all of these people who will now have access to information on jobs and health care and education and communication tools that they just didn’t have before.\n	2015-02-19 00:00:00	2015-04-06 12:33:50.101
15	http://www.bloomberg.com/bw/articles/2014-01-22/nests-tony-fadell-keeps-his-cool-as-google-deal-brings-heat	nests tony fadell keeps his cool as google deal brings heat	Tony Fadell, the gadget king of Silicon Valley, was easy to miss in the media room at Munich’s DLD Conference earlier this week. The chief executive of Nest Labs sat perched by the window, quietly checking his phone as Arianna Huffington stood talking to a TV reporter nearby. As people milled about, looking for faces to meet, none approached the man who’d just sold his company to Google (GOOG) for $3.2 billion. One woman even asked an attendant when the “Nest guy” was due to speak, seemingly oblivious to the fact that he was seated a few feet away.\nLike his products, Fadell doesn’t come in a flashy package. But he’s become a more intimidating one since announcing the Google deal on Jan. 13. While his sale price sparked fresh interest in Nest’s two products—a thermostat that “learns” your preferences, and a Wi-Fi-enabled smoke and carbon monoxide alarm—Fadell’s choice of partner stoked fears. To critics, his sleek networked devices became powerful weapons for Google to track people in new ways and profit from those private details.\nFadell may not share those concerns but—in a world where government taps phone calls and Google uses search data to target ads—he understands them. He’s not in Munich to celebrate the Google acquisition. He’s here to sell it. That means talking to journalists and later going on stage to promise the tech crowd that Nest won’t alter its privacy policy without customers’ consent.\nDespite all the questions about privacy, Fadell hasn’t lost sight of what Google can give Nest: reach. Having led the team that designed the iPod (AAPL), he’s passionate about making beautiful, intuitive devices. But the only way to change the world, he says, is to connect them to a broader network. The goal isn’t just to save energy costs or have more comfortable, safe homes. It’s to have the technology fade into the background so it seamlessly integrates with your life and helps prompt smarter decisions. “You know the No. 1 reason a carbon monoxide alarm goes off?” asks Fadell. “The furnace isn’t working.” Ideally, that monitor could talk to the one controlling the furnace in such situations, and instruct it to turn off.\nThat’s what Fadell calls a smart home. “Just because something can be connected to the Internet doesn’t mean it should be,” he says. “Putting an iPad on the front of the fridge doesn’t do much, except to give you one more device to manage.”\nFadell doesn’t really care about your grocery list. He wants to help you make smarter decisions and live in a smarter environment. In short, he says, “we’re really trying to change the world.” That’s the kind of bold rallying cry you hear at Google. As they join forces in that quest, Fadell knows the biggest challenge is how you get there.\n	2014-01-22 00:00:00	2015-04-06 14:02:09.239
\.


--
-- Name: article_article_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testuser
--

SELECT pg_catalog.setval('article_article_id_seq', 15, true);


--
-- Data for Name: entity; Type: TABLE DATA; Schema: public; Owner: testuser
--

COPY entity (entity_id, entity_name, dbpedia_url, type) FROM stdin;
274	Nest	\N	Person
275	Dropcam	\N	Person
276	Google Inc.	http://dbpedia.org/resource/Google	Company
277	Nest Labs	http://dbpedia.org/resource/Nest_Labs	Company
278	Matt Rogers	http://dbpedia.org/resource/Matthew_Rogers	Person
279	Menlo Ventures	http://dbpedia.org/resource/Menlo_Ventures	Company
280	Dropcam Inc.	\N	Company
281	Palo Alto	http://dbpedia.org/resource/Palo_Alto,_California	City
282	Tony Fadell	http://dbpedia.org/resource/Tony_Fadell	Person
283	Mark Siegel	http://dbpedia.org/resource/Mark_Siegel	Person
284	Dropcam	\N	Company
285	mobile devices	\N	FieldTerminology
286	co-founder	\N	JobTitle
287	Bloomberg	\N	Company
288	The deal	\N	FieldTerminology
289	Accel Partners	http://dbpedia.org/resource/Accel_Partners	Company
290	Skybox Imaging Inc.	\N	Company
291	California	http://dbpedia.org/resource/California	StateOrCounty
292	Tam	\N	Person
293	Apple Inc.	http://dbpedia.org/resource/Apple_Inc.	Company
294	Reed Stevenson	\N	Person
295	Brian Womack	\N	Person
296	reporter	\N	JobTitle
297	Chief Operating Officer	\N	JobTitle
298	Greg Duffy	\N	Person
299	search engine	\N	FieldTerminology
300	Aamir Virani	\N	Person
301	San Francisco	\N	City
302	Internet access	\N	FieldTerminology
303	executive	\N	JobTitle
304	Chief Executive Officer	\N	JobTitle
305	managing director	\N	JobTitle
306	bwomack1@bloomberg.net	\N	EmailAddress
307	ptam13@bloomberg.net	\N	EmailAddress
308	$3.2 billion	\N	Quantity
309	$500 million	\N	Quantity
310	$555 million	\N	Quantity
311	$50 million	\N	Quantity
312	$8 million	\N	Quantity
313	Chief executive officer	http://dbpedia.org/resource/Chief_executive_officer	Concept
314	Executive officer	http://dbpedia.org/resource/Executive_officer	Concept
315	Mountain View, California	http://dbpedia.org/resource/Mountain_View,_California	Concept
316	Silicon Valley	http://dbpedia.org/resource/Silicon_Valley	Concept
317	Facebook	http://dbpedia.org/resource/Facebook	Concept
318	Yahoo!	http://dbpedia.org/resource/Yahoo!	Concept
319	Stanford University	http://dbpedia.org/resource/Stanford_University	Concept
320	Names of large numbers	http://dbpedia.org/resource/Names_of_large_numbers	Concept
321	Samsung	http://dbpedia.org/resource/Samsung	Company
322	Samsung Electronics Co.	http://dbpedia.org/resource/Samsung_Electronics	Company
323	Samsung Ventures	\N	Company
324	Atmel Corp.	http://dbpedia.org/resource/Atmel	Company
325	BlackBerry	\N	Product
326	Freescale	http://dbpedia.org/resource/Freescale_Semiconductor	Company
327	CM Research	\N	Company
328	Neil Shah	\N	Person
329	Counterpoint Research	\N	Company
330	Seoul	http://dbpedia.org/resource/Seoul	City
331	CM Research Ltd	\N	Company
332	research director	\N	JobTitle
333	Cyrus Mewawalla	\N	Person
334	BlackBerry Ltd.	\N	Company
335	Dan Baker	http://dbpedia.org/resource/Dan_Baker	Person
336	BlackBerry	\N	Technology
337	representative	\N	JobTitle
338	different devices	\N	FieldTerminology
339	IDC	http://dbpedia.org/resource/Interdnestrcom	Company
340	Current Analysis Inc	\N	Company
341	Freescale Semiconductor Ltd.	\N	Company
342	Michael Tighe	http://dbpedia.org/resource/Michael_Tighe	Person
343	consumer devices	\N	FieldTerminology
344	Park Hyun Je	\N	Facility
345	software platform	\N	FieldTerminology
346	mobile applications	\N	FieldTerminology
347	Qualcomm Inc.	http://dbpedia.org/resource/Qualcomm	Company
348	Reuters	http://dbpedia.org/resource/Reuters	Company
349	San Jose	http://dbpedia.org/resource/San_Jose,_California	City
350	Galaxy	\N	Technology
351	MOVL	\N	Organization
352	Hong Kong	http://dbpedia.org/resource/Hong_Kong	City
353	Israel	http://dbpedia.org/resource/Israel	Country
354	South Korea	http://dbpedia.org/resource/South_Korea	Country
355	Xiaomi	\N	City
356	technology stack	\N	FieldTerminology
357	Beth Williams	\N	Person
358	Jungah Lee	\N	Person
359	Avi Greengart	\N	Person
360	Austin	http://dbpedia.org/resource/Austin,_Texas	City
361	Shin Jong Kyun	\N	Person
362	Morningstar Inc.	\N	Company
363	Morningstar	\N	Company
364	Mumbai	\N	City
365	QNX	\N	OperatingSystem
366	Angus Whitley	\N	Person
367	venture capital firm	\N	FieldTerminology
368	Opera	http://dbpedia.org/resource/Opera_(web_browser)	Concept
369	Takeover	http://dbpedia.org/resource/Takeover	Concept
370	Computer software	http://dbpedia.org/resource/Computer_software	Concept
371	Research and development	http://dbpedia.org/resource/Research_and_development	Concept
372	Semiconductor companies	http://dbpedia.org/resource/Semiconductor_companies	Concept
373	Opera Software	http://dbpedia.org/resource/Opera_Software	Concept
374	SmartThings	\N	Company
375	Yoon Boo Keun	\N	Person
376	SmartThings Hub	\N	Technology
377	Alex Hawkinson	\N	Person
378	Consumer Electronics Show	\N	FieldTerminology
379	China	\N	Country
380	Chief Executive	\N	JobTitle
381	Sam Grobart	\N	Person
382	house—earlier	\N	Degree
383	solar panels	\N	FieldTerminology
384	partner	\N	JobTitle
385	walled garden	\N	FieldTerminology
386	Bloomberg Businessweek	\N	Company
387	CEO	\N	JobTitle
388	software company.	\N	FieldTerminology
389	100 million dollars	\N	Quantity
390	$100 million	\N	Quantity
391	10 percent	\N	Quantity
392	90 percent	\N	Quantity
393	two years	\N	Quantity
394	two-year	\N	Quantity
395	Samsung Group	http://dbpedia.org/resource/Samsung_Group	Concept
396	Samsung Town	http://dbpedia.org/resource/Samsung_Town	Concept
397	Sierra Wireless	http://dbpedia.org/resource/Sierra_Wireless	Company
398	Jason Cohenour	\N	Person
399	analyst	\N	JobTitle
400	Sierra Wireless Inc.	\N	Company
401	Anindya Ghose	http://dbpedia.org/resource/Anindya_Ghose	Person
402	Steven Li	\N	Person
403	Cisco Systems Inc.	http://dbpedia.org/resource/Cisco_Systems	Company
404	Toronto	http://dbpedia.org/resource/Toronto	City
405	Ubiquiti Networks Inc.	\N	Company
406	cellular networks	\N	FieldTerminology
407	wireless networks	\N	FieldTerminology
408	stock market	\N	FieldTerminology
409	Wavecom SA	http://dbpedia.org/resource/Wavecom	Company
410	ABI Research	http://dbpedia.org/resource/ABI_Research	Company
411	France	http://dbpedia.org/resource/France	Country
412	Richmond	http://dbpedia.org/resource/Richmond,_British_Columbia	City
413	New York	http://dbpedia.org/resource/New_York	StateOrCounty
414	New York University	http://dbpedia.org/resource/New_York_University	Organization
415	Telit Communications Plc	\N	Company
416	Gerrit De Vynck	\N	Person
417	Sarah Rabil	\N	Person
418	New Delhi	http://dbpedia.org/resource/New_Delhi	City
419	Oyster Bay	\N	GeographicFeature
420	Jacqueline Thorpe	\N	Person
421	IBM	http://dbpedia.org/resource/IBM	Company
422	Canaccord Genuity Inc.	\N	Company
423	Dan Shey	\N	Person
424	mobile payments	\N	FieldTerminology
425	British Columbia	\N	StateOrCounty
426	Michael Walkley	\N	Person
427	Karlskrona	\N	Company
428	General Electric Co.	http://dbpedia.org/resource/General_Electric	Company
429	Minneapolis	\N	City
430	Raymond James Financial Inc.	\N	Company
431	professor	\N	JobTitle
432	Gemalto NV	\N	Company
433	Cisco	\N	Company
434	gdevynck@bloomberg.net	\N	EmailAddress
435	srabil@bloomberg.net	\N	EmailAddress
436	$14.4 trillion	\N	Quantity
437	$1.26 billion	\N	Quantity
438	six quarters	\N	Quantity
439	$90 million	\N	Quantity
440	1.8 percent	\N	Quantity
441	Stock market	http://dbpedia.org/resource/Stock_market	Concept
442	Mobile phone	http://dbpedia.org/resource/Mobile_phone	Concept
443	Stock	http://dbpedia.org/resource/Stock	Concept
444	Revenue	http://dbpedia.org/resource/Revenue	Concept
445	Toshiba Corp.	\N	Company
446	Takeshi Oto	\N	Person
447	Ara	\N	Person
448	Tokyo	\N	City
449	Toshiba	http://dbpedia.org/resource/Toshiba	Company
450	Ara	\N	Company
451	iPhone	\N	Technology
452	Bloomberg Intelligence	\N	Company
453	Sony Corp.	http://dbpedia.org/resource/Sony	Company
454	iFixit	http://dbpedia.org/resource/IFixit	Company
455	senior fellow	\N	JobTitle
456	Pavel Alpeyev	\N	Person
457	John Butler	\N	Person
458	Dave McCombs	\N	Person
459	Fujitsu Ltd.	http://dbpedia.org/resource/Fujitsu	Company
460	Matthew Kanterman	\N	Person
461	Takashi Amano	\N	Person
462	Puerto Rico	\N	City
463	form factor	\N	FieldTerminology
464	mobile phone	\N	FieldTerminology
465	nuclear power	\N	FieldTerminology
466	food chain	\N	FieldTerminology
467	notebook computers	\N	FieldTerminology
468	palpeyev@bloomberg.net	\N	EmailAddress
469	mtighe4@bloomberg.net	\N	EmailAddress
470	tamano6@bloomberg.net	\N	EmailAddress
471	80 percent	\N	Quantity
472	Flash memory	http://dbpedia.org/resource/Flash_memory	Concept
473	IPhone	http://dbpedia.org/resource/IPhone	Concept
474	Laptop	http://dbpedia.org/resource/Laptop	Concept
475	App Store	http://dbpedia.org/resource/App_Store	Concept
476	Takashi Amano	http://dbpedia.org/resource/Takashi_Amano	Concept
477	Pentaho Corp.	\N	Company
478	Hitachi Data Systems	http://dbpedia.org/resource/Hitachi_Data_Systems	Company
479	Hitachi Ltd.	http://dbpedia.org/resource/Hitachi	Company
480	Pentaho	http://dbpedia.org/resource/Pentaho	Company
481	data processing	\N	FieldTerminology
482	Kevin Eggleston	\N	Person
483	the deal	\N	FieldTerminology
484	DAG Ventures	\N	Company
485	Index Ventures	http://dbpedia.org/resource/Index_Ventures	Company
486	Revolution Analytics	http://dbpedia.org/resource/Revolution_Analytics	Company
487	Joseph Beare	\N	Person
488	New Enterprise Associates	http://dbpedia.org/resource/New_Enterprise_Associates	Company
489	Microsoft Corp.	http://dbpedia.org/resource/Microsoft	Company
490	Salesforce.com Inc.	\N	Company
491	Katie Watson	\N	Person
492	senior vice president	\N	JobTitle
493	Jack Clark	\N	Person
494	Florida	http://dbpedia.org/resource/Florida	StateOrCounty
495	Orlando	http://dbpedia.org/resource/Orlando,_Florida	City
496	open-source software	\N	FieldTerminology
497	John Lear	\N	Person
498	Global Industries	\N	Company
499	jclark185@bloomberg.net	\N	EmailAddress
500	$400 million	\N	Quantity
501	$600 million	\N	Quantity
502	$60 million	\N	Quantity
503	Hitachi Ltd.	http://dbpedia.org/resource/Hitachi_Ltd.	Concept
504	Data	http://dbpedia.org/resource/Data	Concept
505	Venture capital	http://dbpedia.org/resource/Venture_capital	Concept
506	Vice President of the United States	http://dbpedia.org/resource/Vice_President_of_the_United_States	Concept
507	Business intelligence	http://dbpedia.org/resource/Business_intelligence	Concept
508	Venture capital firms	http://dbpedia.org/resource/Venture_capital_firms	Concept
509	Data analysis	http://dbpedia.org/resource/Data_analysis	Concept
510	Zambia	http://dbpedia.org/resource/Zambia	Country
511	communication tools	\N	FieldTerminology
512	U.S.	http://dbpedia.org/resource/United_States	Country
513	Mark Zuckerberg	http://dbpedia.org/resource/Mark_Zuckerberg	Person
514	Emily Chang	http://dbpedia.org/resource/Emily_Chang_(journalist)	Person
515	Southeast Asia	http://dbpedia.org/resource/Southeast_Asia	Region
516	Bloomberg Television	\N	Company
517	Airtel	http://dbpedia.org/resource/Bharti_Airtel	Company
518	Project Loon	\N	GeographicFeature
519	India	http://dbpedia.org/resource/India	Country
520	technology needs	\N	FieldTerminology
521	Indonesia	http://dbpedia.org/resource/Indonesia	Country
522	different tools	\N	FieldTerminology
523	Bill Gates	http://dbpedia.org/resource/Bill_Gates	Person
524	Android	\N	OperatingSystem
525	faster networks	\N	FieldTerminology
526	Ebola	\N	HealthCondition
527	Wikipedia	\N	Company
528	health services	\N	FieldTerminology
529	technology companies	\N	FieldTerminology
530	search product	\N	FieldTerminology
531	NASA Jet Propulsion	\N	Company
532	Europe	http://dbpedia.org/resource/Europe	Continent
533	Philippines	\N	Country
534	Asia	http://dbpedia.org/resource/Asia	Continent
535	government services	\N	FieldTerminology
536	10 years	\N	Quantity
537	15 percent	\N	Quantity
538	20 percent	\N	Quantity
539	1 percent	\N	Quantity
540	30 years	\N	Quantity
541	30-year	\N	Quantity
542	Internet	http://dbpedia.org/resource/Internet	Concept
543	MySpace	http://dbpedia.org/resource/MySpace	Concept
544	History of the Internet	http://dbpedia.org/resource/History_of_the_Internet	Concept
545	Social network service	http://dbpedia.org/resource/Social_network_service	Concept
546	Instant messaging	http://dbpedia.org/resource/Instant_messaging	Concept
547	carbon monoxide	\N	FieldTerminology
548	Munich	\N	City
549	Arianna Huffington	http://dbpedia.org/resource/Arianna_Huffington	Person
550	chief executive	\N	JobTitle
551	iPod	\N	Technology
552	energy costs	\N	FieldTerminology
553	Carbon monoxide	http://dbpedia.org/resource/Carbon_monoxide	Concept
554	Google search	http://dbpedia.org/resource/Google_search	Concept
555	PageRank	http://dbpedia.org/resource/PageRank	Concept
\.


--
-- Data for Name: entity_article; Type: TABLE DATA; Schema: public; Owner: testuser
--

COPY entity_article (article_id, entity_id, relevance, count, text) FROM stdin;
8	274	0.840655	11	Nest
8	275	0.362548	7	Dropcam
8	276	0.356966	6	Google Inc.
8	277	0.311734	1	Nest Labs
8	278	0.311671	5	Matt Rogers
8	279	0.244707	3	Menlo Ventures
8	280	0.207606	2	Dropcam Inc.
8	281	0.205236	2	Palo Alto
8	282	0.193991	3	Tony Fadell
8	283	0.193497	2	Mark Siegel
8	284	0.182780	1	Dropcam
8	285	0.165915	1	mobile devices
8	286	0.165166	2	co-founder
8	287	0.162079	1	Bloomberg
8	288	0.158197	2	The deal
8	289	0.156117	1	Accel Partners
8	290	0.154897	1	Skybox Imaging Inc.
8	291	0.153762	1	California
8	292	0.145870	1	Tam
8	293	0.144483	1	Apple Inc.
8	294	0.144310	1	Reed Stevenson
8	295	0.142923	1	Brian Womack
8	296	0.142080	1	reporter
8	297	0.142028	1	Chief Operating Officer
8	298	0.141308	2	Greg Duffy
8	299	0.140762	1	search engine
8	300	0.139836	1	Aamir Virani
8	301	0.137814	1	San Francisco
8	302	0.136853	1	Internet access
8	303	0.136445	1	executive
8	304	0.131858	1	Chief Executive Officer
8	305	0.129208	1	managing director
8	306	0.129208	1	bwomack1@bloomberg.net
8	307	0.129208	1	ptam13@bloomberg.net
8	308	0.129208	1	$3.2 billion
8	309	0.129208	1	$500 million
8	310	0.129208	1	$555 million
8	311	0.129208	1	$50 million
8	312	0.129208	1	$8 million
8	313	0.912550	1	Chief executive officer
8	314	0.840277	1	Executive officer
8	315	0.784214	1	Mountain View, California
8	316	0.743894	1	Silicon Valley
8	317	0.691181	1	Facebook
8	318	0.689852	1	Yahoo!
8	319	0.679790	1	Stanford University
8	320	0.643440	1	Names of large numbers
9	321	0.888735	22	Samsung
9	322	0.319055	1	Samsung Electronics Co.
9	323	0.268583	1	Samsung Ventures
9	324	0.227703	5	Atmel Corp.
9	325	0.225598	3	BlackBerry
9	326	0.209064	3	Freescale
9	327	0.176281	3	CM Research
9	328	0.173182	3	Neil Shah
9	329	0.167378	2	Counterpoint Research
9	330	0.161088	2	Seoul
9	331	0.159829	1	CM Research Ltd
9	332	0.157877	2	research director
9	333	0.155897	3	Cyrus Mewawalla
9	287	0.155340	1	Bloomberg
9	334	0.152223	1	BlackBerry Ltd.
9	335	0.149387	2	Dan Baker
9	336	0.145938	2	BlackBerry
9	337	0.145201	2	representative
9	338	0.143863	1	different devices
9	339	0.143260	1	IDC
9	340	0.141864	1	Current Analysis Inc
9	341	0.137442	1	Freescale Semiconductor Ltd.
9	342	0.132077	1	Michael Tighe
9	343	0.131843	1	consumer devices
9	344	0.128583	1	Park Hyun Je
9	345	0.128032	1	software platform
9	346	0.127010	1	mobile applications
9	347	0.127002	1	Qualcomm Inc.
9	348	0.126861	1	Reuters
9	305	0.125781	1	managing director
9	349	0.124988	1	San Jose
9	350	0.124678	1	Galaxy
9	351	0.124361	1	MOVL
9	352	0.123251	1	Hong Kong
9	353	0.123228	1	Israel
9	354	0.121295	1	South Korea
9	355	0.120967	1	Xiaomi
9	356	0.120922	1	technology stack
9	293	0.120387	1	Apple Inc.
9	357	0.120149	2	Beth Williams
9	358	0.120059	1	Jungah Lee
9	359	0.119441	2	Avi Greengart
9	360	0.118046	1	Austin
9	361	0.117835	1	Shin Jong Kyun
9	362	0.117595	1	Morningstar Inc.
9	363	0.116933	1	Morningstar
9	364	0.116539	1	Mumbai
9	365	0.116538	1	QNX
9	366	0.115482	1	Angus Whitley
9	367	0.115011	1	venture capital firm
9	368	0.940793	1	Opera
9	369	0.936700	1	Takeover
9	370	0.926793	1	Computer software
9	371	0.780257	1	Research and development
9	372	0.761838	1	Semiconductor companies
9	373	0.722538	1	Opera Software
10	321	0.941659	20	Samsung
10	322	0.375216	1	Samsung Electronics
10	374	0.276268	7	SmartThings
10	375	0.253472	4	Yoon Boo Keun
10	276	0.186841	2	Google
10	285	0.185134	1	mobile devices
10	376	0.179047	1	SmartThings Hub
10	377	0.179029	2	Alex Hawkinson
10	378	0.177392	1	Consumer Electronics Show
10	330	0.150875	1	Seoul
10	379	0.138235	1	China
10	380	0.135525	1	Chief Executive
10	381	0.135320	1	Sam Grobart
10	382	0.134586	1	house—earlier
10	383	0.134482	1	solar panels
10	384	0.133568	1	partner
10	385	0.132885	1	walled garden
10	386	0.126905	1	Bloomberg Businessweek
10	387	0.123411	1	CEO
10	388	0.121308	1	software company.
10	389	0.121308	1	100 million dollars
10	390	0.121308	1	$100 million
10	391	0.121308	1	10 percent
10	392	0.121308	1	90 percent
10	393	0.121308	1	two years
10	394	0.121308	1	two-year
10	395	0.904400	1	Samsung Group
10	396	0.861840	1	Samsung Town
11	397	0.855750	7	Sierra Wireless
11	398	0.451142	4	Jason Cohenour
11	399	0.436644	5	analyst
11	287	0.370092	3	Bloomberg
11	400	0.329424	1	Sierra Wireless Inc.
11	401	0.287379	2	Anindya Ghose
11	402	0.284203	3	Steven Li
11	387	0.259708	2	CEO
11	403	0.258492	2	Cisco Systems Inc.
11	404	0.252905	2	Toronto
11	405	0.246422	1	Ubiquiti Networks Inc.
11	406	0.243216	1	cellular networks
11	407	0.239642	1	wireless networks
11	408	0.236771	1	stock market
11	409	0.230752	1	Wavecom SA
11	410	0.222122	1	ABI Research
11	411	0.213536	1	France
11	304	0.209700	1	Chief Executive Officer
11	412	0.208400	1	Richmond
11	413	0.207145	1	New York
11	414	0.206791	1	New York University
11	415	0.203295	1	Telit Communications Plc
11	416	0.202630	1	Gerrit De Vynck
11	417	0.202598	1	Sarah Rabil
11	418	0.202530	1	New Delhi
11	419	0.202052	1	Oyster Bay
11	420	0.196862	1	Jacqueline Thorpe
11	421	0.196477	1	IBM
11	422	0.195430	1	Canaccord Genuity Inc.
11	423	0.194027	1	Dan Shey
11	424	0.193919	1	mobile payments
11	296	0.193202	1	reporter
11	425	0.191423	1	British Columbia
11	426	0.189543	1	Michael Walkley
11	427	0.184354	1	Karlskrona
11	428	0.184284	1	General Electric Co.
11	429	0.179818	1	Minneapolis
11	334	0.179313	1	BlackBerry Ltd.
11	430	0.178873	1	Raymond James Financial Inc.
11	431	0.178007	1	professor
11	432	0.177994	1	Gemalto NV
11	433	0.177761	1	Cisco
11	434	0.177761	1	gdevynck@bloomberg.net
11	435	0.177761	1	srabil@bloomberg.net
11	436	0.177761	1	$14.4 trillion
11	437	0.177761	1	$1.26 billion
11	438	0.177761	1	six quarters
11	311	0.177761	1	$50 million
11	439	0.177761	1	$90 million
11	440	0.177761	1	1.8 percent
11	441	0.947238	1	Stock market
11	442	0.802511	1	Mobile phone
11	443	0.625031	1	Stock
11	313	0.610432	1	Chief executive officer
11	444	0.579535	1	Revenue
11	320	0.543809	1	Names of large numbers
12	445	0.948826	8	Toshiba Corp.
12	446	0.580056	5	Takeshi Oto
12	293	0.421169	4	Apple Inc.
12	276	0.391774	4	Google Inc.
12	447	0.365486	4	Ara
12	448	0.358014	4	Tokyo
12	449	0.344092	1	Toshiba
12	450	0.301476	1	Ara
12	451	0.276698	2	iPhone
12	452	0.239334	1	Bloomberg Intelligence
12	287	0.238916	1	Bloomberg
12	322	0.236293	1	Samsung Electronics Co.
12	342	0.225954	1	Michael Tighe
12	453	0.218219	1	Sony Corp.
12	321	0.217614	1	Samsung
12	454	0.209185	1	iFixit
12	455	0.204932	1	senior fellow
12	456	0.203724	1	Pavel Alpeyev
12	457	0.202307	1	John Butler
12	458	0.200776	1	Dave McCombs
12	459	0.200479	1	Fujitsu Ltd.
12	460	0.200294	1	Matthew Kanterman
12	461	0.200082	1	Takashi Amano
12	462	0.190508	1	Puerto Rico
12	463	0.188110	1	form factor
12	464	0.180965	1	mobile phone
12	465	0.175982	1	nuclear power
12	466	0.172602	1	food chain
12	467	0.159193	1	notebook computers
12	468	0.159193	1	palpeyev@bloomberg.net
12	469	0.159193	1	mtighe4@bloomberg.net
12	470	0.159193	1	tamano6@bloomberg.net
12	471	0.159193	1	80 percent
12	394	0.159193	1	two-year
12	472	0.973848	1	Flash memory
12	473	0.915378	1	IPhone
12	442	0.640223	1	Mobile phone
12	474	0.561417	1	Laptop
12	475	0.503076	1	App Store
12	476	0.479293	1	Takashi Amano
13	477	0.951138	7	Pentaho Corp.
13	478	0.701994	3	Hitachi Data Systems
13	479	0.501854	3	Hitachi Ltd.
13	480	0.340124	1	Pentaho
13	481	0.282726	1	data processing
13	482	0.244899	2	Kevin Eggleston
13	287	0.240397	2	Bloomberg
13	483	0.201794	2	the deal
13	484	0.183357	1	DAG Ventures
13	485	0.179714	1	Index Ventures
13	486	0.178394	1	Revolution Analytics
13	487	0.172119	1	Joseph Beare
13	488	0.171001	1	New Enterprise Associates
13	489	0.167233	1	Microsoft Corp.
13	490	0.164857	1	Salesforce.com Inc.
13	491	0.160477	1	Katie Watson
13	492	0.159713	1	senior vice president
13	292	0.157791	1	Tam
13	493	0.156850	1	Jack Clark
13	296	0.156192	1	reporter
13	294	0.154370	1	Reed Stevenson
13	494	0.153164	1	Florida
13	495	0.152465	1	Orlando
13	496	0.152400	1	open-source software
13	301	0.148294	1	San Francisco
13	497	0.140503	1	John Lear
13	498	0.137237	1	Global Industries
13	499	0.137237	1	jclark185@bloomberg.net
13	307	0.137237	1	ptam13@bloomberg.net
13	500	0.137237	1	$400 million
13	309	0.137237	1	$500 million
13	501	0.137237	1	$600 million
13	502	0.137237	1	$60 million
13	503	0.938227	1	Hitachi Ltd.
13	504	0.888391	1	Data
13	505	0.768952	1	Venture capital
13	506	0.721974	1	Vice President of the United States
13	507	0.705760	1	Business intelligence
13	508	0.682256	1	Venture capital firms
13	509	0.682004	1	Data analysis
14	317	0.855653	15	Facebook
14	510	0.398207	4	Zambia
14	276	0.379976	9	Google
14	384	0.326073	4	partner
14	511	0.320380	3	communication tools
14	512	0.284131	2	U.S.
14	513	0.279061	2	Mark Zuckerberg
14	514	0.276951	1	Emily Chang
14	515	0.276292	1	Southeast Asia
14	516	0.263931	1	Bloomberg Television
14	517	0.263037	3	Airtel
14	518	0.262362	2	Project Loon
14	519	0.262004	1	India
14	379	0.258755	3	China
14	520	0.246069	1	technology needs
14	304	0.246022	1	Chief Executive Officer
14	521	0.244604	1	Indonesia
14	522	0.242832	1	different tools
14	523	0.233735	2	Bill Gates
14	524	0.231583	1	Android
14	525	0.226671	1	faster networks
14	526	0.226489	2	Ebola
14	527	0.225030	1	Wikipedia
14	528	0.218161	1	health services
14	529	0.217744	1	technology companies
14	530	0.212926	1	search product
14	531	0.210547	1	NASA Jet Propulsion
14	532	0.210047	1	Europe
14	533	0.207426	1	Philippines
14	534	0.201879	1	Asia
14	535	0.188753	1	government services
14	536	0.188753	2	10 years
14	537	0.188753	1	15 percent
14	538	0.188753	1	20 percent
14	539	0.188753	1	1 percent
14	540	0.188753	1	30 years
14	541	0.188753	1	30-year
14	542	0.963444	1	Internet
14	543	0.769106	1	MySpace
14	544	0.702393	1	History of the Internet
14	545	0.681916	1	Social network service
14	546	0.626878	1	Instant messaging
14	319	0.624930	1	Stanford University
15	282	0.885404	17	Tony Fadell
15	276	0.756968	7	Google
15	274	0.444380	3	Nest
15	277	0.377566	1	Nest Labs
15	547	0.337825	2	carbon monoxide
15	548	0.326156	2	Munich
15	549	0.312891	1	Arianna Huffington
15	550	0.268906	1	chief executive
15	296	0.249222	1	reporter
15	551	0.240750	1	iPod
15	552	0.231999	1	energy costs
15	384	0.220838	1	partner
15	308	0.220838	1	$3.2 billion
15	316	0.557398	1	Silicon Valley
15	553	0.520318	1	Carbon monoxide
15	554	0.509837	1	Google search
15	555	0.485800	1	PageRank
15	293	0.481260	1	Apple Inc.
\.


--
-- Name: entity_entity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testuser
--

SELECT pg_catalog.setval('entity_entity_id_seq', 555, true);


--
-- Data for Name: play_evolutions; Type: TABLE DATA; Schema: public; Owner: testuser
--

COPY play_evolutions (id, hash, applied_at, apply_script, revert_script, state, last_problem) FROM stdin;
1	14bf6e27c72dda1ba9a62a1d8f8c0d55a35fa9f3	2015-04-01 00:00:00	CREATE TABLE article (\narticle_id bigserial primary key,\narticle_url varchar(200) NOT NULL,\narticle_title varchar(100) NOT NULL,\narticle_text text NOT NULL,\narticle_date timestamp default NULL,\ndate_added timestamp default NULL\n);\n\nCREATE TABLE request (\nrequest_id bigserial primary key,\narticle_id BIGINT NOT NULL REFERENCES article (article_id),\nrequest_text_surroundings text NOT NULL,\nrequest_text text NOT NULL,\ndate_asked timestamp default NULL\n);\n\nCREATE TABLE annotation (\nannotation_id bigserial primary key,\nrequest_id BIGINT NOT NULL REFERENCES request (request_id),\narticle_id BIGINT NOT NULL REFERENCES article (article_id),\nannotation_answer text NULL,\ndate_answered timestamp default NULL,\nvotes INT DEFAULT 0\n);	DROP TABLE annotation;\nDROP TABLE request;\nDROP TABLE article;	applied	
2	52a8c90cfbd1aeefb966a09dd7b448e27309b159	2015-04-01 00:00:00	CREATE TABLE entity (\nentity_id bigserial primary key,\nentity_name VARCHAR(100) NOT NULL,\ndbpedia_url varchar(200) NULL,\ntype varchar(100) DEFAULT NULL,\nUNIQUE(entity_name,type)\n);\n\nCREATE TABLE entity_article (\narticle_id BIGINT NOT NULL REFERENCES article (article_id),\nentity_id BIGINT NOT NULL REFERENCES entity (entity_id),\nrelevance DECIMAL(7,6),\ncount INT DEFAULT 1,\ntext VARCHAR(100),\nPRIMARY KEY( article_id, entity_id)\n);	DROP TABLE entity_article;\nDROP TABLE entity;	applied	
3	115db53eeafe4e7cb481b20d0de70a35c66b32fc	2015-04-01 00:00:00	ALTER TABLE annotation ADD COLUMN refs TEXT default NULL;	ALTER TABLE annotation DROP COLUMN refs;	applied	
\.


--
-- Data for Name: request; Type: TABLE DATA; Schema: public; Owner: testuser
--

COPY request (request_id, article_id, request_text_surroundings, request_text, date_asked) FROM stdin;
20	8	The purchase underlines how Nest, which Google bought for\nabout $3.2 billion earlier this year, is working to become a\nbigger player of connected devices for consumers. The trend is\npart of a technology movement dubbed the “Internet of things,”\nwhere more gadgets and everyday items are connected to the Web\nand can deliver data and be controlled by mobile devices. 	Internet of things	2015-04-06 12:37:15.071
\.


--
-- Name: request_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: testuser
--

SELECT pg_catalog.setval('request_request_id_seq', 22, true);


--
-- Name: annotation_pkey; Type: CONSTRAINT; Schema: public; Owner: testuser; Tablespace: 
--

ALTER TABLE ONLY annotation
    ADD CONSTRAINT annotation_pkey PRIMARY KEY (annotation_id);


--
-- Name: article_pkey; Type: CONSTRAINT; Schema: public; Owner: testuser; Tablespace: 
--

ALTER TABLE ONLY article
    ADD CONSTRAINT article_pkey PRIMARY KEY (article_id);


--
-- Name: entity_article_pkey; Type: CONSTRAINT; Schema: public; Owner: testuser; Tablespace: 
--

ALTER TABLE ONLY entity_article
    ADD CONSTRAINT entity_article_pkey PRIMARY KEY (article_id, entity_id);


--
-- Name: entity_entity_name_type_key; Type: CONSTRAINT; Schema: public; Owner: testuser; Tablespace: 
--

ALTER TABLE ONLY entity
    ADD CONSTRAINT entity_entity_name_type_key UNIQUE (entity_name, type);


--
-- Name: entity_pkey; Type: CONSTRAINT; Schema: public; Owner: testuser; Tablespace: 
--

ALTER TABLE ONLY entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (entity_id);


--
-- Name: play_evolutions_pkey; Type: CONSTRAINT; Schema: public; Owner: testuser; Tablespace: 
--

ALTER TABLE ONLY play_evolutions
    ADD CONSTRAINT play_evolutions_pkey PRIMARY KEY (id);


--
-- Name: request_pkey; Type: CONSTRAINT; Schema: public; Owner: testuser; Tablespace: 
--

ALTER TABLE ONLY request
    ADD CONSTRAINT request_pkey PRIMARY KEY (request_id);


--
-- Name: annotation_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY annotation
    ADD CONSTRAINT annotation_article_id_fkey FOREIGN KEY (article_id) REFERENCES article(article_id);


--
-- Name: annotation_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY annotation
    ADD CONSTRAINT annotation_request_id_fkey FOREIGN KEY (request_id) REFERENCES request(request_id);


--
-- Name: entity_article_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY entity_article
    ADD CONSTRAINT entity_article_article_id_fkey FOREIGN KEY (article_id) REFERENCES article(article_id);


--
-- Name: entity_article_entity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY entity_article
    ADD CONSTRAINT entity_article_entity_id_fkey FOREIGN KEY (entity_id) REFERENCES entity(entity_id);


--
-- Name: request_article_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: testuser
--

ALTER TABLE ONLY request
    ADD CONSTRAINT request_article_id_fkey FOREIGN KEY (article_id) REFERENCES article(article_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: korsvanloon
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM korsvanloon;
GRANT ALL ON SCHEMA public TO korsvanloon;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

