CREATE SCHEMA gitlab_partitions_dynamic;

COMMENT ON SCHEMA gitlab_partitions_dynamic IS 'Schema to hold partitions managed dynamically from the application, e.g. for time space partitioning.';

CREATE SCHEMA gitlab_partitions_static;

COMMENT ON SCHEMA gitlab_partitions_static IS 'Schema to hold static partitions, e.g. for hash partitioning';

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE FUNCTION table_sync_function_2be879775d() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF (TG_OP = 'DELETE') THEN
  DELETE FROM audit_events_part_5fc467ac26 where id = OLD.id;
ELSIF (TG_OP = 'UPDATE') THEN
  UPDATE audit_events_part_5fc467ac26
  SET author_id = NEW.author_id,
    entity_id = NEW.entity_id,
    entity_type = NEW.entity_type,
    details = NEW.details,
    ip_address = NEW.ip_address,
    author_name = NEW.author_name,
    entity_path = NEW.entity_path,
    target_details = NEW.target_details,
    target_type = NEW.target_type,
    target_id = NEW.target_id,
    created_at = NEW.created_at
  WHERE audit_events_part_5fc467ac26.id = NEW.id;
ELSIF (TG_OP = 'INSERT') THEN
  INSERT INTO audit_events_part_5fc467ac26 (id,
    author_id,
    entity_id,
    entity_type,
    details,
    ip_address,
    author_name,
    entity_path,
    target_details,
    target_type,
    target_id,
    created_at)
  VALUES (NEW.id,
    NEW.author_id,
    NEW.entity_id,
    NEW.entity_type,
    NEW.details,
    NEW.ip_address,
    NEW.author_name,
    NEW.entity_path,
    NEW.target_details,
    NEW.target_type,
    NEW.target_id,
    NEW.created_at);
END IF;
RETURN NULL;

END
$$;

COMMENT ON FUNCTION table_sync_function_2be879775d() IS 'Partitioning migration: table sync for audit_events table';

CREATE TABLE audit_events_part_5fc467ac26 (
    id bigint NOT NULL,
    author_id integer NOT NULL,
    entity_id integer NOT NULL,
    entity_type character varying NOT NULL,
    details text,
    ip_address inet,
    author_name text,
    entity_path text,
    target_details text,
    created_at timestamp without time zone NOT NULL,
    target_type text,
    target_id bigint,
    CONSTRAINT check_492aaa021d CHECK ((char_length(entity_path) <= 5500)),
    CONSTRAINT check_83ff8406e2 CHECK ((char_length(author_name) <= 255)),
    CONSTRAINT check_97a8c868e7 CHECK ((char_length(target_type) <= 255)),
    CONSTRAINT check_d493ec90b5 CHECK ((char_length(target_details) <= 5500))
)
PARTITION BY RANGE (created_at);

CREATE TABLE product_analytics_events_experimental (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
)
PARTITION BY HASH (project_id);

CREATE SEQUENCE product_analytics_events_experimental_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE product_analytics_events_experimental_id_seq OWNED BY product_analytics_events_experimental.id;

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_00 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_00 FOR VALUES WITH (modulus 64, remainder 0);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_01 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_01 FOR VALUES WITH (modulus 64, remainder 1);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_02 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_02 FOR VALUES WITH (modulus 64, remainder 2);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_03 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_03 FOR VALUES WITH (modulus 64, remainder 3);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_04 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_04 FOR VALUES WITH (modulus 64, remainder 4);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_05 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_05 FOR VALUES WITH (modulus 64, remainder 5);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_06 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_06 FOR VALUES WITH (modulus 64, remainder 6);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_07 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_07 FOR VALUES WITH (modulus 64, remainder 7);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_08 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_08 FOR VALUES WITH (modulus 64, remainder 8);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_09 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_09 FOR VALUES WITH (modulus 64, remainder 9);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_10 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_10 FOR VALUES WITH (modulus 64, remainder 10);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_11 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_11 FOR VALUES WITH (modulus 64, remainder 11);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_12 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_12 FOR VALUES WITH (modulus 64, remainder 12);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_13 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_13 FOR VALUES WITH (modulus 64, remainder 13);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_14 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_14 FOR VALUES WITH (modulus 64, remainder 14);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_15 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_15 FOR VALUES WITH (modulus 64, remainder 15);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_16 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_16 FOR VALUES WITH (modulus 64, remainder 16);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_17 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_17 FOR VALUES WITH (modulus 64, remainder 17);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_18 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_18 FOR VALUES WITH (modulus 64, remainder 18);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_19 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_19 FOR VALUES WITH (modulus 64, remainder 19);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_20 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_20 FOR VALUES WITH (modulus 64, remainder 20);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_21 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_21 FOR VALUES WITH (modulus 64, remainder 21);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_22 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_22 FOR VALUES WITH (modulus 64, remainder 22);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_23 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_23 FOR VALUES WITH (modulus 64, remainder 23);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_24 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_24 FOR VALUES WITH (modulus 64, remainder 24);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_25 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_25 FOR VALUES WITH (modulus 64, remainder 25);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_26 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_26 FOR VALUES WITH (modulus 64, remainder 26);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_27 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_27 FOR VALUES WITH (modulus 64, remainder 27);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_28 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_28 FOR VALUES WITH (modulus 64, remainder 28);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_29 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_29 FOR VALUES WITH (modulus 64, remainder 29);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_30 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_30 FOR VALUES WITH (modulus 64, remainder 30);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_31 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_31 FOR VALUES WITH (modulus 64, remainder 31);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_32 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_32 FOR VALUES WITH (modulus 64, remainder 32);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_33 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_33 FOR VALUES WITH (modulus 64, remainder 33);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_34 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_34 FOR VALUES WITH (modulus 64, remainder 34);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_35 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_35 FOR VALUES WITH (modulus 64, remainder 35);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_36 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_36 FOR VALUES WITH (modulus 64, remainder 36);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_37 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_37 FOR VALUES WITH (modulus 64, remainder 37);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_38 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_38 FOR VALUES WITH (modulus 64, remainder 38);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_39 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_39 FOR VALUES WITH (modulus 64, remainder 39);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_40 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_40 FOR VALUES WITH (modulus 64, remainder 40);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_41 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_41 FOR VALUES WITH (modulus 64, remainder 41);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_42 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_42 FOR VALUES WITH (modulus 64, remainder 42);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_43 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_43 FOR VALUES WITH (modulus 64, remainder 43);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_44 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_44 FOR VALUES WITH (modulus 64, remainder 44);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_45 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_45 FOR VALUES WITH (modulus 64, remainder 45);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_46 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_46 FOR VALUES WITH (modulus 64, remainder 46);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_47 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_47 FOR VALUES WITH (modulus 64, remainder 47);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_48 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_48 FOR VALUES WITH (modulus 64, remainder 48);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_49 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_49 FOR VALUES WITH (modulus 64, remainder 49);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_50 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_50 FOR VALUES WITH (modulus 64, remainder 50);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_51 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_51 FOR VALUES WITH (modulus 64, remainder 51);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_52 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_52 FOR VALUES WITH (modulus 64, remainder 52);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_53 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_53 FOR VALUES WITH (modulus 64, remainder 53);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_54 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_54 FOR VALUES WITH (modulus 64, remainder 54);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_55 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_55 FOR VALUES WITH (modulus 64, remainder 55);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_56 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_56 FOR VALUES WITH (modulus 64, remainder 56);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_57 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_57 FOR VALUES WITH (modulus 64, remainder 57);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_58 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_58 FOR VALUES WITH (modulus 64, remainder 58);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_59 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_59 FOR VALUES WITH (modulus 64, remainder 59);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_60 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_60 FOR VALUES WITH (modulus 64, remainder 60);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_61 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_61 FOR VALUES WITH (modulus 64, remainder 61);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_62 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_62 FOR VALUES WITH (modulus 64, remainder 62);

CREATE TABLE gitlab_partitions_static.product_analytics_events_experimental_63 (
    id bigint DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass) NOT NULL,
    project_id integer NOT NULL,
    platform character varying(255),
    etl_tstamp timestamp with time zone,
    collector_tstamp timestamp with time zone NOT NULL,
    dvce_created_tstamp timestamp with time zone,
    event character varying(128),
    event_id character(36) NOT NULL,
    txn_id integer,
    name_tracker character varying(128),
    v_tracker character varying(100),
    v_collector character varying(100) NOT NULL,
    v_etl character varying(100) NOT NULL,
    user_id character varying(255),
    user_ipaddress character varying(45),
    user_fingerprint character varying(50),
    domain_userid character varying(36),
    domain_sessionidx smallint,
    network_userid character varying(38),
    geo_country character(2),
    geo_region character(3),
    geo_city character varying(75),
    geo_zipcode character varying(15),
    geo_latitude double precision,
    geo_longitude double precision,
    geo_region_name character varying(100),
    ip_isp character varying(100),
    ip_organization character varying(100),
    ip_domain character varying(100),
    ip_netspeed character varying(100),
    page_url text,
    page_title character varying(2000),
    page_referrer text,
    page_urlscheme character varying(16),
    page_urlhost character varying(255),
    page_urlport integer,
    page_urlpath character varying(3000),
    page_urlquery character varying(6000),
    page_urlfragment character varying(3000),
    refr_urlscheme character varying(16),
    refr_urlhost character varying(255),
    refr_urlport integer,
    refr_urlpath character varying(6000),
    refr_urlquery character varying(6000),
    refr_urlfragment character varying(3000),
    refr_medium character varying(25),
    refr_source character varying(50),
    refr_term character varying(255),
    mkt_medium character varying(255),
    mkt_source character varying(255),
    mkt_term character varying(255),
    mkt_content character varying(500),
    mkt_campaign character varying(255),
    se_category character varying(1000),
    se_action character varying(1000),
    se_label character varying(1000),
    se_property character varying(1000),
    se_value double precision,
    tr_orderid character varying(255),
    tr_affiliation character varying(255),
    tr_total numeric(18,2),
    tr_tax numeric(18,2),
    tr_shipping numeric(18,2),
    tr_city character varying(255),
    tr_state character varying(255),
    tr_country character varying(255),
    ti_orderid character varying(255),
    ti_sku character varying(255),
    ti_name character varying(255),
    ti_category character varying(255),
    ti_price numeric(18,2),
    ti_quantity integer,
    pp_xoffset_min integer,
    pp_xoffset_max integer,
    pp_yoffset_min integer,
    pp_yoffset_max integer,
    useragent character varying(1000),
    br_name character varying(50),
    br_family character varying(50),
    br_version character varying(50),
    br_type character varying(50),
    br_renderengine character varying(50),
    br_lang character varying(255),
    br_features_pdf boolean,
    br_features_flash boolean,
    br_features_java boolean,
    br_features_director boolean,
    br_features_quicktime boolean,
    br_features_realplayer boolean,
    br_features_windowsmedia boolean,
    br_features_gears boolean,
    br_features_silverlight boolean,
    br_cookies boolean,
    br_colordepth character varying(12),
    br_viewwidth integer,
    br_viewheight integer,
    os_name character varying(50),
    os_family character varying(50),
    os_manufacturer character varying(50),
    os_timezone character varying(50),
    dvce_type character varying(50),
    dvce_ismobile boolean,
    dvce_screenwidth integer,
    dvce_screenheight integer,
    doc_charset character varying(128),
    doc_width integer,
    doc_height integer,
    tr_currency character(3),
    tr_total_base numeric(18,2),
    tr_tax_base numeric(18,2),
    tr_shipping_base numeric(18,2),
    ti_currency character(3),
    ti_price_base numeric(18,2),
    base_currency character(3),
    geo_timezone character varying(64),
    mkt_clickid character varying(128),
    mkt_network character varying(64),
    etl_tags character varying(500),
    dvce_sent_tstamp timestamp with time zone,
    refr_domain_userid character varying(36),
    refr_dvce_tstamp timestamp with time zone,
    domain_sessionid character(36),
    derived_tstamp timestamp with time zone,
    event_vendor character varying(1000),
    event_name character varying(1000),
    event_format character varying(128),
    event_version character varying(128),
    event_fingerprint character varying(128),
    true_tstamp timestamp with time zone
);
ALTER TABLE ONLY product_analytics_events_experimental ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_63 FOR VALUES WITH (modulus 64, remainder 63);

CREATE TABLE abuse_reports (
    id integer NOT NULL,
    reporter_id integer,
    user_id integer,
    message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    message_html text,
    cached_markdown_version integer
);

CREATE SEQUENCE abuse_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE abuse_reports_id_seq OWNED BY abuse_reports.id;

CREATE TABLE alert_management_alert_assignees (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    alert_id bigint NOT NULL
);

CREATE SEQUENCE alert_management_alert_assignees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE alert_management_alert_assignees_id_seq OWNED BY alert_management_alert_assignees.id;

CREATE TABLE alert_management_alert_user_mentions (
    id bigint NOT NULL,
    alert_management_alert_id bigint NOT NULL,
    note_id bigint,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[]
);

CREATE SEQUENCE alert_management_alert_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE alert_management_alert_user_mentions_id_seq OWNED BY alert_management_alert_user_mentions.id;

CREATE TABLE alert_management_alerts (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    events integer DEFAULT 1 NOT NULL,
    iid integer NOT NULL,
    severity smallint DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    fingerprint bytea,
    issue_id bigint,
    project_id bigint NOT NULL,
    title text NOT NULL,
    description text,
    service text,
    monitoring_tool text,
    hosts text[] DEFAULT '{}'::text[] NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    prometheus_alert_id integer,
    environment_id integer,
    CONSTRAINT check_2df3e2fdc1 CHECK ((char_length(monitoring_tool) <= 100)),
    CONSTRAINT check_5e9e57cadb CHECK ((char_length(description) <= 1000)),
    CONSTRAINT check_bac14dddde CHECK ((char_length(service) <= 100)),
    CONSTRAINT check_d1d1c2d14c CHECK ((char_length(title) <= 200))
);

CREATE SEQUENCE alert_management_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE alert_management_alerts_id_seq OWNED BY alert_management_alerts.id;

CREATE TABLE alert_management_http_integrations (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    active boolean DEFAULT false NOT NULL,
    encrypted_token text NOT NULL,
    encrypted_token_iv text NOT NULL,
    endpoint_identifier text NOT NULL,
    name text NOT NULL,
    CONSTRAINT check_286943b636 CHECK ((char_length(encrypted_token_iv) <= 255)),
    CONSTRAINT check_392143ccf4 CHECK ((char_length(name) <= 255)),
    CONSTRAINT check_e270820180 CHECK ((char_length(endpoint_identifier) <= 255)),
    CONSTRAINT check_f68577c4af CHECK ((char_length(encrypted_token) <= 255))
);

CREATE SEQUENCE alert_management_http_integrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE alert_management_http_integrations_id_seq OWNED BY alert_management_http_integrations.id;

CREATE TABLE alerts_service_data (
    id bigint NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    encrypted_token character varying(255),
    encrypted_token_iv character varying(255)
);

CREATE SEQUENCE alerts_service_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE alerts_service_data_id_seq OWNED BY alerts_service_data.id;

CREATE TABLE allowed_email_domains (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    group_id integer NOT NULL,
    domain character varying(255) NOT NULL
);

CREATE SEQUENCE allowed_email_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE allowed_email_domains_id_seq OWNED BY allowed_email_domains.id;

CREATE TABLE analytics_cycle_analytics_group_stages (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    relative_position integer,
    start_event_identifier integer NOT NULL,
    end_event_identifier integer NOT NULL,
    group_id bigint NOT NULL,
    start_event_label_id bigint,
    end_event_label_id bigint,
    hidden boolean DEFAULT false NOT NULL,
    custom boolean DEFAULT true NOT NULL,
    name character varying(255) NOT NULL,
    group_value_stream_id bigint NOT NULL
);

CREATE SEQUENCE analytics_cycle_analytics_group_stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE analytics_cycle_analytics_group_stages_id_seq OWNED BY analytics_cycle_analytics_group_stages.id;

CREATE TABLE analytics_cycle_analytics_group_value_streams (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    group_id bigint NOT NULL,
    name text NOT NULL,
    CONSTRAINT check_bc1ed5f1f7 CHECK ((char_length(name) <= 100))
);

CREATE SEQUENCE analytics_cycle_analytics_group_value_streams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE analytics_cycle_analytics_group_value_streams_id_seq OWNED BY analytics_cycle_analytics_group_value_streams.id;

CREATE TABLE analytics_cycle_analytics_project_stages (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    relative_position integer,
    start_event_identifier integer NOT NULL,
    end_event_identifier integer NOT NULL,
    project_id bigint NOT NULL,
    start_event_label_id bigint,
    end_event_label_id bigint,
    hidden boolean DEFAULT false NOT NULL,
    custom boolean DEFAULT true NOT NULL,
    name character varying(255) NOT NULL
);

CREATE SEQUENCE analytics_cycle_analytics_project_stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE analytics_cycle_analytics_project_stages_id_seq OWNED BY analytics_cycle_analytics_project_stages.id;

CREATE TABLE analytics_instance_statistics_measurements (
    id bigint NOT NULL,
    count bigint NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    identifier smallint NOT NULL
);

CREATE SEQUENCE analytics_instance_statistics_measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE analytics_instance_statistics_measurements_id_seq OWNED BY analytics_instance_statistics_measurements.id;

CREATE TABLE analytics_language_trend_repository_languages (
    file_count integer DEFAULT 0 NOT NULL,
    programming_language_id bigint NOT NULL,
    project_id bigint NOT NULL,
    loc integer DEFAULT 0 NOT NULL,
    bytes integer DEFAULT 0 NOT NULL,
    percentage smallint DEFAULT 0 NOT NULL,
    snapshot_date date NOT NULL
);

CREATE TABLE appearances (
    id integer NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    logo character varying,
    updated_by integer,
    header_logo character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    description_html text,
    cached_markdown_version integer,
    new_project_guidelines text,
    new_project_guidelines_html text,
    header_message text,
    header_message_html text,
    footer_message text,
    footer_message_html text,
    message_background_color text,
    message_font_color text,
    favicon character varying,
    email_header_and_footer_enabled boolean DEFAULT false NOT NULL,
    profile_image_guidelines text,
    profile_image_guidelines_html text,
    CONSTRAINT appearances_profile_image_guidelines CHECK ((char_length(profile_image_guidelines) <= 4096))
);

CREATE SEQUENCE appearances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE appearances_id_seq OWNED BY appearances.id;

CREATE TABLE application_setting_terms (
    id integer NOT NULL,
    cached_markdown_version integer,
    terms text NOT NULL,
    terms_html text
);

CREATE SEQUENCE application_setting_terms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE application_setting_terms_id_seq OWNED BY application_setting_terms.id;

CREATE TABLE application_settings (
    id integer NOT NULL,
    default_projects_limit integer,
    signup_enabled boolean,
    gravatar_enabled boolean,
    sign_in_text text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    home_page_url character varying,
    default_branch_protection integer DEFAULT 2,
    help_text text,
    restricted_visibility_levels text,
    version_check_enabled boolean DEFAULT true,
    max_attachment_size integer DEFAULT 10 NOT NULL,
    default_project_visibility integer DEFAULT 0 NOT NULL,
    default_snippet_visibility integer DEFAULT 0 NOT NULL,
    domain_whitelist text,
    user_oauth_applications boolean DEFAULT true,
    after_sign_out_path character varying,
    session_expire_delay integer DEFAULT 10080 NOT NULL,
    import_sources text,
    help_page_text text,
    shared_runners_enabled boolean DEFAULT true NOT NULL,
    max_artifacts_size integer DEFAULT 100 NOT NULL,
    runners_registration_token character varying,
    max_pages_size integer DEFAULT 100 NOT NULL,
    require_two_factor_authentication boolean DEFAULT false,
    two_factor_grace_period integer DEFAULT 48,
    metrics_enabled boolean DEFAULT false,
    metrics_host character varying DEFAULT 'localhost'::character varying,
    metrics_pool_size integer DEFAULT 16,
    metrics_timeout integer DEFAULT 10,
    metrics_method_call_threshold integer DEFAULT 10,
    recaptcha_enabled boolean DEFAULT false,
    metrics_port integer DEFAULT 8089,
    akismet_enabled boolean DEFAULT false,
    metrics_sample_interval integer DEFAULT 15,
    email_author_in_body boolean DEFAULT false,
    default_group_visibility integer,
    repository_checks_enabled boolean DEFAULT false,
    shared_runners_text text,
    metrics_packet_size integer DEFAULT 1,
    disabled_oauth_sign_in_sources text,
    health_check_access_token character varying,
    send_user_confirmation_email boolean DEFAULT false,
    container_registry_token_expire_delay integer DEFAULT 5,
    after_sign_up_text text,
    user_default_external boolean DEFAULT false NOT NULL,
    elasticsearch_indexing boolean DEFAULT false NOT NULL,
    elasticsearch_search boolean DEFAULT false NOT NULL,
    repository_storages character varying DEFAULT 'default'::character varying,
    enabled_git_access_protocol character varying,
    domain_blacklist_enabled boolean DEFAULT false,
    domain_blacklist text,
    usage_ping_enabled boolean DEFAULT true NOT NULL,
    sign_in_text_html text,
    help_page_text_html text,
    shared_runners_text_html text,
    after_sign_up_text_html text,
    rsa_key_restriction integer DEFAULT 0 NOT NULL,
    dsa_key_restriction integer DEFAULT '-1'::integer NOT NULL,
    ecdsa_key_restriction integer DEFAULT 0 NOT NULL,
    ed25519_key_restriction integer DEFAULT 0 NOT NULL,
    housekeeping_enabled boolean DEFAULT true NOT NULL,
    housekeeping_bitmaps_enabled boolean DEFAULT true NOT NULL,
    housekeeping_incremental_repack_period integer DEFAULT 10 NOT NULL,
    housekeeping_full_repack_period integer DEFAULT 50 NOT NULL,
    housekeeping_gc_period integer DEFAULT 200 NOT NULL,
    html_emails_enabled boolean DEFAULT true,
    plantuml_url character varying,
    plantuml_enabled boolean,
    shared_runners_minutes integer DEFAULT 0 NOT NULL,
    repository_size_limit bigint DEFAULT 0,
    terminal_max_session_time integer DEFAULT 0 NOT NULL,
    unique_ips_limit_per_user integer,
    unique_ips_limit_time_window integer,
    unique_ips_limit_enabled boolean DEFAULT false NOT NULL,
    default_artifacts_expire_in character varying DEFAULT '0'::character varying NOT NULL,
    elasticsearch_url character varying DEFAULT 'http://localhost:9200'::character varying,
    elasticsearch_aws boolean DEFAULT false NOT NULL,
    elasticsearch_aws_region character varying DEFAULT 'us-east-1'::character varying,
    elasticsearch_aws_access_key character varying,
    geo_status_timeout integer DEFAULT 10,
    uuid character varying,
    polling_interval_multiplier numeric DEFAULT 1.0 NOT NULL,
    cached_markdown_version integer,
    check_namespace_plan boolean DEFAULT false NOT NULL,
    mirror_max_delay integer DEFAULT 300 NOT NULL,
    mirror_max_capacity integer DEFAULT 100 NOT NULL,
    mirror_capacity_threshold integer DEFAULT 50 NOT NULL,
    prometheus_metrics_enabled boolean DEFAULT true NOT NULL,
    authorized_keys_enabled boolean DEFAULT true NOT NULL,
    help_page_hide_commercial_content boolean DEFAULT false,
    help_page_support_url character varying,
    slack_app_enabled boolean DEFAULT false,
    slack_app_id character varying,
    performance_bar_allowed_group_id integer,
    allow_group_owners_to_manage_ldap boolean DEFAULT true NOT NULL,
    hashed_storage_enabled boolean DEFAULT true NOT NULL,
    project_export_enabled boolean DEFAULT true NOT NULL,
    auto_devops_enabled boolean DEFAULT true NOT NULL,
    throttle_unauthenticated_enabled boolean DEFAULT false NOT NULL,
    throttle_unauthenticated_requests_per_period integer DEFAULT 3600 NOT NULL,
    throttle_unauthenticated_period_in_seconds integer DEFAULT 3600 NOT NULL,
    throttle_authenticated_api_enabled boolean DEFAULT false NOT NULL,
    throttle_authenticated_api_requests_per_period integer DEFAULT 7200 NOT NULL,
    throttle_authenticated_api_period_in_seconds integer DEFAULT 3600 NOT NULL,
    throttle_authenticated_web_enabled boolean DEFAULT false NOT NULL,
    throttle_authenticated_web_requests_per_period integer DEFAULT 7200 NOT NULL,
    throttle_authenticated_web_period_in_seconds integer DEFAULT 3600 NOT NULL,
    gitaly_timeout_default integer DEFAULT 55 NOT NULL,
    gitaly_timeout_medium integer DEFAULT 30 NOT NULL,
    gitaly_timeout_fast integer DEFAULT 10 NOT NULL,
    mirror_available boolean DEFAULT true NOT NULL,
    password_authentication_enabled_for_web boolean,
    password_authentication_enabled_for_git boolean DEFAULT true NOT NULL,
    auto_devops_domain character varying,
    external_authorization_service_enabled boolean DEFAULT false NOT NULL,
    external_authorization_service_url character varying,
    external_authorization_service_default_label character varying,
    pages_domain_verification_enabled boolean DEFAULT true NOT NULL,
    user_default_internal_regex character varying,
    external_authorization_service_timeout double precision DEFAULT 0.5,
    external_auth_client_cert text,
    encrypted_external_auth_client_key text,
    encrypted_external_auth_client_key_iv character varying,
    encrypted_external_auth_client_key_pass character varying,
    encrypted_external_auth_client_key_pass_iv character varying,
    email_additional_text character varying,
    enforce_terms boolean DEFAULT false,
    file_template_project_id integer,
    pseudonymizer_enabled boolean DEFAULT false NOT NULL,
    hide_third_party_offers boolean DEFAULT false NOT NULL,
    snowplow_enabled boolean DEFAULT false NOT NULL,
    snowplow_collector_hostname character varying,
    snowplow_cookie_domain character varying,
    web_ide_clientside_preview_enabled boolean DEFAULT false NOT NULL,
    user_show_add_ssh_key_message boolean DEFAULT true NOT NULL,
    custom_project_templates_group_id integer,
    usage_stats_set_by_user_id integer,
    receive_max_input_size integer,
    diff_max_patch_bytes integer DEFAULT 102400 NOT NULL,
    archive_builds_in_seconds integer,
    commit_email_hostname character varying,
    protected_ci_variables boolean DEFAULT true NOT NULL,
    runners_registration_token_encrypted character varying,
    local_markdown_version integer DEFAULT 0 NOT NULL,
    first_day_of_week integer DEFAULT 0 NOT NULL,
    elasticsearch_limit_indexing boolean DEFAULT false NOT NULL,
    default_project_creation integer DEFAULT 2 NOT NULL,
    lets_encrypt_notification_email character varying,
    lets_encrypt_terms_of_service_accepted boolean DEFAULT false NOT NULL,
    geo_node_allowed_ips character varying DEFAULT '0.0.0.0/0, ::/0'::character varying,
    elasticsearch_shards integer DEFAULT 5 NOT NULL,
    elasticsearch_replicas integer DEFAULT 1 NOT NULL,
    encrypted_lets_encrypt_private_key text,
    encrypted_lets_encrypt_private_key_iv text,
    required_instance_ci_template character varying,
    dns_rebinding_protection_enabled boolean DEFAULT true NOT NULL,
    default_project_deletion_protection boolean DEFAULT false NOT NULL,
    grafana_enabled boolean DEFAULT false NOT NULL,
    lock_memberships_to_ldap boolean DEFAULT false NOT NULL,
    time_tracking_limit_to_hours boolean DEFAULT false NOT NULL,
    grafana_url character varying DEFAULT '/-/grafana'::character varying NOT NULL,
    login_recaptcha_protection_enabled boolean DEFAULT false NOT NULL,
    outbound_local_requests_whitelist character varying(255)[] DEFAULT '{}'::character varying[] NOT NULL,
    raw_blob_request_limit integer DEFAULT 300 NOT NULL,
    allow_local_requests_from_web_hooks_and_services boolean DEFAULT false NOT NULL,
    allow_local_requests_from_system_hooks boolean DEFAULT true NOT NULL,
    instance_administration_project_id bigint,
    asset_proxy_enabled boolean DEFAULT false NOT NULL,
    asset_proxy_url character varying,
    asset_proxy_whitelist text,
    encrypted_asset_proxy_secret_key text,
    encrypted_asset_proxy_secret_key_iv character varying,
    static_objects_external_storage_url character varying(255),
    static_objects_external_storage_auth_token character varying(255),
    max_personal_access_token_lifetime integer,
    throttle_protected_paths_enabled boolean DEFAULT false NOT NULL,
    throttle_protected_paths_requests_per_period integer DEFAULT 10 NOT NULL,
    throttle_protected_paths_period_in_seconds integer DEFAULT 60 NOT NULL,
    protected_paths character varying(255)[] DEFAULT '{/users/password,/users/sign_in,/api/v3/session.json,/api/v3/session,/api/v4/session.json,/api/v4/session,/users,/users/confirmation,/unsubscribes/,/import/github/personal_access_token,/admin/session,/oauth/authorize,/oauth/token}'::character varying[],
    throttle_incident_management_notification_enabled boolean DEFAULT false NOT NULL,
    throttle_incident_management_notification_period_in_seconds integer DEFAULT 3600,
    throttle_incident_management_notification_per_period integer DEFAULT 3600,
    push_event_hooks_limit integer DEFAULT 3 NOT NULL,
    push_event_activities_limit integer DEFAULT 3 NOT NULL,
    custom_http_clone_url_root character varying(511),
    deletion_adjourned_period integer DEFAULT 7 NOT NULL,
    license_trial_ends_on date,
    eks_integration_enabled boolean DEFAULT false NOT NULL,
    eks_account_id character varying(128),
    eks_access_key_id character varying(128),
    encrypted_eks_secret_access_key_iv character varying(255),
    encrypted_eks_secret_access_key text,
    snowplow_app_id character varying,
    productivity_analytics_start_date timestamp with time zone,
    default_ci_config_path character varying(255),
    sourcegraph_enabled boolean DEFAULT false NOT NULL,
    sourcegraph_url character varying(255),
    sourcegraph_public_only boolean DEFAULT true NOT NULL,
    snippet_size_limit bigint DEFAULT 52428800 NOT NULL,
    minimum_password_length integer DEFAULT 8 NOT NULL,
    encrypted_akismet_api_key text,
    encrypted_akismet_api_key_iv character varying(255),
    encrypted_elasticsearch_aws_secret_access_key text,
    encrypted_elasticsearch_aws_secret_access_key_iv character varying(255),
    encrypted_recaptcha_private_key text,
    encrypted_recaptcha_private_key_iv character varying(255),
    encrypted_recaptcha_site_key text,
    encrypted_recaptcha_site_key_iv character varying(255),
    encrypted_slack_app_secret text,
    encrypted_slack_app_secret_iv character varying(255),
    encrypted_slack_app_verification_token text,
    encrypted_slack_app_verification_token_iv character varying(255),
    force_pages_access_control boolean DEFAULT false NOT NULL,
    updating_name_disabled_for_users boolean DEFAULT false NOT NULL,
    instance_administrators_group_id integer,
    elasticsearch_indexed_field_length_limit integer DEFAULT 0 NOT NULL,
    elasticsearch_max_bulk_size_mb smallint DEFAULT 10 NOT NULL,
    elasticsearch_max_bulk_concurrency smallint DEFAULT 10 NOT NULL,
    disable_overriding_approvers_per_merge_request boolean DEFAULT false NOT NULL,
    prevent_merge_requests_author_approval boolean DEFAULT false NOT NULL,
    prevent_merge_requests_committers_approval boolean DEFAULT false NOT NULL,
    email_restrictions_enabled boolean DEFAULT false NOT NULL,
    email_restrictions text,
    npm_package_requests_forwarding boolean DEFAULT true NOT NULL,
    namespace_storage_size_limit bigint DEFAULT 0 NOT NULL,
    seat_link_enabled boolean DEFAULT true NOT NULL,
    container_expiration_policies_enable_historic_entries boolean DEFAULT false NOT NULL,
    issues_create_limit integer DEFAULT 0 NOT NULL,
    push_rule_id bigint,
    group_owners_can_manage_default_branch_protection boolean DEFAULT true NOT NULL,
    container_registry_vendor text DEFAULT ''::text NOT NULL,
    container_registry_version text DEFAULT ''::text NOT NULL,
    container_registry_features text[] DEFAULT '{}'::text[] NOT NULL,
    spam_check_endpoint_url text,
    spam_check_endpoint_enabled boolean DEFAULT false NOT NULL,
    elasticsearch_pause_indexing boolean DEFAULT false NOT NULL,
    repository_storages_weighted jsonb DEFAULT '{}'::jsonb NOT NULL,
    max_import_size integer DEFAULT 50 NOT NULL,
    enforce_pat_expiration boolean DEFAULT true NOT NULL,
    compliance_frameworks smallint[] DEFAULT '{}'::smallint[] NOT NULL,
    notify_on_unknown_sign_in boolean DEFAULT true NOT NULL,
    default_branch_name text,
    project_import_limit integer DEFAULT 6 NOT NULL,
    project_export_limit integer DEFAULT 6 NOT NULL,
    project_download_export_limit integer DEFAULT 1 NOT NULL,
    group_import_limit integer DEFAULT 6 NOT NULL,
    group_export_limit integer DEFAULT 6 NOT NULL,
    group_download_export_limit integer DEFAULT 1 NOT NULL,
    maintenance_mode boolean DEFAULT false NOT NULL,
    maintenance_mode_message text,
    wiki_page_max_content_bytes bigint DEFAULT 52428800 NOT NULL,
    elasticsearch_indexed_file_size_limit_kb integer DEFAULT 1024 NOT NULL,
    enforce_namespace_storage_limit boolean DEFAULT false NOT NULL,
    container_registry_delete_tags_service_timeout integer DEFAULT 250 NOT NULL,
    elasticsearch_client_request_timeout integer DEFAULT 0 NOT NULL,
    gitpod_enabled boolean DEFAULT false NOT NULL,
    gitpod_url text DEFAULT 'https://gitpod.io/'::text,
    abuse_notification_email character varying,
    require_admin_approval_after_user_signup boolean DEFAULT false NOT NULL,
    help_page_documentation_base_url text,
    automatic_purchased_storage_allocation boolean DEFAULT false NOT NULL,
    encrypted_ci_jwt_signing_key text,
    encrypted_ci_jwt_signing_key_iv text,
    CONSTRAINT check_2dba05b802 CHECK ((char_length(gitpod_url) <= 255)),
    CONSTRAINT check_51700b31b5 CHECK ((char_length(default_branch_name) <= 255)),
    CONSTRAINT check_57123c9593 CHECK ((char_length(help_page_documentation_base_url) <= 255)),
    CONSTRAINT check_85a39b68ff CHECK ((char_length(encrypted_ci_jwt_signing_key_iv) <= 255)),
    CONSTRAINT check_9c6c447a13 CHECK ((char_length(maintenance_mode_message) <= 255)),
    CONSTRAINT check_d03919528d CHECK ((char_length(container_registry_vendor) <= 255)),
    CONSTRAINT check_d820146492 CHECK ((char_length(spam_check_endpoint_url) <= 255)),
    CONSTRAINT check_e5aba18f02 CHECK ((char_length(container_registry_version) <= 255))
);

CREATE SEQUENCE application_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE application_settings_id_seq OWNED BY application_settings.id;

CREATE TABLE approval_merge_request_rule_sources (
    id bigint NOT NULL,
    approval_merge_request_rule_id bigint NOT NULL,
    approval_project_rule_id bigint NOT NULL
);

CREATE SEQUENCE approval_merge_request_rule_sources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_merge_request_rule_sources_id_seq OWNED BY approval_merge_request_rule_sources.id;

CREATE TABLE approval_merge_request_rules (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    merge_request_id integer NOT NULL,
    approvals_required smallint DEFAULT 0 NOT NULL,
    name character varying NOT NULL,
    rule_type smallint DEFAULT 1 NOT NULL,
    report_type smallint,
    section text,
    modified_from_project_rule boolean DEFAULT false NOT NULL,
    CONSTRAINT check_6fca5928b2 CHECK ((char_length(section) <= 255))
);

CREATE TABLE approval_merge_request_rules_approved_approvers (
    id bigint NOT NULL,
    approval_merge_request_rule_id bigint NOT NULL,
    user_id integer NOT NULL
);

CREATE SEQUENCE approval_merge_request_rules_approved_approvers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_merge_request_rules_approved_approvers_id_seq OWNED BY approval_merge_request_rules_approved_approvers.id;

CREATE TABLE approval_merge_request_rules_groups (
    id bigint NOT NULL,
    approval_merge_request_rule_id bigint NOT NULL,
    group_id integer NOT NULL
);

CREATE SEQUENCE approval_merge_request_rules_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_merge_request_rules_groups_id_seq OWNED BY approval_merge_request_rules_groups.id;

CREATE SEQUENCE approval_merge_request_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_merge_request_rules_id_seq OWNED BY approval_merge_request_rules.id;

CREATE TABLE approval_merge_request_rules_users (
    id bigint NOT NULL,
    approval_merge_request_rule_id bigint NOT NULL,
    user_id integer NOT NULL
);

CREATE SEQUENCE approval_merge_request_rules_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_merge_request_rules_users_id_seq OWNED BY approval_merge_request_rules_users.id;

CREATE TABLE approval_project_rules (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    approvals_required smallint DEFAULT 0 NOT NULL,
    name character varying NOT NULL,
    rule_type smallint DEFAULT 0 NOT NULL
);

CREATE TABLE approval_project_rules_groups (
    id bigint NOT NULL,
    approval_project_rule_id bigint NOT NULL,
    group_id integer NOT NULL
);

CREATE SEQUENCE approval_project_rules_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_project_rules_groups_id_seq OWNED BY approval_project_rules_groups.id;

CREATE SEQUENCE approval_project_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_project_rules_id_seq OWNED BY approval_project_rules.id;

CREATE TABLE approval_project_rules_protected_branches (
    approval_project_rule_id bigint NOT NULL,
    protected_branch_id bigint NOT NULL
);

CREATE TABLE approval_project_rules_users (
    id bigint NOT NULL,
    approval_project_rule_id bigint NOT NULL,
    user_id integer NOT NULL
);

CREATE SEQUENCE approval_project_rules_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approval_project_rules_users_id_seq OWNED BY approval_project_rules_users.id;

CREATE TABLE approvals (
    id integer NOT NULL,
    merge_request_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE approvals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approvals_id_seq OWNED BY approvals.id;

CREATE TABLE approver_groups (
    id integer NOT NULL,
    target_id integer NOT NULL,
    target_type character varying NOT NULL,
    group_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE approver_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approver_groups_id_seq OWNED BY approver_groups.id;

CREATE TABLE approvers (
    id integer NOT NULL,
    target_id integer NOT NULL,
    target_type character varying,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE approvers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE approvers_id_seq OWNED BY approvers.id;

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);

CREATE TABLE atlassian_identities (
    user_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone,
    extern_uid text NOT NULL,
    encrypted_token bytea,
    encrypted_token_iv bytea,
    encrypted_refresh_token bytea,
    encrypted_refresh_token_iv bytea,
    CONSTRAINT atlassian_identities_refresh_token_iv_length_constraint CHECK ((octet_length(encrypted_refresh_token_iv) <= 12)),
    CONSTRAINT atlassian_identities_refresh_token_length_constraint CHECK ((octet_length(encrypted_refresh_token) <= 512)),
    CONSTRAINT atlassian_identities_token_iv_length_constraint CHECK ((octet_length(encrypted_token_iv) <= 12)),
    CONSTRAINT atlassian_identities_token_length_constraint CHECK ((octet_length(encrypted_token) <= 2048)),
    CONSTRAINT check_32f5779763 CHECK ((char_length(extern_uid) <= 255))
);

CREATE SEQUENCE atlassian_identities_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE atlassian_identities_user_id_seq OWNED BY atlassian_identities.user_id;

CREATE TABLE audit_events (
    id integer NOT NULL,
    author_id integer NOT NULL,
    entity_id integer NOT NULL,
    entity_type character varying NOT NULL,
    details text,
    created_at timestamp without time zone,
    ip_address inet,
    author_name text,
    entity_path text,
    target_details text,
    target_type text,
    target_id bigint,
    CONSTRAINT check_492aaa021d CHECK ((char_length(entity_path) <= 5500)),
    CONSTRAINT check_82294106dd CHECK ((char_length(target_type) <= 255)),
    CONSTRAINT check_83ff8406e2 CHECK ((char_length(author_name) <= 255)),
    CONSTRAINT check_d493ec90b5 CHECK ((char_length(target_details) <= 5500))
);

CREATE SEQUENCE audit_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE audit_events_id_seq OWNED BY audit_events.id;

CREATE TABLE authentication_events (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    user_id bigint,
    result smallint NOT NULL,
    ip_address inet,
    provider text NOT NULL,
    user_name text NOT NULL,
    CONSTRAINT check_45a6cc4e80 CHECK ((char_length(user_name) <= 255)),
    CONSTRAINT check_c64f424630 CHECK ((char_length(provider) <= 64))
);

CREATE SEQUENCE authentication_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE authentication_events_id_seq OWNED BY authentication_events.id;

CREATE TABLE award_emoji (
    id integer NOT NULL,
    name character varying,
    user_id integer,
    awardable_id integer,
    awardable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE award_emoji_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE award_emoji_id_seq OWNED BY award_emoji.id;

CREATE TABLE aws_roles (
    user_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    role_arn character varying(2048),
    role_external_id character varying(64) NOT NULL
);

CREATE TABLE background_migration_jobs (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    class_name text NOT NULL,
    arguments jsonb NOT NULL,
    CONSTRAINT check_b0de0a5852 CHECK ((char_length(class_name) <= 200))
);

CREATE SEQUENCE background_migration_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE background_migration_jobs_id_seq OWNED BY background_migration_jobs.id;

CREATE TABLE backup_labels (
    id integer NOT NULL,
    title character varying,
    color character varying,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    template boolean DEFAULT false,
    description character varying,
    description_html text,
    type character varying,
    group_id integer,
    cached_markdown_version integer,
    restore_action integer,
    new_title character varying
);

CREATE TABLE badges (
    id integer NOT NULL,
    link_url character varying NOT NULL,
    image_url character varying NOT NULL,
    project_id integer,
    group_id integer,
    type character varying NOT NULL,
    name character varying(255),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE badges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE badges_id_seq OWNED BY badges.id;

CREATE TABLE board_assignees (
    id integer NOT NULL,
    board_id integer NOT NULL,
    assignee_id integer NOT NULL
);

CREATE SEQUENCE board_assignees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE board_assignees_id_seq OWNED BY board_assignees.id;

CREATE TABLE board_group_recent_visits (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    user_id integer,
    board_id integer,
    group_id integer
);

CREATE SEQUENCE board_group_recent_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE board_group_recent_visits_id_seq OWNED BY board_group_recent_visits.id;

CREATE TABLE board_labels (
    id integer NOT NULL,
    board_id integer NOT NULL,
    label_id integer NOT NULL
);

CREATE SEQUENCE board_labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE board_labels_id_seq OWNED BY board_labels.id;

CREATE TABLE board_project_recent_visits (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    user_id integer,
    project_id integer,
    board_id integer
);

CREATE SEQUENCE board_project_recent_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE board_project_recent_visits_id_seq OWNED BY board_project_recent_visits.id;

CREATE TABLE board_user_preferences (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    board_id bigint NOT NULL,
    hide_labels boolean,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE board_user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE board_user_preferences_id_seq OWNED BY board_user_preferences.id;

CREATE TABLE boards (
    id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying DEFAULT 'Development'::character varying NOT NULL,
    milestone_id integer,
    group_id integer,
    weight integer,
    hide_backlog_list boolean DEFAULT false NOT NULL,
    hide_closed_list boolean DEFAULT false NOT NULL
);

CREATE TABLE boards_epic_user_preferences (
    id bigint NOT NULL,
    board_id bigint NOT NULL,
    user_id bigint NOT NULL,
    epic_id bigint NOT NULL,
    collapsed boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE boards_epic_user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE boards_epic_user_preferences_id_seq OWNED BY boards_epic_user_preferences.id;

CREATE SEQUENCE boards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE boards_id_seq OWNED BY boards.id;

CREATE TABLE broadcast_messages (
    id integer NOT NULL,
    message text NOT NULL,
    starts_at timestamp without time zone NOT NULL,
    ends_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    color character varying,
    font character varying,
    message_html text NOT NULL,
    cached_markdown_version integer,
    target_path character varying(255),
    broadcast_type smallint DEFAULT 1 NOT NULL,
    dismissable boolean
);

CREATE SEQUENCE broadcast_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE broadcast_messages_id_seq OWNED BY broadcast_messages.id;

CREATE TABLE bulk_import_configurations (
    id bigint NOT NULL,
    bulk_import_id integer NOT NULL,
    encrypted_url text,
    encrypted_url_iv text,
    encrypted_access_token text,
    encrypted_access_token_iv text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE bulk_import_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE bulk_import_configurations_id_seq OWNED BY bulk_import_configurations.id;

CREATE TABLE bulk_import_entities (
    id bigint NOT NULL,
    bulk_import_id bigint NOT NULL,
    parent_id bigint,
    namespace_id bigint,
    project_id bigint,
    source_type smallint NOT NULL,
    source_full_path text NOT NULL,
    destination_name text NOT NULL,
    destination_namespace text NOT NULL,
    status smallint NOT NULL,
    jid text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT check_13f279f7da CHECK ((char_length(source_full_path) <= 255)),
    CONSTRAINT check_715d725ea2 CHECK ((char_length(destination_name) <= 255)),
    CONSTRAINT check_796a4d9cc6 CHECK ((char_length(jid) <= 255)),
    CONSTRAINT check_b834fff4d9 CHECK ((char_length(destination_namespace) <= 255))
);

CREATE SEQUENCE bulk_import_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE bulk_import_entities_id_seq OWNED BY bulk_import_entities.id;

CREATE TABLE bulk_imports (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    source_type smallint NOT NULL,
    status smallint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE bulk_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE bulk_imports_id_seq OWNED BY bulk_imports.id;

CREATE TABLE chat_names (
    id integer NOT NULL,
    user_id integer NOT NULL,
    service_id integer NOT NULL,
    team_id character varying NOT NULL,
    team_domain character varying,
    chat_id character varying NOT NULL,
    chat_name character varying,
    last_used_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE chat_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE chat_names_id_seq OWNED BY chat_names.id;

CREATE TABLE chat_teams (
    id integer NOT NULL,
    namespace_id integer NOT NULL,
    team_id character varying,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE chat_teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE chat_teams_id_seq OWNED BY chat_teams.id;

CREATE TABLE ci_build_needs (
    id integer NOT NULL,
    build_id integer NOT NULL,
    name text NOT NULL,
    artifacts boolean DEFAULT true NOT NULL
);

CREATE SEQUENCE ci_build_needs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_build_needs_id_seq OWNED BY ci_build_needs.id;

CREATE TABLE ci_build_pending_states (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    build_id bigint NOT NULL,
    state smallint,
    failure_reason smallint,
    trace_checksum bytea
);

CREATE SEQUENCE ci_build_pending_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_build_pending_states_id_seq OWNED BY ci_build_pending_states.id;

CREATE TABLE ci_build_report_results (
    build_id bigint NOT NULL,
    project_id bigint NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL
);

CREATE SEQUENCE ci_build_report_results_build_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_build_report_results_build_id_seq OWNED BY ci_build_report_results.build_id;

CREATE TABLE ci_build_trace_chunks (
    id bigint NOT NULL,
    build_id integer NOT NULL,
    chunk_index integer NOT NULL,
    data_store integer NOT NULL,
    raw_data bytea,
    checksum bytea,
    lock_version integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE ci_build_trace_chunks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_build_trace_chunks_id_seq OWNED BY ci_build_trace_chunks.id;

CREATE TABLE ci_build_trace_section_names (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying NOT NULL
);

CREATE SEQUENCE ci_build_trace_section_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_build_trace_section_names_id_seq OWNED BY ci_build_trace_section_names.id;

CREATE TABLE ci_build_trace_sections (
    project_id integer NOT NULL,
    date_start timestamp without time zone NOT NULL,
    date_end timestamp without time zone NOT NULL,
    byte_start bigint NOT NULL,
    byte_end bigint NOT NULL,
    build_id integer NOT NULL,
    section_name_id integer NOT NULL
);

CREATE TABLE ci_builds (
    id integer NOT NULL,
    status character varying,
    finished_at timestamp without time zone,
    trace text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    started_at timestamp without time zone,
    runner_id integer,
    coverage double precision,
    commit_id integer,
    commands text,
    name character varying,
    options text,
    allow_failure boolean DEFAULT false NOT NULL,
    stage character varying,
    trigger_request_id integer,
    stage_idx integer,
    tag boolean,
    ref character varying,
    user_id integer,
    type character varying,
    target_url character varying,
    description character varying,
    artifacts_file text,
    project_id integer,
    artifacts_metadata text,
    erased_by_id integer,
    erased_at timestamp without time zone,
    artifacts_expire_at timestamp without time zone,
    environment character varying,
    artifacts_size bigint,
    "when" character varying,
    yaml_variables text,
    queued_at timestamp without time zone,
    token character varying,
    lock_version integer DEFAULT 0,
    coverage_regex character varying,
    auto_canceled_by_id integer,
    retried boolean,
    stage_id integer,
    artifacts_file_store integer,
    artifacts_metadata_store integer,
    protected boolean,
    failure_reason integer,
    scheduled_at timestamp with time zone,
    token_encrypted character varying,
    upstream_pipeline_id integer,
    resource_group_id bigint,
    waiting_for_resource_at timestamp with time zone,
    processed boolean,
    scheduling_type smallint,
    CONSTRAINT check_1e2fbd1b39 CHECK ((lock_version IS NOT NULL))
);

CREATE SEQUENCE ci_builds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_builds_id_seq OWNED BY ci_builds.id;

CREATE TABLE ci_builds_metadata (
    id integer NOT NULL,
    build_id integer NOT NULL,
    project_id integer NOT NULL,
    timeout integer,
    timeout_source integer DEFAULT 1 NOT NULL,
    interruptible boolean,
    config_options jsonb,
    config_variables jsonb,
    has_exposed_artifacts boolean,
    environment_auto_stop_in character varying(255),
    expanded_environment_name character varying(255),
    secrets jsonb DEFAULT '{}'::jsonb NOT NULL
);

CREATE SEQUENCE ci_builds_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_builds_metadata_id_seq OWNED BY ci_builds_metadata.id;

CREATE TABLE ci_builds_runner_session (
    id bigint NOT NULL,
    build_id integer NOT NULL,
    url character varying NOT NULL,
    certificate character varying,
    "authorization" character varying
);

CREATE SEQUENCE ci_builds_runner_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_builds_runner_session_id_seq OWNED BY ci_builds_runner_session.id;

CREATE TABLE ci_daily_build_group_report_results (
    id bigint NOT NULL,
    date date NOT NULL,
    project_id bigint NOT NULL,
    last_pipeline_id bigint NOT NULL,
    ref_path text NOT NULL,
    group_name text NOT NULL,
    data jsonb NOT NULL
);

CREATE SEQUENCE ci_daily_build_group_report_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_daily_build_group_report_results_id_seq OWNED BY ci_daily_build_group_report_results.id;

CREATE TABLE ci_deleted_objects (
    id bigint NOT NULL,
    file_store smallint DEFAULT 1 NOT NULL,
    pick_up_at timestamp with time zone DEFAULT now() NOT NULL,
    store_dir text NOT NULL,
    file text NOT NULL,
    CONSTRAINT check_5e151d6912 CHECK ((char_length(store_dir) <= 1024))
);

CREATE SEQUENCE ci_deleted_objects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_deleted_objects_id_seq OWNED BY ci_deleted_objects.id;

CREATE TABLE ci_freeze_periods (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    freeze_start character varying(998) NOT NULL,
    freeze_end character varying(998) NOT NULL,
    cron_timezone character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE ci_freeze_periods_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_freeze_periods_id_seq OWNED BY ci_freeze_periods.id;

CREATE TABLE ci_group_variables (
    id integer NOT NULL,
    key character varying NOT NULL,
    value text,
    encrypted_value text,
    encrypted_value_salt character varying,
    encrypted_value_iv character varying,
    group_id integer NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    masked boolean DEFAULT false NOT NULL,
    variable_type smallint DEFAULT 1 NOT NULL
);

CREATE SEQUENCE ci_group_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_group_variables_id_seq OWNED BY ci_group_variables.id;

CREATE TABLE ci_instance_variables (
    id bigint NOT NULL,
    variable_type smallint DEFAULT 1 NOT NULL,
    masked boolean DEFAULT false,
    protected boolean DEFAULT false,
    key text NOT NULL,
    encrypted_value text,
    encrypted_value_iv text,
    CONSTRAINT check_07a45a5bcb CHECK ((char_length(encrypted_value_iv) <= 255)),
    CONSTRAINT check_5aede12208 CHECK ((char_length(key) <= 255)),
    CONSTRAINT check_956afd70f1 CHECK ((char_length(encrypted_value) <= 13579))
);

CREATE SEQUENCE ci_instance_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_instance_variables_id_seq OWNED BY ci_instance_variables.id;

CREATE TABLE ci_job_artifacts (
    id integer NOT NULL,
    project_id integer NOT NULL,
    job_id integer NOT NULL,
    file_type integer NOT NULL,
    size bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    expire_at timestamp with time zone,
    file character varying,
    file_store integer DEFAULT 1,
    file_sha256 bytea,
    file_format smallint,
    file_location smallint,
    CONSTRAINT check_27f0f6dbab CHECK ((file_store IS NOT NULL))
);

CREATE SEQUENCE ci_job_artifacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_job_artifacts_id_seq OWNED BY ci_job_artifacts.id;

CREATE TABLE ci_job_variables (
    id bigint NOT NULL,
    key character varying NOT NULL,
    encrypted_value text,
    encrypted_value_iv character varying,
    job_id bigint NOT NULL,
    variable_type smallint DEFAULT 1 NOT NULL,
    source smallint DEFAULT 0 NOT NULL
);

CREATE SEQUENCE ci_job_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_job_variables_id_seq OWNED BY ci_job_variables.id;

CREATE TABLE ci_pipeline_artifacts (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    pipeline_id bigint NOT NULL,
    project_id bigint NOT NULL,
    size integer NOT NULL,
    file_store smallint DEFAULT 1 NOT NULL,
    file_type smallint NOT NULL,
    file_format smallint NOT NULL,
    file text,
    expire_at timestamp with time zone,
    CONSTRAINT check_191b5850ec CHECK ((char_length(file) <= 255)),
    CONSTRAINT check_abeeb71caf CHECK ((file IS NOT NULL))
);

CREATE SEQUENCE ci_pipeline_artifacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipeline_artifacts_id_seq OWNED BY ci_pipeline_artifacts.id;

CREATE TABLE ci_pipeline_chat_data (
    id bigint NOT NULL,
    pipeline_id integer NOT NULL,
    chat_name_id integer NOT NULL,
    response_url text NOT NULL
);

CREATE SEQUENCE ci_pipeline_chat_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipeline_chat_data_id_seq OWNED BY ci_pipeline_chat_data.id;

CREATE TABLE ci_pipeline_messages (
    id bigint NOT NULL,
    severity smallint DEFAULT 0 NOT NULL,
    pipeline_id integer NOT NULL,
    content text NOT NULL,
    CONSTRAINT check_58ca2981b2 CHECK ((char_length(content) <= 10000))
);

CREATE SEQUENCE ci_pipeline_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipeline_messages_id_seq OWNED BY ci_pipeline_messages.id;

CREATE TABLE ci_pipeline_schedule_variables (
    id integer NOT NULL,
    key character varying NOT NULL,
    value text,
    encrypted_value text,
    encrypted_value_salt character varying,
    encrypted_value_iv character varying,
    pipeline_schedule_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    variable_type smallint DEFAULT 1 NOT NULL
);

CREATE SEQUENCE ci_pipeline_schedule_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipeline_schedule_variables_id_seq OWNED BY ci_pipeline_schedule_variables.id;

CREATE TABLE ci_pipeline_schedules (
    id integer NOT NULL,
    description character varying,
    ref character varying,
    cron character varying,
    cron_timezone character varying,
    next_run_at timestamp without time zone,
    project_id integer,
    owner_id integer,
    active boolean DEFAULT true,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE ci_pipeline_schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipeline_schedules_id_seq OWNED BY ci_pipeline_schedules.id;

CREATE TABLE ci_pipeline_variables (
    id integer NOT NULL,
    key character varying NOT NULL,
    value text,
    encrypted_value text,
    encrypted_value_salt character varying,
    encrypted_value_iv character varying,
    pipeline_id integer NOT NULL,
    variable_type smallint DEFAULT 1 NOT NULL
);

CREATE SEQUENCE ci_pipeline_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipeline_variables_id_seq OWNED BY ci_pipeline_variables.id;

CREATE TABLE ci_pipelines (
    id integer NOT NULL,
    ref character varying,
    sha character varying,
    before_sha character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tag boolean DEFAULT false,
    yaml_errors text,
    committed_at timestamp without time zone,
    project_id integer,
    status character varying,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    duration integer,
    user_id integer,
    lock_version integer DEFAULT 0,
    auto_canceled_by_id integer,
    pipeline_schedule_id integer,
    source integer,
    config_source integer,
    protected boolean,
    failure_reason integer,
    iid integer,
    merge_request_id integer,
    source_sha bytea,
    target_sha bytea,
    external_pull_request_id bigint,
    ci_ref_id bigint,
    locked smallint DEFAULT 1 NOT NULL,
    CONSTRAINT check_d7e99a025e CHECK ((lock_version IS NOT NULL))
);

CREATE TABLE ci_pipelines_config (
    pipeline_id bigint NOT NULL,
    content text NOT NULL
);

CREATE SEQUENCE ci_pipelines_config_pipeline_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipelines_config_pipeline_id_seq OWNED BY ci_pipelines_config.pipeline_id;

CREATE SEQUENCE ci_pipelines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_pipelines_id_seq OWNED BY ci_pipelines.id;

CREATE TABLE ci_platform_metrics (
    id bigint NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    platform_target text NOT NULL,
    count integer NOT NULL,
    CONSTRAINT check_f922abc32b CHECK ((char_length(platform_target) <= 255)),
    CONSTRAINT ci_platform_metrics_check_count_positive CHECK ((count > 0))
);

CREATE SEQUENCE ci_platform_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_platform_metrics_id_seq OWNED BY ci_platform_metrics.id;

CREATE TABLE ci_refs (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    lock_version integer DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    ref_path text NOT NULL
);

CREATE SEQUENCE ci_refs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_refs_id_seq OWNED BY ci_refs.id;

CREATE TABLE ci_resource_groups (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    key character varying(255) NOT NULL
);

CREATE SEQUENCE ci_resource_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_resource_groups_id_seq OWNED BY ci_resource_groups.id;

CREATE TABLE ci_resources (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    resource_group_id bigint NOT NULL,
    build_id bigint
);

CREATE SEQUENCE ci_resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_resources_id_seq OWNED BY ci_resources.id;

CREATE TABLE ci_runner_namespaces (
    id integer NOT NULL,
    runner_id integer,
    namespace_id integer
);

CREATE SEQUENCE ci_runner_namespaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_runner_namespaces_id_seq OWNED BY ci_runner_namespaces.id;

CREATE TABLE ci_runner_projects (
    id integer NOT NULL,
    runner_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_id integer
);

CREATE SEQUENCE ci_runner_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_runner_projects_id_seq OWNED BY ci_runner_projects.id;

CREATE TABLE ci_runners (
    id integer NOT NULL,
    token character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description character varying,
    contacted_at timestamp without time zone,
    active boolean DEFAULT true NOT NULL,
    is_shared boolean DEFAULT false,
    name character varying,
    version character varying,
    revision character varying,
    platform character varying,
    architecture character varying,
    run_untagged boolean DEFAULT true NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    access_level integer DEFAULT 0 NOT NULL,
    ip_address character varying,
    maximum_timeout integer,
    runner_type smallint NOT NULL,
    token_encrypted character varying,
    public_projects_minutes_cost_factor double precision DEFAULT 0.0 NOT NULL,
    private_projects_minutes_cost_factor double precision DEFAULT 1.0 NOT NULL
);

CREATE SEQUENCE ci_runners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_runners_id_seq OWNED BY ci_runners.id;

CREATE TABLE ci_sources_pipelines (
    id integer NOT NULL,
    project_id integer,
    pipeline_id integer,
    source_project_id integer,
    source_job_id integer,
    source_pipeline_id integer
);

CREATE SEQUENCE ci_sources_pipelines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_sources_pipelines_id_seq OWNED BY ci_sources_pipelines.id;

CREATE TABLE ci_sources_projects (
    id bigint NOT NULL,
    pipeline_id bigint NOT NULL,
    source_project_id bigint NOT NULL
);

CREATE SEQUENCE ci_sources_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_sources_projects_id_seq OWNED BY ci_sources_projects.id;

CREATE TABLE ci_stages (
    id integer NOT NULL,
    project_id integer,
    pipeline_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying,
    status integer,
    lock_version integer DEFAULT 0,
    "position" integer,
    CONSTRAINT check_81b431e49b CHECK ((lock_version IS NOT NULL))
);

CREATE SEQUENCE ci_stages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_stages_id_seq OWNED BY ci_stages.id;

CREATE TABLE ci_subscriptions_projects (
    id bigint NOT NULL,
    downstream_project_id bigint NOT NULL,
    upstream_project_id bigint NOT NULL
);

CREATE SEQUENCE ci_subscriptions_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_subscriptions_projects_id_seq OWNED BY ci_subscriptions_projects.id;

CREATE TABLE ci_trigger_requests (
    id integer NOT NULL,
    trigger_id integer NOT NULL,
    variables text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    commit_id integer
);

CREATE SEQUENCE ci_trigger_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_trigger_requests_id_seq OWNED BY ci_trigger_requests.id;

CREATE TABLE ci_triggers (
    id integer NOT NULL,
    token character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_id integer,
    owner_id integer NOT NULL,
    description character varying,
    ref character varying
);

CREATE SEQUENCE ci_triggers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_triggers_id_seq OWNED BY ci_triggers.id;

CREATE TABLE ci_variables (
    id integer NOT NULL,
    key character varying NOT NULL,
    value text,
    encrypted_value text,
    encrypted_value_salt character varying,
    encrypted_value_iv character varying,
    project_id integer NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    environment_scope character varying DEFAULT '*'::character varying NOT NULL,
    masked boolean DEFAULT false NOT NULL,
    variable_type smallint DEFAULT 1 NOT NULL
);

CREATE SEQUENCE ci_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_variables_id_seq OWNED BY ci_variables.id;

CREATE TABLE cluster_agent_tokens (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    agent_id bigint NOT NULL,
    token_encrypted text NOT NULL,
    CONSTRAINT check_c60daed227 CHECK ((char_length(token_encrypted) <= 255))
);

CREATE SEQUENCE cluster_agent_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE cluster_agent_tokens_id_seq OWNED BY cluster_agent_tokens.id;

CREATE TABLE cluster_agents (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    name text NOT NULL,
    CONSTRAINT check_3498369510 CHECK ((char_length(name) <= 255))
);

CREATE SEQUENCE cluster_agents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE cluster_agents_id_seq OWNED BY cluster_agents.id;

CREATE TABLE cluster_groups (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    group_id integer NOT NULL
);

CREATE SEQUENCE cluster_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE cluster_groups_id_seq OWNED BY cluster_groups.id;

CREATE TABLE cluster_platforms_kubernetes (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    api_url text,
    ca_cert text,
    namespace character varying,
    username character varying,
    encrypted_password text,
    encrypted_password_iv character varying,
    encrypted_token text,
    encrypted_token_iv character varying,
    authorization_type smallint
);

CREATE SEQUENCE cluster_platforms_kubernetes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE cluster_platforms_kubernetes_id_seq OWNED BY cluster_platforms_kubernetes.id;

CREATE TABLE cluster_projects (
    id integer NOT NULL,
    project_id integer NOT NULL,
    cluster_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE cluster_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE cluster_projects_id_seq OWNED BY cluster_projects.id;

CREATE TABLE cluster_providers_aws (
    id bigint NOT NULL,
    cluster_id bigint NOT NULL,
    num_nodes integer NOT NULL,
    status integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    key_name character varying(255) NOT NULL,
    role_arn character varying(2048) NOT NULL,
    region character varying(255) NOT NULL,
    vpc_id character varying(255) NOT NULL,
    subnet_ids character varying(255)[] DEFAULT '{}'::character varying[] NOT NULL,
    security_group_id character varying(255) NOT NULL,
    instance_type character varying(255) NOT NULL,
    access_key_id character varying(255),
    encrypted_secret_access_key_iv character varying(255),
    encrypted_secret_access_key text,
    session_token text,
    status_reason text,
    kubernetes_version text DEFAULT '1.14'::text NOT NULL,
    CONSTRAINT check_f1f42cd85e CHECK ((char_length(kubernetes_version) <= 30))
);

CREATE SEQUENCE cluster_providers_aws_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE cluster_providers_aws_id_seq OWNED BY cluster_providers_aws.id;

CREATE TABLE cluster_providers_gcp (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    status integer,
    num_nodes integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status_reason text,
    gcp_project_id character varying NOT NULL,
    zone character varying NOT NULL,
    machine_type character varying,
    operation_id character varying,
    endpoint character varying,
    encrypted_access_token text,
    encrypted_access_token_iv character varying,
    legacy_abac boolean DEFAULT false NOT NULL,
    cloud_run boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE cluster_providers_gcp_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE cluster_providers_gcp_id_seq OWNED BY cluster_providers_gcp.id;

CREATE TABLE clusters (
    id integer NOT NULL,
    user_id integer,
    provider_type integer,
    platform_type integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    enabled boolean DEFAULT true,
    name character varying NOT NULL,
    environment_scope character varying DEFAULT '*'::character varying NOT NULL,
    cluster_type smallint DEFAULT 3 NOT NULL,
    domain character varying,
    managed boolean DEFAULT true NOT NULL,
    namespace_per_environment boolean DEFAULT true NOT NULL,
    management_project_id integer,
    cleanup_status smallint DEFAULT 1 NOT NULL,
    cleanup_status_reason text
);

CREATE TABLE clusters_applications_cert_managers (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    status integer NOT NULL,
    version character varying NOT NULL,
    email character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status_reason text
);

CREATE SEQUENCE clusters_applications_cert_managers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_cert_managers_id_seq OWNED BY clusters_applications_cert_managers.id;

CREATE TABLE clusters_applications_cilium (
    id bigint NOT NULL,
    cluster_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status integer NOT NULL,
    status_reason text
);

CREATE SEQUENCE clusters_applications_cilium_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_cilium_id_seq OWNED BY clusters_applications_cilium.id;

CREATE TABLE clusters_applications_crossplane (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    cluster_id bigint NOT NULL,
    status integer NOT NULL,
    version character varying(255) NOT NULL,
    stack character varying(255) NOT NULL,
    status_reason text
);

CREATE SEQUENCE clusters_applications_crossplane_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_crossplane_id_seq OWNED BY clusters_applications_crossplane.id;

CREATE TABLE clusters_applications_elastic_stacks (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    cluster_id bigint NOT NULL,
    status integer NOT NULL,
    version character varying(255) NOT NULL,
    status_reason text
);

CREATE SEQUENCE clusters_applications_elastic_stacks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_elastic_stacks_id_seq OWNED BY clusters_applications_elastic_stacks.id;

CREATE TABLE clusters_applications_fluentd (
    id bigint NOT NULL,
    protocol smallint NOT NULL,
    status integer NOT NULL,
    port integer NOT NULL,
    cluster_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version character varying(255) NOT NULL,
    host character varying(255) NOT NULL,
    status_reason text,
    waf_log_enabled boolean DEFAULT true NOT NULL,
    cilium_log_enabled boolean DEFAULT true NOT NULL
);

CREATE SEQUENCE clusters_applications_fluentd_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_fluentd_id_seq OWNED BY clusters_applications_fluentd.id;

CREATE TABLE clusters_applications_helm (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer NOT NULL,
    version character varying NOT NULL,
    status_reason text,
    encrypted_ca_key text,
    encrypted_ca_key_iv text,
    ca_cert text
);

CREATE SEQUENCE clusters_applications_helm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_helm_id_seq OWNED BY clusters_applications_helm.id;

CREATE TABLE clusters_applications_ingress (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer NOT NULL,
    ingress_type integer NOT NULL,
    version character varying NOT NULL,
    cluster_ip character varying,
    status_reason text,
    external_ip character varying,
    external_hostname character varying,
    modsecurity_enabled boolean,
    modsecurity_mode smallint DEFAULT 0 NOT NULL
);

CREATE SEQUENCE clusters_applications_ingress_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_ingress_id_seq OWNED BY clusters_applications_ingress.id;

CREATE TABLE clusters_applications_jupyter (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    oauth_application_id integer,
    status integer NOT NULL,
    version character varying NOT NULL,
    hostname character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status_reason text
);

CREATE SEQUENCE clusters_applications_jupyter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_jupyter_id_seq OWNED BY clusters_applications_jupyter.id;

CREATE TABLE clusters_applications_knative (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status integer NOT NULL,
    version character varying NOT NULL,
    hostname character varying,
    status_reason text,
    external_ip character varying,
    external_hostname character varying
);

CREATE SEQUENCE clusters_applications_knative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_knative_id_seq OWNED BY clusters_applications_knative.id;

CREATE TABLE clusters_applications_prometheus (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    status integer NOT NULL,
    version character varying NOT NULL,
    status_reason text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    last_update_started_at timestamp with time zone,
    encrypted_alert_manager_token character varying,
    encrypted_alert_manager_token_iv character varying,
    healthy boolean
);

CREATE SEQUENCE clusters_applications_prometheus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_prometheus_id_seq OWNED BY clusters_applications_prometheus.id;

CREATE TABLE clusters_applications_runners (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    runner_id integer,
    status integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version character varying NOT NULL,
    status_reason text,
    privileged boolean DEFAULT true NOT NULL
);

CREATE SEQUENCE clusters_applications_runners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_applications_runners_id_seq OWNED BY clusters_applications_runners.id;

CREATE SEQUENCE clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_id_seq OWNED BY clusters.id;

CREATE TABLE clusters_kubernetes_namespaces (
    id bigint NOT NULL,
    cluster_id integer NOT NULL,
    project_id integer,
    cluster_project_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    encrypted_service_account_token text,
    encrypted_service_account_token_iv character varying,
    namespace character varying NOT NULL,
    service_account_name character varying,
    environment_id bigint
);

CREATE SEQUENCE clusters_kubernetes_namespaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE clusters_kubernetes_namespaces_id_seq OWNED BY clusters_kubernetes_namespaces.id;

CREATE TABLE commit_user_mentions (
    id bigint NOT NULL,
    note_id integer NOT NULL,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[],
    commit_id character varying NOT NULL
);

CREATE SEQUENCE commit_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE commit_user_mentions_id_seq OWNED BY commit_user_mentions.id;

CREATE TABLE compliance_management_frameworks (
    id bigint NOT NULL,
    group_id bigint,
    name text NOT NULL,
    description text NOT NULL,
    color text NOT NULL,
    namespace_id integer NOT NULL,
    CONSTRAINT check_08cd34b2c2 CHECK ((char_length(color) <= 10)),
    CONSTRAINT check_1617e0b87e CHECK ((char_length(description) <= 255)),
    CONSTRAINT check_ab00bc2193 CHECK ((char_length(name) <= 255))
);

CREATE SEQUENCE compliance_management_frameworks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE compliance_management_frameworks_id_seq OWNED BY compliance_management_frameworks.id;

CREATE TABLE container_expiration_policies (
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    next_run_at timestamp with time zone,
    name_regex character varying(255),
    cadence character varying(12) DEFAULT '1d'::character varying NOT NULL,
    older_than character varying(12) DEFAULT '90d'::character varying,
    keep_n integer DEFAULT 10,
    enabled boolean DEFAULT true NOT NULL,
    name_regex_keep text,
    CONSTRAINT container_expiration_policies_name_regex_keep CHECK ((char_length(name_regex_keep) <= 255))
);

CREATE TABLE container_repositories (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status smallint,
    expiration_policy_started_at timestamp with time zone
);

CREATE SEQUENCE container_repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE container_repositories_id_seq OWNED BY container_repositories.id;

CREATE TABLE conversational_development_index_metrics (
    id integer NOT NULL,
    leader_issues double precision NOT NULL,
    instance_issues double precision NOT NULL,
    leader_notes double precision NOT NULL,
    instance_notes double precision NOT NULL,
    leader_milestones double precision NOT NULL,
    instance_milestones double precision NOT NULL,
    leader_boards double precision NOT NULL,
    instance_boards double precision NOT NULL,
    leader_merge_requests double precision NOT NULL,
    instance_merge_requests double precision NOT NULL,
    leader_ci_pipelines double precision NOT NULL,
    instance_ci_pipelines double precision NOT NULL,
    leader_environments double precision NOT NULL,
    instance_environments double precision NOT NULL,
    leader_deployments double precision NOT NULL,
    instance_deployments double precision NOT NULL,
    leader_projects_prometheus_active double precision NOT NULL,
    instance_projects_prometheus_active double precision NOT NULL,
    leader_service_desk_issues double precision NOT NULL,
    instance_service_desk_issues double precision NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    percentage_boards double precision DEFAULT 0.0 NOT NULL,
    percentage_ci_pipelines double precision DEFAULT 0.0 NOT NULL,
    percentage_deployments double precision DEFAULT 0.0 NOT NULL,
    percentage_environments double precision DEFAULT 0.0 NOT NULL,
    percentage_issues double precision DEFAULT 0.0 NOT NULL,
    percentage_merge_requests double precision DEFAULT 0.0 NOT NULL,
    percentage_milestones double precision DEFAULT 0.0 NOT NULL,
    percentage_notes double precision DEFAULT 0.0 NOT NULL,
    percentage_projects_prometheus_active double precision DEFAULT 0.0 NOT NULL,
    percentage_service_desk_issues double precision DEFAULT 0.0 NOT NULL
);

CREATE SEQUENCE conversational_development_index_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE conversational_development_index_metrics_id_seq OWNED BY conversational_development_index_metrics.id;

CREATE TABLE csv_issue_imports (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE csv_issue_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE csv_issue_imports_id_seq OWNED BY csv_issue_imports.id;

CREATE TABLE custom_emoji (
    id bigint NOT NULL,
    namespace_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    file text NOT NULL,
    external boolean DEFAULT true NOT NULL,
    CONSTRAINT check_8c586dd507 CHECK ((char_length(name) <= 36)),
    CONSTRAINT check_dd5d60f1fb CHECK ((char_length(file) <= 255))
);

CREATE SEQUENCE custom_emoji_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE custom_emoji_id_seq OWNED BY custom_emoji.id;

CREATE TABLE dast_scanner_profiles (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    spider_timeout smallint,
    target_timeout smallint,
    name text NOT NULL,
    scan_type smallint DEFAULT 1 NOT NULL,
    use_ajax_spider boolean DEFAULT false NOT NULL,
    show_debug_messages boolean DEFAULT false NOT NULL,
    CONSTRAINT check_568568fabf CHECK ((char_length(name) <= 255))
);

CREATE SEQUENCE dast_scanner_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE dast_scanner_profiles_id_seq OWNED BY dast_scanner_profiles.id;

CREATE TABLE dast_site_profiles (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    dast_site_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    CONSTRAINT check_6cfab17b48 CHECK ((char_length(name) <= 255))
);

CREATE SEQUENCE dast_site_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE dast_site_profiles_id_seq OWNED BY dast_site_profiles.id;

CREATE TABLE dast_site_tokens (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    expired_at timestamp with time zone,
    token text NOT NULL,
    url text NOT NULL,
    CONSTRAINT check_02a6bf20a7 CHECK ((char_length(token) <= 255)),
    CONSTRAINT check_69ab8622a6 CHECK ((char_length(url) <= 255))
);

CREATE SEQUENCE dast_site_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE dast_site_tokens_id_seq OWNED BY dast_site_tokens.id;

CREATE TABLE dast_site_validations (
    id bigint NOT NULL,
    dast_site_token_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    validation_started_at timestamp with time zone,
    validation_passed_at timestamp with time zone,
    validation_failed_at timestamp with time zone,
    validation_last_retried_at timestamp with time zone,
    validation_strategy smallint NOT NULL,
    url_base text NOT NULL,
    url_path text NOT NULL,
    state text DEFAULT 'pending'::text NOT NULL,
    CONSTRAINT check_13b34efe4b CHECK ((char_length(url_path) <= 255)),
    CONSTRAINT check_283be72e9b CHECK ((char_length(state) <= 255)),
    CONSTRAINT check_cd3b538210 CHECK ((char_length(url_base) <= 255))
);

CREATE SEQUENCE dast_site_validations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE dast_site_validations_id_seq OWNED BY dast_site_validations.id;

CREATE TABLE dast_sites (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    url text NOT NULL,
    dast_site_validation_id bigint,
    CONSTRAINT check_46df8b449c CHECK ((char_length(url) <= 255))
);

CREATE SEQUENCE dast_sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE dast_sites_id_seq OWNED BY dast_sites.id;

CREATE TABLE dependency_proxy_blobs (
    id integer NOT NULL,
    group_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    size bigint,
    file_store integer,
    file_name character varying NOT NULL,
    file text NOT NULL
);

CREATE SEQUENCE dependency_proxy_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE dependency_proxy_blobs_id_seq OWNED BY dependency_proxy_blobs.id;

CREATE TABLE dependency_proxy_group_settings (
    id integer NOT NULL,
    group_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    enabled boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE dependency_proxy_group_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE dependency_proxy_group_settings_id_seq OWNED BY dependency_proxy_group_settings.id;

CREATE TABLE deploy_keys_projects (
    id integer NOT NULL,
    deploy_key_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    can_push boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE deploy_keys_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE deploy_keys_projects_id_seq OWNED BY deploy_keys_projects.id;

CREATE TABLE deploy_tokens (
    id integer NOT NULL,
    revoked boolean DEFAULT false,
    read_repository boolean DEFAULT false NOT NULL,
    read_registry boolean DEFAULT false NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL,
    name character varying NOT NULL,
    token character varying,
    username character varying,
    token_encrypted character varying(255),
    deploy_token_type smallint DEFAULT 2 NOT NULL,
    write_registry boolean DEFAULT false NOT NULL,
    read_package_registry boolean DEFAULT false NOT NULL,
    write_package_registry boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE deploy_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE deploy_tokens_id_seq OWNED BY deploy_tokens.id;

CREATE TABLE deployment_clusters (
    deployment_id integer NOT NULL,
    cluster_id integer NOT NULL,
    kubernetes_namespace character varying(255)
);

CREATE TABLE deployment_merge_requests (
    deployment_id integer NOT NULL,
    merge_request_id integer NOT NULL,
    environment_id integer
);

CREATE TABLE deployments (
    id integer NOT NULL,
    iid integer NOT NULL,
    project_id integer NOT NULL,
    environment_id integer NOT NULL,
    ref character varying NOT NULL,
    tag boolean NOT NULL,
    sha character varying NOT NULL,
    user_id integer,
    deployable_id integer,
    deployable_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    on_stop character varying,
    status smallint NOT NULL,
    finished_at timestamp with time zone,
    cluster_id integer
);

CREATE SEQUENCE deployments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE deployments_id_seq OWNED BY deployments.id;

CREATE TABLE description_versions (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    issue_id integer,
    merge_request_id integer,
    epic_id integer,
    description text,
    deleted_at timestamp with time zone
);

CREATE SEQUENCE description_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE description_versions_id_seq OWNED BY description_versions.id;

CREATE TABLE design_management_designs (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    issue_id integer,
    filename character varying NOT NULL,
    relative_position integer,
    CONSTRAINT check_07155e2715 CHECK ((char_length((filename)::text) <= 255))
);

CREATE SEQUENCE design_management_designs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE design_management_designs_id_seq OWNED BY design_management_designs.id;

CREATE TABLE design_management_designs_versions (
    id bigint NOT NULL,
    design_id bigint NOT NULL,
    version_id bigint NOT NULL,
    event smallint DEFAULT 0 NOT NULL,
    image_v432x230 character varying(255)
);

CREATE SEQUENCE design_management_designs_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE design_management_designs_versions_id_seq OWNED BY design_management_designs_versions.id;

CREATE TABLE design_management_versions (
    id bigint NOT NULL,
    sha bytea NOT NULL,
    issue_id bigint,
    created_at timestamp with time zone NOT NULL,
    author_id integer
);

CREATE SEQUENCE design_management_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE design_management_versions_id_seq OWNED BY design_management_versions.id;

CREATE TABLE design_user_mentions (
    id bigint NOT NULL,
    design_id integer NOT NULL,
    note_id integer NOT NULL,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[]
);

CREATE SEQUENCE design_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE design_user_mentions_id_seq OWNED BY design_user_mentions.id;

CREATE TABLE diff_note_positions (
    id bigint NOT NULL,
    note_id bigint NOT NULL,
    old_line integer,
    new_line integer,
    diff_content_type smallint NOT NULL,
    diff_type smallint NOT NULL,
    line_code character varying(255) NOT NULL,
    base_sha bytea NOT NULL,
    start_sha bytea NOT NULL,
    head_sha bytea NOT NULL,
    old_path text NOT NULL,
    new_path text NOT NULL
);

CREATE SEQUENCE diff_note_positions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE diff_note_positions_id_seq OWNED BY diff_note_positions.id;

CREATE TABLE draft_notes (
    id bigint NOT NULL,
    merge_request_id integer NOT NULL,
    author_id integer NOT NULL,
    resolve_discussion boolean DEFAULT false NOT NULL,
    discussion_id character varying,
    note text NOT NULL,
    "position" text,
    original_position text,
    change_position text,
    commit_id bytea
);

CREATE SEQUENCE draft_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE draft_notes_id_seq OWNED BY draft_notes.id;

CREATE TABLE elastic_reindexing_tasks (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    documents_count integer,
    state smallint DEFAULT 0 NOT NULL,
    in_progress boolean DEFAULT true NOT NULL,
    index_name_from text,
    index_name_to text,
    elastic_task text,
    error_message text,
    documents_count_target integer,
    delete_original_index_at timestamp with time zone,
    CONSTRAINT check_04151aca42 CHECK ((char_length(index_name_from) <= 255)),
    CONSTRAINT check_7f64acda8e CHECK ((char_length(error_message) <= 255)),
    CONSTRAINT check_85ebff7124 CHECK ((char_length(index_name_to) <= 255)),
    CONSTRAINT check_942e5aae53 CHECK ((char_length(elastic_task) <= 255))
);

CREATE SEQUENCE elastic_reindexing_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE elastic_reindexing_tasks_id_seq OWNED BY elastic_reindexing_tasks.id;

CREATE TABLE elasticsearch_indexed_namespaces (
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    namespace_id integer
);

CREATE TABLE elasticsearch_indexed_projects (
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer
);

CREATE TABLE emails (
    id integer NOT NULL,
    user_id integer NOT NULL,
    email character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone
);

CREATE SEQUENCE emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE emails_id_seq OWNED BY emails.id;

CREATE TABLE environments (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    external_url character varying,
    environment_type character varying,
    state character varying DEFAULT 'available'::character varying NOT NULL,
    slug character varying NOT NULL,
    auto_stop_at timestamp with time zone
);

CREATE SEQUENCE environments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE environments_id_seq OWNED BY environments.id;

CREATE TABLE epic_issues (
    id integer NOT NULL,
    epic_id integer NOT NULL,
    issue_id integer NOT NULL,
    relative_position integer
);

CREATE SEQUENCE epic_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE epic_issues_id_seq OWNED BY epic_issues.id;

CREATE TABLE epic_metrics (
    id integer NOT NULL,
    epic_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE epic_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE epic_metrics_id_seq OWNED BY epic_metrics.id;

CREATE TABLE epic_user_mentions (
    id bigint NOT NULL,
    epic_id integer NOT NULL,
    note_id integer,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[]
);

CREATE SEQUENCE epic_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE epic_user_mentions_id_seq OWNED BY epic_user_mentions.id;

CREATE TABLE epics (
    id integer NOT NULL,
    group_id integer NOT NULL,
    author_id integer NOT NULL,
    assignee_id integer,
    iid integer NOT NULL,
    cached_markdown_version integer,
    updated_by_id integer,
    last_edited_by_id integer,
    lock_version integer DEFAULT 0,
    start_date date,
    end_date date,
    last_edited_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying NOT NULL,
    title_html character varying NOT NULL,
    description text,
    description_html text,
    start_date_sourcing_milestone_id integer,
    due_date_sourcing_milestone_id integer,
    start_date_fixed date,
    due_date_fixed date,
    start_date_is_fixed boolean,
    due_date_is_fixed boolean,
    closed_by_id integer,
    closed_at timestamp without time zone,
    parent_id integer,
    relative_position integer,
    state_id smallint DEFAULT 1 NOT NULL,
    start_date_sourcing_epic_id integer,
    due_date_sourcing_epic_id integer,
    confidential boolean DEFAULT false NOT NULL,
    external_key character varying(255),
    CONSTRAINT check_fcfb4a93ff CHECK ((lock_version IS NOT NULL))
);

CREATE SEQUENCE epics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE epics_id_seq OWNED BY epics.id;

CREATE TABLE events (
    id integer NOT NULL,
    project_id integer,
    author_id integer NOT NULL,
    target_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    action smallint NOT NULL,
    target_type character varying,
    group_id bigint,
    fingerprint bytea,
    CONSTRAINT check_97e06e05ad CHECK ((octet_length(fingerprint) <= 128))
);

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE events_id_seq OWNED BY events.id;

CREATE TABLE evidences (
    id bigint NOT NULL,
    release_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    summary_sha bytea,
    summary jsonb DEFAULT '{}'::jsonb NOT NULL
);

CREATE SEQUENCE evidences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE evidences_id_seq OWNED BY evidences.id;

CREATE TABLE experiment_users (
    id bigint NOT NULL,
    experiment_id bigint NOT NULL,
    user_id bigint NOT NULL,
    group_type smallint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE experiment_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE experiment_users_id_seq OWNED BY experiment_users.id;

CREATE TABLE experiments (
    id bigint NOT NULL,
    name text NOT NULL,
    CONSTRAINT check_e2dda25ed0 CHECK ((char_length(name) <= 255))
);

CREATE SEQUENCE experiments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE experiments_id_seq OWNED BY experiments.id;

CREATE TABLE external_pull_requests (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    pull_request_iid integer NOT NULL,
    status smallint NOT NULL,
    source_branch character varying(255) NOT NULL,
    target_branch character varying(255) NOT NULL,
    source_repository character varying(255) NOT NULL,
    target_repository character varying(255) NOT NULL,
    source_sha bytea NOT NULL,
    target_sha bytea NOT NULL
);

CREATE SEQUENCE external_pull_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE external_pull_requests_id_seq OWNED BY external_pull_requests.id;

CREATE TABLE feature_gates (
    id integer NOT NULL,
    feature_key character varying NOT NULL,
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE feature_gates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE feature_gates_id_seq OWNED BY feature_gates.id;

CREATE TABLE features (
    id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE features_id_seq OWNED BY features.id;

CREATE TABLE fork_network_members (
    id integer NOT NULL,
    fork_network_id integer NOT NULL,
    project_id integer NOT NULL,
    forked_from_project_id integer
);

CREATE SEQUENCE fork_network_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE fork_network_members_id_seq OWNED BY fork_network_members.id;

CREATE TABLE fork_networks (
    id integer NOT NULL,
    root_project_id integer,
    deleted_root_project_name character varying
);

CREATE SEQUENCE fork_networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE fork_networks_id_seq OWNED BY fork_networks.id;

CREATE TABLE geo_cache_invalidation_events (
    id bigint NOT NULL,
    key character varying NOT NULL
);

CREATE SEQUENCE geo_cache_invalidation_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_cache_invalidation_events_id_seq OWNED BY geo_cache_invalidation_events.id;

CREATE TABLE geo_container_repository_updated_events (
    id bigint NOT NULL,
    container_repository_id integer NOT NULL
);

CREATE SEQUENCE geo_container_repository_updated_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_container_repository_updated_events_id_seq OWNED BY geo_container_repository_updated_events.id;

CREATE TABLE geo_event_log (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    repository_updated_event_id bigint,
    repository_deleted_event_id bigint,
    repository_renamed_event_id bigint,
    repositories_changed_event_id bigint,
    repository_created_event_id bigint,
    hashed_storage_migrated_event_id bigint,
    lfs_object_deleted_event_id bigint,
    hashed_storage_attachments_event_id bigint,
    upload_deleted_event_id bigint,
    job_artifact_deleted_event_id bigint,
    reset_checksum_event_id bigint,
    cache_invalidation_event_id bigint,
    container_repository_updated_event_id bigint,
    geo_event_id integer
);

CREATE SEQUENCE geo_event_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_event_log_id_seq OWNED BY geo_event_log.id;

CREATE TABLE geo_events (
    id bigint NOT NULL,
    replicable_name character varying(255) NOT NULL,
    event_name character varying(255) NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE geo_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_events_id_seq OWNED BY geo_events.id;

CREATE TABLE geo_hashed_storage_attachments_events (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    old_attachments_path text NOT NULL,
    new_attachments_path text NOT NULL
);

CREATE SEQUENCE geo_hashed_storage_attachments_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_hashed_storage_attachments_events_id_seq OWNED BY geo_hashed_storage_attachments_events.id;

CREATE TABLE geo_hashed_storage_migrated_events (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    repository_storage_name text NOT NULL,
    old_disk_path text NOT NULL,
    new_disk_path text NOT NULL,
    old_wiki_disk_path text NOT NULL,
    new_wiki_disk_path text NOT NULL,
    old_storage_version smallint,
    new_storage_version smallint NOT NULL,
    old_design_disk_path text,
    new_design_disk_path text
);

CREATE SEQUENCE geo_hashed_storage_migrated_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_hashed_storage_migrated_events_id_seq OWNED BY geo_hashed_storage_migrated_events.id;

CREATE TABLE geo_job_artifact_deleted_events (
    id bigint NOT NULL,
    job_artifact_id integer NOT NULL,
    file_path character varying NOT NULL
);

CREATE SEQUENCE geo_job_artifact_deleted_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_job_artifact_deleted_events_id_seq OWNED BY geo_job_artifact_deleted_events.id;

CREATE TABLE geo_lfs_object_deleted_events (
    id bigint NOT NULL,
    lfs_object_id integer NOT NULL,
    oid character varying NOT NULL,
    file_path character varying NOT NULL
);

CREATE SEQUENCE geo_lfs_object_deleted_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_lfs_object_deleted_events_id_seq OWNED BY geo_lfs_object_deleted_events.id;

CREATE TABLE geo_node_namespace_links (
    id integer NOT NULL,
    geo_node_id integer NOT NULL,
    namespace_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE geo_node_namespace_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_node_namespace_links_id_seq OWNED BY geo_node_namespace_links.id;

CREATE TABLE geo_node_statuses (
    id integer NOT NULL,
    geo_node_id integer NOT NULL,
    db_replication_lag_seconds integer,
    repositories_synced_count integer,
    repositories_failed_count integer,
    lfs_objects_count integer,
    lfs_objects_synced_count integer,
    lfs_objects_failed_count integer,
    attachments_count integer,
    attachments_synced_count integer,
    attachments_failed_count integer,
    last_event_id integer,
    last_event_date timestamp without time zone,
    cursor_last_event_id integer,
    cursor_last_event_date timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_successful_status_check_at timestamp without time zone,
    status_message character varying,
    replication_slots_count integer,
    replication_slots_used_count integer,
    replication_slots_max_retained_wal_bytes bigint,
    wikis_synced_count integer,
    wikis_failed_count integer,
    job_artifacts_count integer,
    job_artifacts_synced_count integer,
    job_artifacts_failed_count integer,
    version character varying,
    revision character varying,
    repositories_verified_count integer,
    repositories_verification_failed_count integer,
    wikis_verified_count integer,
    wikis_verification_failed_count integer,
    lfs_objects_synced_missing_on_primary_count integer,
    job_artifacts_synced_missing_on_primary_count integer,
    attachments_synced_missing_on_primary_count integer,
    repositories_checksummed_count integer,
    repositories_checksum_failed_count integer,
    repositories_checksum_mismatch_count integer,
    wikis_checksummed_count integer,
    wikis_checksum_failed_count integer,
    wikis_checksum_mismatch_count integer,
    storage_configuration_digest bytea,
    repositories_retrying_verification_count integer,
    wikis_retrying_verification_count integer,
    projects_count integer,
    container_repositories_count integer,
    container_repositories_synced_count integer,
    container_repositories_failed_count integer,
    container_repositories_registry_count integer,
    design_repositories_count integer,
    design_repositories_synced_count integer,
    design_repositories_failed_count integer,
    design_repositories_registry_count integer,
    status jsonb DEFAULT '{}'::jsonb NOT NULL
);

CREATE SEQUENCE geo_node_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_node_statuses_id_seq OWNED BY geo_node_statuses.id;

CREATE TABLE geo_nodes (
    id integer NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    oauth_application_id integer,
    enabled boolean DEFAULT true NOT NULL,
    access_key character varying,
    encrypted_secret_access_key character varying,
    encrypted_secret_access_key_iv character varying,
    clone_url_prefix character varying,
    files_max_capacity integer DEFAULT 10 NOT NULL,
    repos_max_capacity integer DEFAULT 25 NOT NULL,
    url character varying NOT NULL,
    selective_sync_type character varying,
    selective_sync_shards text,
    verification_max_capacity integer DEFAULT 100 NOT NULL,
    minimum_reverification_interval integer DEFAULT 7 NOT NULL,
    internal_url character varying,
    name character varying NOT NULL,
    container_repositories_max_capacity integer DEFAULT 10 NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    sync_object_storage boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE geo_nodes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_nodes_id_seq OWNED BY geo_nodes.id;

CREATE TABLE geo_repositories_changed_events (
    id bigint NOT NULL,
    geo_node_id integer NOT NULL
);

CREATE SEQUENCE geo_repositories_changed_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_repositories_changed_events_id_seq OWNED BY geo_repositories_changed_events.id;

CREATE TABLE geo_repository_created_events (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    repository_storage_name text NOT NULL,
    repo_path text NOT NULL,
    wiki_path text,
    project_name text NOT NULL
);

CREATE SEQUENCE geo_repository_created_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_repository_created_events_id_seq OWNED BY geo_repository_created_events.id;

CREATE TABLE geo_repository_deleted_events (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    repository_storage_name text NOT NULL,
    deleted_path text NOT NULL,
    deleted_wiki_path text,
    deleted_project_name text NOT NULL
);

CREATE SEQUENCE geo_repository_deleted_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_repository_deleted_events_id_seq OWNED BY geo_repository_deleted_events.id;

CREATE TABLE geo_repository_renamed_events (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    repository_storage_name text NOT NULL,
    old_path_with_namespace text NOT NULL,
    new_path_with_namespace text NOT NULL,
    old_wiki_path_with_namespace text NOT NULL,
    new_wiki_path_with_namespace text NOT NULL,
    old_path text NOT NULL,
    new_path text NOT NULL
);

CREATE SEQUENCE geo_repository_renamed_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_repository_renamed_events_id_seq OWNED BY geo_repository_renamed_events.id;

CREATE TABLE geo_repository_updated_events (
    id bigint NOT NULL,
    branches_affected integer NOT NULL,
    tags_affected integer NOT NULL,
    project_id integer NOT NULL,
    source smallint NOT NULL,
    new_branch boolean DEFAULT false NOT NULL,
    remove_branch boolean DEFAULT false NOT NULL,
    ref text
);

CREATE SEQUENCE geo_repository_updated_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_repository_updated_events_id_seq OWNED BY geo_repository_updated_events.id;

CREATE TABLE geo_reset_checksum_events (
    id bigint NOT NULL,
    project_id integer NOT NULL
);

CREATE SEQUENCE geo_reset_checksum_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_reset_checksum_events_id_seq OWNED BY geo_reset_checksum_events.id;

CREATE TABLE geo_upload_deleted_events (
    id bigint NOT NULL,
    upload_id integer NOT NULL,
    file_path character varying NOT NULL,
    model_id integer NOT NULL,
    model_type character varying NOT NULL,
    uploader character varying NOT NULL
);

CREATE SEQUENCE geo_upload_deleted_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE geo_upload_deleted_events_id_seq OWNED BY geo_upload_deleted_events.id;

CREATE TABLE gitlab_subscription_histories (
    id bigint NOT NULL,
    gitlab_subscription_created_at timestamp with time zone,
    gitlab_subscription_updated_at timestamp with time zone,
    start_date date,
    end_date date,
    trial_ends_on date,
    namespace_id integer,
    hosted_plan_id integer,
    max_seats_used integer,
    seats integer,
    trial boolean,
    change_type smallint,
    gitlab_subscription_id bigint NOT NULL,
    created_at timestamp with time zone,
    trial_starts_on date,
    auto_renew boolean
);

CREATE SEQUENCE gitlab_subscription_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE gitlab_subscription_histories_id_seq OWNED BY gitlab_subscription_histories.id;

CREATE TABLE gitlab_subscriptions (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    start_date date,
    end_date date,
    trial_ends_on date,
    namespace_id integer,
    hosted_plan_id integer,
    max_seats_used integer DEFAULT 0,
    seats integer DEFAULT 0,
    trial boolean DEFAULT false,
    trial_starts_on date,
    auto_renew boolean,
    seats_in_use integer DEFAULT 0 NOT NULL,
    seats_owed integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE gitlab_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE gitlab_subscriptions_id_seq OWNED BY gitlab_subscriptions.id;

CREATE TABLE gpg_key_subkeys (
    id integer NOT NULL,
    gpg_key_id integer NOT NULL,
    keyid bytea,
    fingerprint bytea
);

CREATE SEQUENCE gpg_key_subkeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE gpg_key_subkeys_id_seq OWNED BY gpg_key_subkeys.id;

CREATE TABLE gpg_keys (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    user_id integer,
    primary_keyid bytea,
    fingerprint bytea,
    key text
);

CREATE SEQUENCE gpg_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE gpg_keys_id_seq OWNED BY gpg_keys.id;

CREATE TABLE gpg_signatures (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer,
    gpg_key_id integer,
    commit_sha bytea,
    gpg_key_primary_keyid bytea,
    gpg_key_user_name text,
    gpg_key_user_email text,
    verification_status smallint DEFAULT 0 NOT NULL,
    gpg_key_subkey_id integer
);

CREATE SEQUENCE gpg_signatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE gpg_signatures_id_seq OWNED BY gpg_signatures.id;

CREATE TABLE grafana_integrations (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    encrypted_token character varying(255) NOT NULL,
    encrypted_token_iv character varying(255) NOT NULL,
    grafana_url character varying(1024) NOT NULL,
    enabled boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE grafana_integrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE grafana_integrations_id_seq OWNED BY grafana_integrations.id;

CREATE TABLE group_custom_attributes (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    group_id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);

CREATE SEQUENCE group_custom_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE group_custom_attributes_id_seq OWNED BY group_custom_attributes.id;

CREATE TABLE group_deletion_schedules (
    group_id bigint NOT NULL,
    user_id bigint NOT NULL,
    marked_for_deletion_on date NOT NULL
);

CREATE TABLE group_deploy_keys (
    id bigint NOT NULL,
    user_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    last_used_at timestamp with time zone,
    expires_at timestamp with time zone,
    key text NOT NULL,
    title text,
    fingerprint text NOT NULL,
    fingerprint_sha256 bytea,
    CONSTRAINT check_cc0365908d CHECK ((char_length(title) <= 255)),
    CONSTRAINT check_e4526dcf91 CHECK ((char_length(fingerprint) <= 255)),
    CONSTRAINT check_f58fa0a0f7 CHECK ((char_length(key) <= 4096))
);

CREATE TABLE group_deploy_keys_groups (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    group_id bigint NOT NULL,
    group_deploy_key_id bigint NOT NULL,
    can_push boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE group_deploy_keys_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE group_deploy_keys_groups_id_seq OWNED BY group_deploy_keys_groups.id;

CREATE SEQUENCE group_deploy_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE group_deploy_keys_id_seq OWNED BY group_deploy_keys.id;

CREATE TABLE group_deploy_tokens (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    group_id bigint NOT NULL,
    deploy_token_id bigint NOT NULL
);

CREATE SEQUENCE group_deploy_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE group_deploy_tokens_id_seq OWNED BY group_deploy_tokens.id;

CREATE TABLE group_group_links (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    shared_group_id bigint NOT NULL,
    shared_with_group_id bigint NOT NULL,
    expires_at date,
    group_access smallint DEFAULT 30 NOT NULL
);

CREATE SEQUENCE group_group_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE group_group_links_id_seq OWNED BY group_group_links.id;

CREATE TABLE group_import_states (
    group_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    jid text,
    last_error text,
    user_id bigint,
    CONSTRAINT check_87b58f6b30 CHECK ((char_length(last_error) <= 255)),
    CONSTRAINT check_96558fff96 CHECK ((char_length(jid) <= 100))
);

CREATE SEQUENCE group_import_states_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE group_import_states_group_id_seq OWNED BY group_import_states.group_id;

CREATE TABLE group_wiki_repositories (
    shard_id bigint NOT NULL,
    group_id bigint NOT NULL,
    disk_path text NOT NULL,
    CONSTRAINT check_07f1c81806 CHECK ((char_length(disk_path) <= 80))
);

CREATE TABLE historical_data (
    id integer NOT NULL,
    date date NOT NULL,
    active_user_count integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE historical_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE historical_data_id_seq OWNED BY historical_data.id;

CREATE TABLE identities (
    id integer NOT NULL,
    extern_uid character varying,
    provider character varying,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    secondary_extern_uid character varying,
    saml_provider_id integer
);

CREATE SEQUENCE identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE identities_id_seq OWNED BY identities.id;

CREATE TABLE import_export_uploads (
    id integer NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer,
    import_file text,
    export_file text,
    group_id bigint
);

CREATE SEQUENCE import_export_uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE import_export_uploads_id_seq OWNED BY import_export_uploads.id;

CREATE TABLE import_failures (
    id bigint NOT NULL,
    relation_index integer,
    project_id bigint,
    created_at timestamp with time zone NOT NULL,
    relation_key character varying(64),
    exception_class character varying(128),
    correlation_id_value character varying(128),
    exception_message character varying(255),
    retry_count integer,
    group_id integer,
    source character varying(128)
);

CREATE SEQUENCE import_failures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE import_failures_id_seq OWNED BY import_failures.id;

CREATE TABLE index_statuses (
    id integer NOT NULL,
    project_id integer NOT NULL,
    indexed_at timestamp without time zone,
    note text,
    last_commit character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_wiki_commit bytea,
    wiki_indexed_at timestamp with time zone
);

CREATE SEQUENCE index_statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE index_statuses_id_seq OWNED BY index_statuses.id;

CREATE TABLE insights (
    id integer NOT NULL,
    namespace_id integer NOT NULL,
    project_id integer NOT NULL
);

CREATE SEQUENCE insights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE insights_id_seq OWNED BY insights.id;

CREATE TABLE internal_ids (
    id bigint NOT NULL,
    project_id integer,
    usage integer NOT NULL,
    last_value integer NOT NULL,
    namespace_id integer
);

CREATE SEQUENCE internal_ids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE internal_ids_id_seq OWNED BY internal_ids.id;

CREATE TABLE ip_restrictions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    range character varying NOT NULL
);

CREATE SEQUENCE ip_restrictions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ip_restrictions_id_seq OWNED BY ip_restrictions.id;

CREATE TABLE issuable_severities (
    id bigint NOT NULL,
    issue_id bigint NOT NULL,
    severity smallint DEFAULT 0 NOT NULL
);

CREATE SEQUENCE issuable_severities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issuable_severities_id_seq OWNED BY issuable_severities.id;

CREATE TABLE issuable_slas (
    id bigint NOT NULL,
    issue_id bigint NOT NULL,
    due_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE issuable_slas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issuable_slas_id_seq OWNED BY issuable_slas.id;

CREATE TABLE issue_assignees (
    user_id integer NOT NULL,
    issue_id integer NOT NULL
);

CREATE TABLE issue_email_participants (
    id bigint NOT NULL,
    issue_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    email text NOT NULL,
    CONSTRAINT check_2c321d408d CHECK ((char_length(email) <= 255))
);

CREATE SEQUENCE issue_email_participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issue_email_participants_id_seq OWNED BY issue_email_participants.id;

CREATE TABLE issue_links (
    id integer NOT NULL,
    source_id integer NOT NULL,
    target_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    link_type smallint DEFAULT 0 NOT NULL
);

CREATE SEQUENCE issue_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issue_links_id_seq OWNED BY issue_links.id;

CREATE TABLE issue_metrics (
    id integer NOT NULL,
    issue_id integer NOT NULL,
    first_mentioned_in_commit_at timestamp without time zone,
    first_associated_with_milestone_at timestamp without time zone,
    first_added_to_board_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE issue_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issue_metrics_id_seq OWNED BY issue_metrics.id;

CREATE TABLE issue_tracker_data (
    id bigint NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    encrypted_project_url character varying,
    encrypted_project_url_iv character varying,
    encrypted_issues_url character varying,
    encrypted_issues_url_iv character varying,
    encrypted_new_issue_url character varying,
    encrypted_new_issue_url_iv character varying
);

CREATE SEQUENCE issue_tracker_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issue_tracker_data_id_seq OWNED BY issue_tracker_data.id;

CREATE TABLE issue_user_mentions (
    id bigint NOT NULL,
    issue_id integer NOT NULL,
    note_id integer,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[]
);

CREATE SEQUENCE issue_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issue_user_mentions_id_seq OWNED BY issue_user_mentions.id;

CREATE TABLE issues (
    id integer NOT NULL,
    title character varying,
    author_id integer,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    description text,
    milestone_id integer,
    iid integer,
    updated_by_id integer,
    weight integer,
    confidential boolean DEFAULT false NOT NULL,
    due_date date,
    moved_to_id integer,
    lock_version integer DEFAULT 0,
    title_html text,
    description_html text,
    time_estimate integer,
    relative_position integer,
    service_desk_reply_to character varying,
    cached_markdown_version integer,
    last_edited_at timestamp without time zone,
    last_edited_by_id integer,
    discussion_locked boolean,
    closed_at timestamp with time zone,
    closed_by_id integer,
    state_id smallint DEFAULT 1 NOT NULL,
    duplicated_to_id integer,
    promoted_to_epic_id integer,
    health_status smallint,
    external_key character varying(255),
    sprint_id bigint,
    issue_type smallint DEFAULT 0 NOT NULL,
    blocking_issues_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT check_fba63f706d CHECK ((lock_version IS NOT NULL))
);

CREATE SEQUENCE issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE issues_id_seq OWNED BY issues.id;

CREATE TABLE issues_prometheus_alert_events (
    issue_id bigint NOT NULL,
    prometheus_alert_event_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE TABLE issues_self_managed_prometheus_alert_events (
    issue_id bigint NOT NULL,
    self_managed_prometheus_alert_event_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE TABLE jira_connect_installations (
    id bigint NOT NULL,
    client_key character varying,
    encrypted_shared_secret character varying,
    encrypted_shared_secret_iv character varying,
    base_url character varying
);

CREATE SEQUENCE jira_connect_installations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE jira_connect_installations_id_seq OWNED BY jira_connect_installations.id;

CREATE TABLE jira_connect_subscriptions (
    id bigint NOT NULL,
    jira_connect_installation_id bigint NOT NULL,
    namespace_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE jira_connect_subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE jira_connect_subscriptions_id_seq OWNED BY jira_connect_subscriptions.id;

CREATE TABLE jira_imports (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint,
    label_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    jira_project_xid bigint NOT NULL,
    total_issue_count integer DEFAULT 0 NOT NULL,
    imported_issues_count integer DEFAULT 0 NOT NULL,
    failed_to_import_count integer DEFAULT 0 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    jid character varying(255),
    jira_project_key character varying(255) NOT NULL,
    jira_project_name character varying(255) NOT NULL,
    scheduled_at timestamp with time zone,
    error_message text,
    CONSTRAINT check_9ed451c5b1 CHECK ((char_length(error_message) <= 1000))
);

CREATE SEQUENCE jira_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE jira_imports_id_seq OWNED BY jira_imports.id;

CREATE TABLE jira_tracker_data (
    id bigint NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    encrypted_url character varying,
    encrypted_url_iv character varying,
    encrypted_api_url character varying,
    encrypted_api_url_iv character varying,
    encrypted_username character varying,
    encrypted_username_iv character varying,
    encrypted_password character varying,
    encrypted_password_iv character varying,
    jira_issue_transition_id character varying,
    project_key text,
    issues_enabled boolean DEFAULT false NOT NULL,
    deployment_type smallint DEFAULT 0 NOT NULL,
    CONSTRAINT check_214cf6a48b CHECK ((char_length(project_key) <= 255))
);

CREATE SEQUENCE jira_tracker_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE jira_tracker_data_id_seq OWNED BY jira_tracker_data.id;

CREATE TABLE keys (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    key text,
    title character varying,
    type character varying,
    fingerprint character varying,
    public boolean DEFAULT false NOT NULL,
    last_used_at timestamp without time zone,
    fingerprint_sha256 bytea,
    expires_at timestamp with time zone
);

CREATE SEQUENCE keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE keys_id_seq OWNED BY keys.id;

CREATE TABLE label_links (
    id integer NOT NULL,
    label_id integer,
    target_id integer,
    target_type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE label_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE label_links_id_seq OWNED BY label_links.id;

CREATE TABLE label_priorities (
    id integer NOT NULL,
    project_id integer NOT NULL,
    label_id integer NOT NULL,
    priority integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE label_priorities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE label_priorities_id_seq OWNED BY label_priorities.id;

CREATE TABLE labels (
    id integer NOT NULL,
    title character varying,
    color character varying,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    template boolean DEFAULT false,
    description character varying,
    description_html text,
    type character varying,
    group_id integer,
    cached_markdown_version integer
);

CREATE SEQUENCE labels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE labels_id_seq OWNED BY labels.id;

CREATE TABLE ldap_group_links (
    id integer NOT NULL,
    cn character varying,
    group_access integer NOT NULL,
    group_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    provider character varying,
    filter character varying
);

CREATE SEQUENCE ldap_group_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ldap_group_links_id_seq OWNED BY ldap_group_links.id;

CREATE TABLE lfs_file_locks (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    path character varying(511)
);

CREATE SEQUENCE lfs_file_locks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE lfs_file_locks_id_seq OWNED BY lfs_file_locks.id;

CREATE TABLE lfs_objects (
    id integer NOT NULL,
    oid character varying NOT NULL,
    size bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file character varying,
    file_store integer DEFAULT 1,
    CONSTRAINT check_eecfc5717d CHECK ((file_store IS NOT NULL))
);

CREATE SEQUENCE lfs_objects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE lfs_objects_id_seq OWNED BY lfs_objects.id;

CREATE TABLE lfs_objects_projects (
    id integer NOT NULL,
    lfs_object_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    repository_type smallint
);

CREATE SEQUENCE lfs_objects_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE lfs_objects_projects_id_seq OWNED BY lfs_objects_projects.id;

CREATE TABLE licenses (
    id integer NOT NULL,
    data text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE licenses_id_seq OWNED BY licenses.id;

CREATE TABLE list_user_preferences (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    list_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    collapsed boolean
);

CREATE SEQUENCE list_user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE list_user_preferences_id_seq OWNED BY list_user_preferences.id;

CREATE TABLE lists (
    id integer NOT NULL,
    board_id integer NOT NULL,
    label_id integer,
    list_type integer DEFAULT 1 NOT NULL,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    milestone_id integer,
    max_issue_count integer DEFAULT 0 NOT NULL,
    max_issue_weight integer DEFAULT 0 NOT NULL,
    limit_metric character varying(20)
);

CREATE SEQUENCE lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE lists_id_seq OWNED BY lists.id;

CREATE TABLE members (
    id integer NOT NULL,
    access_level integer NOT NULL,
    source_id integer NOT NULL,
    source_type character varying NOT NULL,
    user_id integer,
    notification_level integer NOT NULL,
    type character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    created_by_id integer,
    invite_email character varying,
    invite_token character varying,
    invite_accepted_at timestamp without time zone,
    requested_at timestamp without time zone,
    expires_at date,
    ldap boolean DEFAULT false NOT NULL,
    override boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE members_id_seq OWNED BY members.id;

CREATE TABLE merge_request_assignees (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    merge_request_id integer NOT NULL,
    created_at timestamp with time zone
);

CREATE SEQUENCE merge_request_assignees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_assignees_id_seq OWNED BY merge_request_assignees.id;

CREATE TABLE merge_request_blocks (
    id bigint NOT NULL,
    blocking_merge_request_id integer NOT NULL,
    blocked_merge_request_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE merge_request_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_blocks_id_seq OWNED BY merge_request_blocks.id;

CREATE TABLE merge_request_context_commit_diff_files (
    sha bytea NOT NULL,
    relative_order integer NOT NULL,
    new_file boolean NOT NULL,
    renamed_file boolean NOT NULL,
    deleted_file boolean NOT NULL,
    too_large boolean NOT NULL,
    a_mode character varying(255) NOT NULL,
    b_mode character varying(255) NOT NULL,
    new_path text NOT NULL,
    old_path text NOT NULL,
    diff text,
    "binary" boolean,
    merge_request_context_commit_id bigint
);

CREATE TABLE merge_request_context_commits (
    id bigint NOT NULL,
    authored_date timestamp with time zone,
    committed_date timestamp with time zone,
    relative_order integer NOT NULL,
    sha bytea NOT NULL,
    author_name text,
    author_email text,
    committer_name text,
    committer_email text,
    message text,
    merge_request_id bigint
);

CREATE SEQUENCE merge_request_context_commits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_context_commits_id_seq OWNED BY merge_request_context_commits.id;

CREATE TABLE merge_request_diff_commits (
    authored_date timestamp without time zone,
    committed_date timestamp without time zone,
    merge_request_diff_id integer NOT NULL,
    relative_order integer NOT NULL,
    sha bytea NOT NULL,
    author_name text,
    author_email text,
    committer_name text,
    committer_email text,
    message text
);

CREATE TABLE merge_request_diff_details (
    merge_request_diff_id bigint NOT NULL,
    verification_retry_at timestamp with time zone,
    verified_at timestamp with time zone,
    verification_retry_count smallint,
    verification_checksum bytea,
    verification_failure text,
    verification_state smallint DEFAULT 0,
    verification_started_at timestamp with time zone,
    CONSTRAINT check_81429e3622 CHECK ((char_length(verification_failure) <= 255))
);

CREATE SEQUENCE merge_request_diff_details_merge_request_diff_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_diff_details_merge_request_diff_id_seq OWNED BY merge_request_diff_details.merge_request_diff_id;

CREATE TABLE merge_request_diff_files (
    merge_request_diff_id integer NOT NULL,
    relative_order integer NOT NULL,
    new_file boolean NOT NULL,
    renamed_file boolean NOT NULL,
    deleted_file boolean NOT NULL,
    too_large boolean NOT NULL,
    a_mode character varying NOT NULL,
    b_mode character varying NOT NULL,
    new_path text NOT NULL,
    old_path text NOT NULL,
    diff text,
    "binary" boolean,
    external_diff_offset integer,
    external_diff_size integer
);

CREATE TABLE merge_request_diffs (
    id integer NOT NULL,
    state character varying,
    merge_request_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    base_commit_sha character varying,
    real_size character varying,
    head_commit_sha character varying,
    start_commit_sha character varying,
    commits_count integer,
    external_diff character varying,
    external_diff_store integer DEFAULT 1,
    stored_externally boolean,
    files_count smallint,
    CONSTRAINT check_93ee616ac9 CHECK ((external_diff_store IS NOT NULL))
);

CREATE SEQUENCE merge_request_diffs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_diffs_id_seq OWNED BY merge_request_diffs.id;

CREATE TABLE merge_request_metrics (
    id integer NOT NULL,
    merge_request_id integer NOT NULL,
    latest_build_started_at timestamp without time zone,
    latest_build_finished_at timestamp without time zone,
    first_deployed_to_production_at timestamp without time zone,
    merged_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pipeline_id integer,
    merged_by_id integer,
    latest_closed_by_id integer,
    latest_closed_at timestamp with time zone,
    first_comment_at timestamp with time zone,
    first_commit_at timestamp with time zone,
    last_commit_at timestamp with time zone,
    diff_size integer,
    modified_paths_size integer,
    commits_count integer,
    first_approved_at timestamp with time zone,
    first_reassigned_at timestamp with time zone,
    added_lines integer,
    removed_lines integer,
    target_project_id integer,
    CONSTRAINT check_e03d0900bf CHECK ((target_project_id IS NOT NULL))
);

CREATE SEQUENCE merge_request_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_metrics_id_seq OWNED BY merge_request_metrics.id;

CREATE TABLE merge_request_reviewers (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    merge_request_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE merge_request_reviewers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_reviewers_id_seq OWNED BY merge_request_reviewers.id;

CREATE TABLE merge_request_user_mentions (
    id bigint NOT NULL,
    merge_request_id integer NOT NULL,
    note_id integer,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[]
);

CREATE SEQUENCE merge_request_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_request_user_mentions_id_seq OWNED BY merge_request_user_mentions.id;

CREATE TABLE merge_requests (
    id integer NOT NULL,
    target_branch character varying NOT NULL,
    source_branch character varying NOT NULL,
    source_project_id integer,
    author_id integer,
    assignee_id integer,
    title character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    milestone_id integer,
    merge_status character varying DEFAULT 'unchecked'::character varying NOT NULL,
    target_project_id integer NOT NULL,
    iid integer,
    description text,
    updated_by_id integer,
    merge_error text,
    merge_params text,
    merge_when_pipeline_succeeds boolean DEFAULT false NOT NULL,
    merge_user_id integer,
    merge_commit_sha character varying,
    approvals_before_merge integer,
    rebase_commit_sha character varying,
    in_progress_merge_commit_sha character varying,
    lock_version integer DEFAULT 0,
    title_html text,
    description_html text,
    time_estimate integer,
    squash boolean DEFAULT false NOT NULL,
    cached_markdown_version integer,
    last_edited_at timestamp without time zone,
    last_edited_by_id integer,
    head_pipeline_id integer,
    merge_jid character varying,
    discussion_locked boolean,
    latest_merge_request_diff_id integer,
    allow_maintainer_to_push boolean,
    state_id smallint DEFAULT 1 NOT NULL,
    rebase_jid character varying,
    squash_commit_sha bytea,
    sprint_id bigint,
    merge_ref_sha bytea,
    CONSTRAINT check_970d272570 CHECK ((lock_version IS NOT NULL))
);

CREATE TABLE merge_requests_closing_issues (
    id integer NOT NULL,
    merge_request_id integer NOT NULL,
    issue_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE merge_requests_closing_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_requests_closing_issues_id_seq OWNED BY merge_requests_closing_issues.id;

CREATE SEQUENCE merge_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_requests_id_seq OWNED BY merge_requests.id;

CREATE TABLE merge_trains (
    id bigint NOT NULL,
    merge_request_id integer NOT NULL,
    user_id integer NOT NULL,
    pipeline_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    target_project_id integer NOT NULL,
    target_branch text NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    merged_at timestamp with time zone,
    duration integer
);

CREATE SEQUENCE merge_trains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE merge_trains_id_seq OWNED BY merge_trains.id;

CREATE TABLE metrics_dashboard_annotations (
    id bigint NOT NULL,
    starting_at timestamp with time zone NOT NULL,
    ending_at timestamp with time zone,
    environment_id bigint,
    cluster_id bigint,
    dashboard_path character varying(255) NOT NULL,
    panel_xid character varying(255),
    description text NOT NULL
);

CREATE SEQUENCE metrics_dashboard_annotations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE metrics_dashboard_annotations_id_seq OWNED BY metrics_dashboard_annotations.id;

CREATE TABLE metrics_users_starred_dashboards (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    user_id bigint NOT NULL,
    dashboard_path text NOT NULL,
    CONSTRAINT check_79a84a0f57 CHECK ((char_length(dashboard_path) <= 255))
);

CREATE SEQUENCE metrics_users_starred_dashboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE metrics_users_starred_dashboards_id_seq OWNED BY metrics_users_starred_dashboards.id;

CREATE TABLE milestone_releases (
    milestone_id bigint NOT NULL,
    release_id bigint NOT NULL
);

CREATE TABLE milestones (
    id integer NOT NULL,
    title character varying NOT NULL,
    project_id integer,
    description text,
    due_date date,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    state character varying,
    iid integer,
    title_html text,
    description_html text,
    start_date date,
    cached_markdown_version integer,
    group_id integer
);

CREATE SEQUENCE milestones_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE milestones_id_seq OWNED BY milestones.id;

CREATE TABLE namespace_aggregation_schedules (
    namespace_id integer NOT NULL
);

CREATE TABLE namespace_limits (
    additional_purchased_storage_size bigint DEFAULT 0 NOT NULL,
    additional_purchased_storage_ends_on date,
    namespace_id integer NOT NULL,
    temporary_storage_increase_ends_on date
);

CREATE TABLE namespace_root_storage_statistics (
    namespace_id integer NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    repository_size bigint DEFAULT 0 NOT NULL,
    lfs_objects_size bigint DEFAULT 0 NOT NULL,
    wiki_size bigint DEFAULT 0 NOT NULL,
    build_artifacts_size bigint DEFAULT 0 NOT NULL,
    storage_size bigint DEFAULT 0 NOT NULL,
    packages_size bigint DEFAULT 0 NOT NULL,
    snippets_size bigint DEFAULT 0 NOT NULL,
    pipeline_artifacts_size bigint DEFAULT 0 NOT NULL
);

CREATE TABLE namespace_settings (
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    namespace_id integer NOT NULL,
    prevent_forking_outside_group boolean DEFAULT false NOT NULL,
    allow_mfa_for_subgroups boolean DEFAULT true NOT NULL,
    default_branch_name text,
    CONSTRAINT check_0ba93c78c7 CHECK ((char_length(default_branch_name) <= 255))
);

CREATE TABLE namespace_statistics (
    id integer NOT NULL,
    namespace_id integer NOT NULL,
    shared_runners_seconds integer DEFAULT 0 NOT NULL,
    shared_runners_seconds_last_reset timestamp without time zone
);

CREATE SEQUENCE namespace_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE namespace_statistics_id_seq OWNED BY namespace_statistics.id;

CREATE TABLE namespaces (
    id integer NOT NULL,
    name character varying NOT NULL,
    path character varying NOT NULL,
    owner_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying,
    description character varying DEFAULT ''::character varying NOT NULL,
    avatar character varying,
    membership_lock boolean DEFAULT false,
    share_with_group_lock boolean DEFAULT false,
    visibility_level integer DEFAULT 20 NOT NULL,
    request_access_enabled boolean DEFAULT true NOT NULL,
    ldap_sync_status character varying DEFAULT 'ready'::character varying NOT NULL,
    ldap_sync_error character varying,
    ldap_sync_last_update_at timestamp without time zone,
    ldap_sync_last_successful_update_at timestamp without time zone,
    ldap_sync_last_sync_at timestamp without time zone,
    description_html text,
    lfs_enabled boolean,
    parent_id integer,
    shared_runners_minutes_limit integer,
    repository_size_limit bigint,
    require_two_factor_authentication boolean DEFAULT false NOT NULL,
    two_factor_grace_period integer DEFAULT 48 NOT NULL,
    cached_markdown_version integer,
    project_creation_level integer,
    runners_token character varying,
    file_template_project_id integer,
    saml_discovery_token character varying,
    runners_token_encrypted character varying,
    custom_project_templates_group_id integer,
    auto_devops_enabled boolean,
    extra_shared_runners_minutes_limit integer,
    last_ci_minutes_notification_at timestamp with time zone,
    last_ci_minutes_usage_notification_level integer,
    subgroup_creation_level integer DEFAULT 1,
    emails_disabled boolean,
    max_pages_size integer,
    max_artifacts_size integer,
    mentions_disabled boolean,
    default_branch_protection smallint,
    unlock_membership_to_ldap boolean,
    max_personal_access_token_lifetime integer,
    push_rule_id bigint,
    shared_runners_enabled boolean DEFAULT true NOT NULL,
    allow_descendants_override_disabled_shared_runners boolean DEFAULT false NOT NULL,
    traversal_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    delayed_project_removal boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE namespaces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE namespaces_id_seq OWNED BY namespaces.id;

CREATE TABLE note_diff_files (
    id integer NOT NULL,
    diff_note_id integer NOT NULL,
    diff text NOT NULL,
    new_file boolean NOT NULL,
    renamed_file boolean NOT NULL,
    deleted_file boolean NOT NULL,
    a_mode character varying NOT NULL,
    b_mode character varying NOT NULL,
    new_path text NOT NULL,
    old_path text NOT NULL
);

CREATE SEQUENCE note_diff_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE note_diff_files_id_seq OWNED BY note_diff_files.id;

CREATE TABLE notes (
    id integer NOT NULL,
    note text,
    noteable_type character varying,
    author_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_id integer,
    attachment character varying,
    line_code character varying,
    commit_id character varying,
    noteable_id integer,
    system boolean DEFAULT false NOT NULL,
    st_diff text,
    updated_by_id integer,
    type character varying,
    "position" text,
    original_position text,
    resolved_at timestamp without time zone,
    resolved_by_id integer,
    discussion_id character varying,
    note_html text,
    cached_markdown_version integer,
    change_position text,
    resolved_by_push boolean,
    review_id bigint,
    confidential boolean
);

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;

CREATE TABLE notification_settings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    source_id integer,
    source_type character varying,
    level integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    new_note boolean,
    new_issue boolean,
    reopen_issue boolean,
    close_issue boolean,
    reassign_issue boolean,
    new_merge_request boolean,
    reopen_merge_request boolean,
    close_merge_request boolean,
    reassign_merge_request boolean,
    merge_merge_request boolean,
    failed_pipeline boolean,
    success_pipeline boolean,
    push_to_merge_request boolean,
    issue_due boolean,
    new_epic boolean,
    notification_email character varying,
    fixed_pipeline boolean,
    new_release boolean,
    moved_project boolean DEFAULT true NOT NULL,
    change_reviewer_merge_request boolean
);

CREATE SEQUENCE notification_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE notification_settings_id_seq OWNED BY notification_settings.id;

CREATE TABLE oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;

CREATE TABLE oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying
);

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;

CREATE TABLE oauth_applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    owner_id integer,
    owner_type character varying,
    trusted boolean DEFAULT false NOT NULL,
    confidential boolean DEFAULT true NOT NULL
);

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;

CREATE TABLE oauth_openid_requests (
    id integer NOT NULL,
    access_grant_id integer NOT NULL,
    nonce character varying NOT NULL
);

CREATE SEQUENCE oauth_openid_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE oauth_openid_requests_id_seq OWNED BY oauth_openid_requests.id;

CREATE TABLE open_project_tracker_data (
    id bigint NOT NULL,
    service_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    encrypted_url character varying(255),
    encrypted_url_iv character varying(255),
    encrypted_api_url character varying(255),
    encrypted_api_url_iv character varying(255),
    encrypted_token character varying(255),
    encrypted_token_iv character varying(255),
    closed_status_id character varying(5),
    project_identifier_code character varying(100)
);

CREATE SEQUENCE open_project_tracker_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE open_project_tracker_data_id_seq OWNED BY open_project_tracker_data.id;

CREATE TABLE operations_feature_flag_scopes (
    id bigint NOT NULL,
    feature_flag_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    active boolean NOT NULL,
    environment_scope character varying DEFAULT '*'::character varying NOT NULL,
    strategies jsonb DEFAULT '[{"name": "default", "parameters": {}}]'::jsonb NOT NULL
);

CREATE SEQUENCE operations_feature_flag_scopes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_feature_flag_scopes_id_seq OWNED BY operations_feature_flag_scopes.id;

CREATE TABLE operations_feature_flags (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    active boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying NOT NULL,
    description text,
    iid integer NOT NULL,
    version smallint DEFAULT 1 NOT NULL
);

CREATE TABLE operations_feature_flags_clients (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    token_encrypted character varying
);

CREATE SEQUENCE operations_feature_flags_clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_feature_flags_clients_id_seq OWNED BY operations_feature_flags_clients.id;

CREATE SEQUENCE operations_feature_flags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_feature_flags_id_seq OWNED BY operations_feature_flags.id;

CREATE TABLE operations_feature_flags_issues (
    id bigint NOT NULL,
    feature_flag_id bigint NOT NULL,
    issue_id bigint NOT NULL
);

CREATE SEQUENCE operations_feature_flags_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_feature_flags_issues_id_seq OWNED BY operations_feature_flags_issues.id;

CREATE TABLE operations_scopes (
    id bigint NOT NULL,
    strategy_id bigint NOT NULL,
    environment_scope character varying(255) NOT NULL
);

CREATE SEQUENCE operations_scopes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_scopes_id_seq OWNED BY operations_scopes.id;

CREATE TABLE operations_strategies (
    id bigint NOT NULL,
    feature_flag_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    parameters jsonb DEFAULT '{}'::jsonb NOT NULL
);

CREATE SEQUENCE operations_strategies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_strategies_id_seq OWNED BY operations_strategies.id;

CREATE TABLE operations_strategies_user_lists (
    id bigint NOT NULL,
    strategy_id bigint NOT NULL,
    user_list_id bigint NOT NULL
);

CREATE SEQUENCE operations_strategies_user_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_strategies_user_lists_id_seq OWNED BY operations_strategies_user_lists.id;

CREATE TABLE operations_user_lists (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    iid integer NOT NULL,
    name character varying(255) NOT NULL,
    user_xids text DEFAULT ''::text NOT NULL
);

CREATE SEQUENCE operations_user_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE operations_user_lists_id_seq OWNED BY operations_user_lists.id;

CREATE TABLE packages_build_infos (
    id bigint NOT NULL,
    package_id integer NOT NULL,
    pipeline_id integer
);

CREATE SEQUENCE packages_build_infos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_build_infos_id_seq OWNED BY packages_build_infos.id;

CREATE TABLE packages_composer_metadata (
    package_id bigint NOT NULL,
    target_sha bytea NOT NULL,
    composer_json jsonb DEFAULT '{}'::jsonb NOT NULL
);

CREATE TABLE packages_conan_file_metadata (
    id bigint NOT NULL,
    package_file_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    recipe_revision character varying(255) DEFAULT '0'::character varying NOT NULL,
    package_revision character varying(255),
    conan_package_reference character varying(255),
    conan_file_type smallint NOT NULL
);

CREATE SEQUENCE packages_conan_file_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_conan_file_metadata_id_seq OWNED BY packages_conan_file_metadata.id;

CREATE TABLE packages_conan_metadata (
    id bigint NOT NULL,
    package_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    package_username character varying(255) NOT NULL,
    package_channel character varying(255) NOT NULL
);

CREATE SEQUENCE packages_conan_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_conan_metadata_id_seq OWNED BY packages_conan_metadata.id;

CREATE TABLE packages_dependencies (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    version_pattern character varying(255) NOT NULL
);

CREATE SEQUENCE packages_dependencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_dependencies_id_seq OWNED BY packages_dependencies.id;

CREATE TABLE packages_dependency_links (
    id bigint NOT NULL,
    package_id bigint NOT NULL,
    dependency_id bigint NOT NULL,
    dependency_type smallint NOT NULL
);

CREATE SEQUENCE packages_dependency_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_dependency_links_id_seq OWNED BY packages_dependency_links.id;

CREATE TABLE packages_events (
    id bigint NOT NULL,
    event_type smallint NOT NULL,
    event_scope smallint NOT NULL,
    originator_type smallint NOT NULL,
    originator bigint,
    created_at timestamp with time zone NOT NULL,
    package_id bigint
);

CREATE SEQUENCE packages_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_events_id_seq OWNED BY packages_events.id;

CREATE TABLE packages_maven_metadata (
    id bigint NOT NULL,
    package_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    app_group character varying NOT NULL,
    app_name character varying NOT NULL,
    app_version character varying,
    path character varying(512) NOT NULL
);

CREATE SEQUENCE packages_maven_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_maven_metadata_id_seq OWNED BY packages_maven_metadata.id;

CREATE TABLE packages_nuget_dependency_link_metadata (
    dependency_link_id bigint NOT NULL,
    target_framework text NOT NULL,
    CONSTRAINT packages_nuget_dependency_link_metadata_target_framework_constr CHECK ((char_length(target_framework) <= 255))
);

CREATE TABLE packages_nuget_metadata (
    package_id bigint NOT NULL,
    license_url text,
    project_url text,
    icon_url text,
    CONSTRAINT packages_nuget_metadata_icon_url_constraint CHECK ((char_length(icon_url) <= 255)),
    CONSTRAINT packages_nuget_metadata_license_url_constraint CHECK ((char_length(license_url) <= 255)),
    CONSTRAINT packages_nuget_metadata_project_url_constraint CHECK ((char_length(project_url) <= 255))
);

CREATE TABLE packages_package_files (
    id bigint NOT NULL,
    package_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    size bigint,
    file_store integer DEFAULT 1,
    file_md5 bytea,
    file_sha1 bytea,
    file_name character varying NOT NULL,
    file text NOT NULL,
    file_sha256 bytea,
    verification_retry_at timestamp with time zone,
    verified_at timestamp with time zone,
    verification_failure character varying(255),
    verification_retry_count integer,
    verification_checksum bytea,
    verification_state smallint DEFAULT 0,
    verification_started_at timestamp with time zone,
    CONSTRAINT check_4c5e6bb0b3 CHECK ((file_store IS NOT NULL))
);

CREATE SEQUENCE packages_package_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_package_files_id_seq OWNED BY packages_package_files.id;

CREATE TABLE packages_packages (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying NOT NULL,
    version character varying,
    package_type smallint NOT NULL,
    creator_id integer
);

CREATE SEQUENCE packages_packages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_packages_id_seq OWNED BY packages_packages.id;

CREATE TABLE packages_pypi_metadata (
    package_id bigint NOT NULL,
    required_python text,
    CONSTRAINT check_0d9aed55b2 CHECK ((required_python IS NOT NULL)),
    CONSTRAINT check_379019d5da CHECK ((char_length(required_python) <= 255))
);

CREATE TABLE packages_tags (
    id bigint NOT NULL,
    package_id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE packages_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE packages_tags_id_seq OWNED BY packages_tags.id;

CREATE TABLE pages_deployments (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    ci_build_id bigint,
    file_store smallint NOT NULL,
    size integer NOT NULL,
    file text NOT NULL,
    file_count integer NOT NULL,
    file_sha256 bytea NOT NULL,
    CONSTRAINT check_f0fe8032dd CHECK ((char_length(file) <= 255))
);

CREATE SEQUENCE pages_deployments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE pages_deployments_id_seq OWNED BY pages_deployments.id;

CREATE TABLE pages_domain_acme_orders (
    id bigint NOT NULL,
    pages_domain_id integer NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    url character varying NOT NULL,
    challenge_token character varying NOT NULL,
    challenge_file_content text NOT NULL,
    encrypted_private_key text NOT NULL,
    encrypted_private_key_iv text NOT NULL
);

CREATE SEQUENCE pages_domain_acme_orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE pages_domain_acme_orders_id_seq OWNED BY pages_domain_acme_orders.id;

CREATE TABLE pages_domains (
    id integer NOT NULL,
    project_id integer,
    certificate text,
    encrypted_key text,
    encrypted_key_iv character varying,
    encrypted_key_salt character varying,
    domain character varying,
    verified_at timestamp with time zone,
    verification_code character varying NOT NULL,
    enabled_until timestamp with time zone,
    remove_at timestamp with time zone,
    auto_ssl_enabled boolean DEFAULT false NOT NULL,
    certificate_valid_not_before timestamp with time zone,
    certificate_valid_not_after timestamp with time zone,
    certificate_source smallint DEFAULT 0 NOT NULL,
    wildcard boolean DEFAULT false NOT NULL,
    usage smallint DEFAULT 0 NOT NULL,
    scope smallint DEFAULT 2 NOT NULL,
    auto_ssl_failed boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE pages_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE pages_domains_id_seq OWNED BY pages_domains.id;

CREATE TABLE partitioned_foreign_keys (
    id bigint NOT NULL,
    cascade_delete boolean DEFAULT true NOT NULL,
    from_table text NOT NULL,
    from_column text NOT NULL,
    to_table text NOT NULL,
    to_column text NOT NULL,
    CONSTRAINT check_2c2e02a62b CHECK ((char_length(from_column) <= 63)),
    CONSTRAINT check_40738efb57 CHECK ((char_length(to_table) <= 63)),
    CONSTRAINT check_741676d405 CHECK ((char_length(from_table) <= 63)),
    CONSTRAINT check_7e98be694f CHECK ((char_length(to_column) <= 63))
);

CREATE SEQUENCE partitioned_foreign_keys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE partitioned_foreign_keys_id_seq OWNED BY partitioned_foreign_keys.id;

CREATE TABLE path_locks (
    id integer NOT NULL,
    path character varying NOT NULL,
    project_id integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE path_locks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE path_locks_id_seq OWNED BY path_locks.id;

CREATE TABLE personal_access_tokens (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying NOT NULL,
    revoked boolean DEFAULT false,
    expires_at date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    scopes character varying DEFAULT '--- []
'::character varying NOT NULL,
    impersonation boolean DEFAULT false NOT NULL,
    token_digest character varying,
    expire_notification_delivered boolean DEFAULT false NOT NULL,
    last_used_at timestamp with time zone,
    after_expiry_notification_delivered boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE personal_access_tokens_id_seq OWNED BY personal_access_tokens.id;

CREATE TABLE plan_limits (
    id bigint NOT NULL,
    plan_id bigint NOT NULL,
    ci_active_pipelines integer DEFAULT 0 NOT NULL,
    ci_pipeline_size integer DEFAULT 0 NOT NULL,
    ci_active_jobs integer DEFAULT 0 NOT NULL,
    project_hooks integer DEFAULT 100 NOT NULL,
    group_hooks integer DEFAULT 50 NOT NULL,
    ci_project_subscriptions integer DEFAULT 2 NOT NULL,
    ci_pipeline_schedules integer DEFAULT 10 NOT NULL,
    offset_pagination_limit integer DEFAULT 50000 NOT NULL,
    ci_instance_level_variables integer DEFAULT 25 NOT NULL,
    storage_size_limit integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_lsif integer DEFAULT 20 NOT NULL,
    ci_max_artifact_size_archive integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_metadata integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_trace integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_junit integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_sast integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_dependency_scanning integer DEFAULT 350 NOT NULL,
    ci_max_artifact_size_container_scanning integer DEFAULT 150 NOT NULL,
    ci_max_artifact_size_dast integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_codequality integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_license_management integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_license_scanning integer DEFAULT 100 NOT NULL,
    ci_max_artifact_size_performance integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_metrics integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_metrics_referee integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_network_referee integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_dotenv integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_cobertura integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_terraform integer DEFAULT 5 NOT NULL,
    ci_max_artifact_size_accessibility integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_cluster_applications integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_secret_detection integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_requirements integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_coverage_fuzzing integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_browser_performance integer DEFAULT 0 NOT NULL,
    ci_max_artifact_size_load_performance integer DEFAULT 0 NOT NULL,
    ci_needs_size_limit integer DEFAULT 50 NOT NULL,
    conan_max_file_size bigint DEFAULT '3221225472'::bigint NOT NULL,
    maven_max_file_size bigint DEFAULT '3221225472'::bigint NOT NULL,
    npm_max_file_size bigint DEFAULT 524288000 NOT NULL,
    nuget_max_file_size bigint DEFAULT 524288000 NOT NULL,
    pypi_max_file_size bigint DEFAULT '3221225472'::bigint NOT NULL,
    generic_packages_max_file_size bigint DEFAULT '5368709120'::bigint NOT NULL,
    golang_max_file_size bigint DEFAULT 104857600 NOT NULL,
    debian_max_file_size bigint DEFAULT '3221225472'::bigint NOT NULL,
    project_feature_flags integer DEFAULT 200 NOT NULL,
    ci_max_artifact_size_api_fuzzing integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE plan_limits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE plan_limits_id_seq OWNED BY plan_limits.id;

CREATE TABLE plans (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying,
    title character varying
);

CREATE SEQUENCE plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE plans_id_seq OWNED BY plans.id;

CREATE TABLE pool_repositories (
    id bigint NOT NULL,
    shard_id integer NOT NULL,
    disk_path character varying,
    state character varying,
    source_project_id integer
);

CREATE SEQUENCE pool_repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE pool_repositories_id_seq OWNED BY pool_repositories.id;

CREATE VIEW postgres_indexes AS
 SELECT (((pg_namespace.nspname)::text || '.'::text) || (pg_class.relname)::text) AS identifier,
    pg_index.indexrelid,
    pg_namespace.nspname AS schema,
    pg_class.relname AS name,
    pg_index.indisunique AS "unique",
    pg_index.indisvalid AS valid_index,
    pg_class.relispartition AS partitioned,
    pg_index.indisexclusion AS exclusion,
    pg_indexes.indexdef AS definition,
    pg_relation_size((pg_class.oid)::regclass) AS ondisk_size_bytes
   FROM (((pg_index
     JOIN pg_class ON ((pg_class.oid = pg_index.indexrelid)))
     JOIN pg_namespace ON ((pg_class.relnamespace = pg_namespace.oid)))
     JOIN pg_indexes ON ((pg_class.relname = pg_indexes.indexname)))
  WHERE ((pg_namespace.nspname <> 'pg_catalog'::name) AND (pg_namespace.nspname = ANY (ARRAY["current_schema"(), 'gitlab_partitions_dynamic'::name, 'gitlab_partitions_static'::name])));

CREATE VIEW postgres_partitioned_tables AS
 SELECT (((pg_namespace.nspname)::text || '.'::text) || (pg_class.relname)::text) AS identifier,
    pg_class.oid,
    pg_namespace.nspname AS schema,
    pg_class.relname AS name,
        CASE partitioned_tables.partstrat
            WHEN 'l'::"char" THEN 'list'::text
            WHEN 'r'::"char" THEN 'range'::text
            WHEN 'h'::"char" THEN 'hash'::text
            ELSE NULL::text
        END AS strategy,
    array_agg(pg_attribute.attname) AS key_columns
   FROM (((( SELECT pg_partitioned_table.partrelid,
            pg_partitioned_table.partstrat,
            unnest(pg_partitioned_table.partattrs) AS column_position
           FROM pg_partitioned_table) partitioned_tables
     JOIN pg_class ON ((partitioned_tables.partrelid = pg_class.oid)))
     JOIN pg_namespace ON ((pg_class.relnamespace = pg_namespace.oid)))
     JOIN pg_attribute ON (((pg_attribute.attrelid = pg_class.oid) AND (pg_attribute.attnum = partitioned_tables.column_position))))
  WHERE (pg_namespace.nspname = "current_schema"())
  GROUP BY (((pg_namespace.nspname)::text || '.'::text) || (pg_class.relname)::text), pg_class.oid, pg_namespace.nspname, pg_class.relname,
        CASE partitioned_tables.partstrat
            WHEN 'l'::"char" THEN 'list'::text
            WHEN 'r'::"char" THEN 'range'::text
            WHEN 'h'::"char" THEN 'hash'::text
            ELSE NULL::text
        END;

CREATE TABLE postgres_reindex_actions (
    id bigint NOT NULL,
    action_start timestamp with time zone NOT NULL,
    action_end timestamp with time zone,
    ondisk_size_bytes_start bigint NOT NULL,
    ondisk_size_bytes_end bigint,
    state smallint DEFAULT 0 NOT NULL,
    index_identifier text NOT NULL,
    CONSTRAINT check_f12527622c CHECK ((char_length(index_identifier) <= 255))
);

CREATE SEQUENCE postgres_reindex_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE postgres_reindex_actions_id_seq OWNED BY postgres_reindex_actions.id;

CREATE TABLE programming_languages (
    id integer NOT NULL,
    name character varying NOT NULL,
    color character varying NOT NULL,
    created_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE programming_languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE programming_languages_id_seq OWNED BY programming_languages.id;

CREATE TABLE project_access_tokens (
    personal_access_token_id bigint NOT NULL,
    project_id bigint NOT NULL
);

CREATE TABLE project_alerting_settings (
    project_id integer NOT NULL,
    encrypted_token character varying NOT NULL,
    encrypted_token_iv character varying NOT NULL
);

CREATE TABLE project_aliases (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE project_aliases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_aliases_id_seq OWNED BY project_aliases.id;

CREATE TABLE project_authorizations (
    user_id integer NOT NULL,
    project_id integer NOT NULL,
    access_level integer NOT NULL
);

CREATE TABLE project_auto_devops (
    id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    enabled boolean,
    deploy_strategy integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE project_auto_devops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_auto_devops_id_seq OWNED BY project_auto_devops.id;

CREATE TABLE project_ci_cd_settings (
    id integer NOT NULL,
    project_id integer NOT NULL,
    group_runners_enabled boolean DEFAULT true NOT NULL,
    merge_pipelines_enabled boolean,
    default_git_depth integer,
    forward_deployment_enabled boolean
);

CREATE SEQUENCE project_ci_cd_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_ci_cd_settings_id_seq OWNED BY project_ci_cd_settings.id;

CREATE TABLE project_compliance_framework_settings (
    project_id bigint NOT NULL,
    framework smallint NOT NULL,
    framework_id bigint,
    CONSTRAINT check_d348de9e2d CHECK ((framework_id IS NOT NULL))
);

CREATE SEQUENCE project_compliance_framework_settings_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_compliance_framework_settings_project_id_seq OWNED BY project_compliance_framework_settings.project_id;

CREATE TABLE project_custom_attributes (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);

CREATE SEQUENCE project_custom_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_custom_attributes_id_seq OWNED BY project_custom_attributes.id;

CREATE TABLE project_daily_statistics (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    fetch_count integer NOT NULL,
    date date
);

CREATE SEQUENCE project_daily_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_daily_statistics_id_seq OWNED BY project_daily_statistics.id;

CREATE TABLE project_deploy_tokens (
    id integer NOT NULL,
    project_id integer NOT NULL,
    deploy_token_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE project_deploy_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_deploy_tokens_id_seq OWNED BY project_deploy_tokens.id;

CREATE TABLE project_error_tracking_settings (
    project_id integer NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    api_url character varying,
    encrypted_token character varying,
    encrypted_token_iv character varying,
    project_name character varying,
    organization_name character varying
);

CREATE TABLE project_export_jobs (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    jid character varying(100) NOT NULL
);

CREATE SEQUENCE project_export_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_export_jobs_id_seq OWNED BY project_export_jobs.id;

CREATE TABLE project_feature_usages (
    project_id integer NOT NULL,
    jira_dvcs_cloud_last_sync_at timestamp without time zone,
    jira_dvcs_server_last_sync_at timestamp without time zone
);

CREATE TABLE project_features (
    id integer NOT NULL,
    project_id integer NOT NULL,
    merge_requests_access_level integer,
    issues_access_level integer,
    wiki_access_level integer,
    snippets_access_level integer DEFAULT 20 NOT NULL,
    builds_access_level integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    repository_access_level integer DEFAULT 20 NOT NULL,
    pages_access_level integer NOT NULL,
    forking_access_level integer,
    metrics_dashboard_access_level integer
);

CREATE SEQUENCE project_features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_features_id_seq OWNED BY project_features.id;

CREATE TABLE project_group_links (
    id integer NOT NULL,
    project_id integer NOT NULL,
    group_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    group_access integer DEFAULT 30 NOT NULL,
    expires_at date
);

CREATE SEQUENCE project_group_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_group_links_id_seq OWNED BY project_group_links.id;

CREATE TABLE project_import_data (
    id integer NOT NULL,
    project_id integer,
    data text,
    encrypted_credentials text,
    encrypted_credentials_iv character varying,
    encrypted_credentials_salt character varying
);

CREATE SEQUENCE project_import_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_import_data_id_seq OWNED BY project_import_data.id;

CREATE TABLE project_incident_management_settings (
    project_id integer NOT NULL,
    create_issue boolean DEFAULT false NOT NULL,
    send_email boolean DEFAULT false NOT NULL,
    issue_template_key text,
    pagerduty_active boolean DEFAULT false NOT NULL,
    encrypted_pagerduty_token bytea,
    encrypted_pagerduty_token_iv bytea,
    auto_close_incident boolean DEFAULT true NOT NULL,
    sla_timer boolean DEFAULT false,
    sla_timer_minutes integer,
    CONSTRAINT pagerduty_token_iv_length_constraint CHECK ((octet_length(encrypted_pagerduty_token_iv) <= 12)),
    CONSTRAINT pagerduty_token_length_constraint CHECK ((octet_length(encrypted_pagerduty_token) <= 255))
);

CREATE SEQUENCE project_incident_management_settings_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_incident_management_settings_project_id_seq OWNED BY project_incident_management_settings.project_id;

CREATE TABLE project_metrics_settings (
    project_id integer NOT NULL,
    external_dashboard_url character varying,
    dashboard_timezone smallint DEFAULT 0 NOT NULL
);

CREATE TABLE project_mirror_data (
    id integer NOT NULL,
    project_id integer NOT NULL,
    retry_count integer DEFAULT 0 NOT NULL,
    last_update_started_at timestamp without time zone,
    last_update_scheduled_at timestamp without time zone,
    next_execution_timestamp timestamp without time zone,
    status character varying,
    jid character varying,
    last_error text,
    last_update_at timestamp with time zone,
    last_successful_update_at timestamp with time zone,
    correlation_id_value character varying(128)
);

CREATE SEQUENCE project_mirror_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_mirror_data_id_seq OWNED BY project_mirror_data.id;

CREATE TABLE project_pages_metadata (
    project_id bigint NOT NULL,
    deployed boolean DEFAULT false NOT NULL,
    artifacts_archive_id bigint,
    pages_deployment_id bigint
);

CREATE TABLE project_repositories (
    id bigint NOT NULL,
    shard_id integer NOT NULL,
    disk_path character varying NOT NULL,
    project_id integer NOT NULL
);

CREATE SEQUENCE project_repositories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_repositories_id_seq OWNED BY project_repositories.id;

CREATE TABLE project_repository_states (
    id integer NOT NULL,
    project_id integer NOT NULL,
    repository_verification_checksum bytea,
    wiki_verification_checksum bytea,
    last_repository_verification_failure character varying,
    last_wiki_verification_failure character varying,
    repository_retry_at timestamp with time zone,
    wiki_retry_at timestamp with time zone,
    repository_retry_count integer,
    wiki_retry_count integer,
    last_repository_verification_ran_at timestamp with time zone,
    last_wiki_verification_ran_at timestamp with time zone
);

CREATE SEQUENCE project_repository_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_repository_states_id_seq OWNED BY project_repository_states.id;

CREATE TABLE project_repository_storage_moves (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    state smallint DEFAULT 1 NOT NULL,
    source_storage_name text NOT NULL,
    destination_storage_name text NOT NULL,
    CONSTRAINT project_repository_storage_moves_destination_storage_name CHECK ((char_length(destination_storage_name) <= 255)),
    CONSTRAINT project_repository_storage_moves_source_storage_name CHECK ((char_length(source_storage_name) <= 255))
);

CREATE SEQUENCE project_repository_storage_moves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_repository_storage_moves_id_seq OWNED BY project_repository_storage_moves.id;

CREATE TABLE project_security_settings (
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    auto_fix_container_scanning boolean DEFAULT true NOT NULL,
    auto_fix_dast boolean DEFAULT true NOT NULL,
    auto_fix_dependency_scanning boolean DEFAULT true NOT NULL,
    auto_fix_sast boolean DEFAULT true NOT NULL
);

CREATE SEQUENCE project_security_settings_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_security_settings_project_id_seq OWNED BY project_security_settings.project_id;

CREATE TABLE project_settings (
    project_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    push_rule_id bigint,
    show_default_award_emojis boolean DEFAULT true,
    allow_merge_on_skipped_pipeline boolean,
    squash_option smallint DEFAULT 3,
    has_confluence boolean DEFAULT false NOT NULL,
    CONSTRAINT check_bde223416c CHECK ((show_default_award_emojis IS NOT NULL))
);

CREATE TABLE project_statistics (
    id integer NOT NULL,
    project_id integer NOT NULL,
    namespace_id integer NOT NULL,
    commit_count bigint DEFAULT 0 NOT NULL,
    storage_size bigint DEFAULT 0 NOT NULL,
    repository_size bigint DEFAULT 0 NOT NULL,
    lfs_objects_size bigint DEFAULT 0 NOT NULL,
    build_artifacts_size bigint DEFAULT 0 NOT NULL,
    shared_runners_seconds bigint DEFAULT 0 NOT NULL,
    shared_runners_seconds_last_reset timestamp without time zone,
    packages_size bigint DEFAULT 0 NOT NULL,
    wiki_size bigint,
    snippets_size bigint,
    pipeline_artifacts_size bigint DEFAULT 0 NOT NULL
);

CREATE SEQUENCE project_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_statistics_id_seq OWNED BY project_statistics.id;

CREATE TABLE project_tracing_settings (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    external_url character varying NOT NULL
);

CREATE SEQUENCE project_tracing_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE project_tracing_settings_id_seq OWNED BY project_tracing_settings.id;

CREATE TABLE projects (
    id integer NOT NULL,
    name character varying,
    path character varying,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    creator_id integer,
    namespace_id integer NOT NULL,
    last_activity_at timestamp without time zone,
    import_url character varying,
    visibility_level integer DEFAULT 0 NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    avatar character varying,
    merge_requests_template text,
    star_count integer DEFAULT 0 NOT NULL,
    merge_requests_rebase_enabled boolean DEFAULT false,
    import_type character varying,
    import_source character varying,
    approvals_before_merge integer DEFAULT 0 NOT NULL,
    reset_approvals_on_push boolean DEFAULT true,
    merge_requests_ff_only_enabled boolean DEFAULT false,
    issues_template text,
    mirror boolean DEFAULT false NOT NULL,
    mirror_last_update_at timestamp without time zone,
    mirror_last_successful_update_at timestamp without time zone,
    mirror_user_id integer,
    shared_runners_enabled boolean DEFAULT true NOT NULL,
    runners_token character varying,
    build_coverage_regex character varying,
    build_allow_git_fetch boolean DEFAULT true NOT NULL,
    build_timeout integer DEFAULT 3600 NOT NULL,
    mirror_trigger_builds boolean DEFAULT false NOT NULL,
    pending_delete boolean DEFAULT false,
    public_builds boolean DEFAULT true NOT NULL,
    last_repository_check_failed boolean,
    last_repository_check_at timestamp without time zone,
    container_registry_enabled boolean,
    only_allow_merge_if_pipeline_succeeds boolean DEFAULT false NOT NULL,
    has_external_issue_tracker boolean,
    repository_storage character varying DEFAULT 'default'::character varying NOT NULL,
    repository_read_only boolean,
    request_access_enabled boolean DEFAULT true NOT NULL,
    has_external_wiki boolean,
    ci_config_path character varying,
    lfs_enabled boolean,
    description_html text,
    only_allow_merge_if_all_discussions_are_resolved boolean,
    repository_size_limit bigint,
    printing_merge_request_link_enabled boolean DEFAULT true NOT NULL,
    auto_cancel_pending_pipelines integer DEFAULT 1 NOT NULL,
    service_desk_enabled boolean DEFAULT true,
    cached_markdown_version integer,
    delete_error text,
    last_repository_updated_at timestamp without time zone,
    disable_overriding_approvers_per_merge_request boolean,
    storage_version smallint,
    resolve_outdated_diff_discussions boolean,
    remote_mirror_available_overridden boolean,
    only_mirror_protected_branches boolean,
    pull_mirror_available_overridden boolean,
    jobs_cache_index integer,
    external_authorization_classification_label character varying,
    mirror_overwrites_diverged_branches boolean,
    pages_https_only boolean DEFAULT true,
    external_webhook_token character varying,
    packages_enabled boolean,
    merge_requests_author_approval boolean,
    pool_repository_id bigint,
    runners_token_encrypted character varying,
    bfg_object_map character varying,
    detected_repository_languages boolean,
    merge_requests_disable_committers_approval boolean,
    require_password_to_approve boolean,
    emails_disabled boolean,
    max_pages_size integer,
    max_artifacts_size integer,
    pull_mirror_branch_prefix character varying(50),
    remove_source_branch_after_merge boolean,
    marked_for_deletion_at date,
    marked_for_deletion_by_user_id integer,
    autoclose_referenced_issues boolean,
    suggestion_commit_message character varying(255)
);

CREATE SEQUENCE projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE projects_id_seq OWNED BY projects.id;

CREATE TABLE prometheus_alert_events (
    id bigint NOT NULL,
    project_id integer NOT NULL,
    prometheus_alert_id integer NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    status smallint,
    payload_key character varying
);

CREATE SEQUENCE prometheus_alert_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE prometheus_alert_events_id_seq OWNED BY prometheus_alert_events.id;

CREATE TABLE prometheus_alerts (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    threshold double precision NOT NULL,
    operator integer NOT NULL,
    environment_id integer NOT NULL,
    project_id integer NOT NULL,
    prometheus_metric_id integer NOT NULL,
    runbook_url text,
    CONSTRAINT check_cb76d7e629 CHECK ((char_length(runbook_url) <= 255))
);

CREATE SEQUENCE prometheus_alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE prometheus_alerts_id_seq OWNED BY prometheus_alerts.id;

CREATE TABLE prometheus_metrics (
    id integer NOT NULL,
    project_id integer,
    title character varying NOT NULL,
    query character varying NOT NULL,
    y_label character varying NOT NULL,
    unit character varying NOT NULL,
    legend character varying,
    "group" integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    common boolean DEFAULT false NOT NULL,
    identifier character varying,
    dashboard_path text,
    CONSTRAINT check_0ad9f01463 CHECK ((char_length(dashboard_path) <= 2048))
);

CREATE SEQUENCE prometheus_metrics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE prometheus_metrics_id_seq OWNED BY prometheus_metrics.id;

CREATE TABLE protected_branch_merge_access_levels (
    id integer NOT NULL,
    protected_branch_id integer NOT NULL,
    access_level integer DEFAULT 40,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    group_id integer
);

CREATE SEQUENCE protected_branch_merge_access_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_branch_merge_access_levels_id_seq OWNED BY protected_branch_merge_access_levels.id;

CREATE TABLE protected_branch_push_access_levels (
    id integer NOT NULL,
    protected_branch_id integer NOT NULL,
    access_level integer DEFAULT 40,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    group_id integer,
    deploy_key_id integer
);

CREATE SEQUENCE protected_branch_push_access_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_branch_push_access_levels_id_seq OWNED BY protected_branch_push_access_levels.id;

CREATE TABLE protected_branch_unprotect_access_levels (
    id integer NOT NULL,
    protected_branch_id integer NOT NULL,
    access_level integer DEFAULT 40,
    user_id integer,
    group_id integer
);

CREATE SEQUENCE protected_branch_unprotect_access_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_branch_unprotect_access_levels_id_seq OWNED BY protected_branch_unprotect_access_levels.id;

CREATE TABLE protected_branches (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    code_owner_approval_required boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE protected_branches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_branches_id_seq OWNED BY protected_branches.id;

CREATE TABLE protected_environment_deploy_access_levels (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    access_level integer DEFAULT 40,
    protected_environment_id integer NOT NULL,
    user_id integer,
    group_id integer
);

CREATE SEQUENCE protected_environment_deploy_access_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_environment_deploy_access_levels_id_seq OWNED BY protected_environment_deploy_access_levels.id;

CREATE TABLE protected_environments (
    id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name character varying NOT NULL
);

CREATE SEQUENCE protected_environments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_environments_id_seq OWNED BY protected_environments.id;

CREATE TABLE protected_tag_create_access_levels (
    id integer NOT NULL,
    protected_tag_id integer NOT NULL,
    access_level integer DEFAULT 40,
    user_id integer,
    group_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE protected_tag_create_access_levels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_tag_create_access_levels_id_seq OWNED BY protected_tag_create_access_levels.id;

CREATE TABLE protected_tags (
    id integer NOT NULL,
    project_id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE protected_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE protected_tags_id_seq OWNED BY protected_tags.id;

CREATE TABLE push_event_payloads (
    commit_count bigint NOT NULL,
    event_id integer NOT NULL,
    action smallint NOT NULL,
    ref_type smallint NOT NULL,
    commit_from bytea,
    commit_to bytea,
    ref text,
    commit_title character varying(70),
    ref_count integer
);

CREATE TABLE push_rules (
    id integer NOT NULL,
    force_push_regex character varying,
    delete_branch_regex character varying,
    commit_message_regex character varying,
    deny_delete_tag boolean,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    author_email_regex character varying,
    member_check boolean DEFAULT false NOT NULL,
    file_name_regex character varying,
    is_sample boolean DEFAULT false,
    max_file_size integer DEFAULT 0 NOT NULL,
    prevent_secrets boolean DEFAULT false NOT NULL,
    branch_name_regex character varying,
    reject_unsigned_commits boolean,
    commit_committer_check boolean,
    regexp_uses_re2 boolean DEFAULT true,
    commit_message_negative_regex character varying
);

CREATE SEQUENCE push_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE push_rules_id_seq OWNED BY push_rules.id;

CREATE TABLE raw_usage_data (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    recorded_at timestamp with time zone NOT NULL,
    sent_at timestamp with time zone,
    payload jsonb NOT NULL
);

CREATE SEQUENCE raw_usage_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE raw_usage_data_id_seq OWNED BY raw_usage_data.id;

CREATE TABLE redirect_routes (
    id integer NOT NULL,
    source_id integer NOT NULL,
    source_type character varying NOT NULL,
    path character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE redirect_routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE redirect_routes_id_seq OWNED BY redirect_routes.id;

CREATE TABLE release_links (
    id bigint NOT NULL,
    release_id integer NOT NULL,
    url character varying NOT NULL,
    name character varying NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    filepath character varying(128),
    link_type smallint DEFAULT 0
);

CREATE SEQUENCE release_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE release_links_id_seq OWNED BY release_links.id;

CREATE TABLE releases (
    id integer NOT NULL,
    tag character varying,
    description text,
    project_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description_html text,
    cached_markdown_version integer,
    author_id integer,
    name character varying,
    sha character varying,
    released_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE releases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE releases_id_seq OWNED BY releases.id;

CREATE TABLE remote_mirrors (
    id integer NOT NULL,
    project_id integer,
    url character varying,
    enabled boolean DEFAULT false,
    update_status character varying,
    last_update_at timestamp without time zone,
    last_successful_update_at timestamp without time zone,
    last_error character varying,
    encrypted_credentials text,
    encrypted_credentials_iv character varying,
    encrypted_credentials_salt character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_update_started_at timestamp without time zone,
    only_protected_branches boolean DEFAULT false NOT NULL,
    remote_name character varying,
    error_notification_sent boolean,
    keep_divergent_refs boolean
);

CREATE SEQUENCE remote_mirrors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE remote_mirrors_id_seq OWNED BY remote_mirrors.id;

CREATE TABLE repository_languages (
    project_id integer NOT NULL,
    programming_language_id integer NOT NULL,
    share double precision NOT NULL
);

CREATE TABLE required_code_owners_sections (
    id bigint NOT NULL,
    protected_branch_id bigint NOT NULL,
    name text NOT NULL,
    CONSTRAINT check_e58d53741e CHECK ((char_length(name) <= 1024))
);

CREATE SEQUENCE required_code_owners_sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE required_code_owners_sections_id_seq OWNED BY required_code_owners_sections.id;

CREATE TABLE requirements (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    author_id integer,
    iid integer NOT NULL,
    cached_markdown_version integer,
    state smallint DEFAULT 1 NOT NULL,
    title character varying(255) NOT NULL,
    title_html text,
    description text,
    description_html text,
    CONSTRAINT check_785ae25b9d CHECK ((char_length(description) <= 10000))
);

CREATE SEQUENCE requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE requirements_id_seq OWNED BY requirements.id;

CREATE TABLE requirements_management_test_reports (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    requirement_id bigint NOT NULL,
    author_id bigint,
    state smallint NOT NULL,
    build_id bigint
);

CREATE SEQUENCE requirements_management_test_reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE requirements_management_test_reports_id_seq OWNED BY requirements_management_test_reports.id;

CREATE TABLE resource_iteration_events (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    issue_id bigint,
    merge_request_id bigint,
    iteration_id bigint,
    created_at timestamp with time zone NOT NULL,
    action smallint NOT NULL
);

CREATE SEQUENCE resource_iteration_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE resource_iteration_events_id_seq OWNED BY resource_iteration_events.id;

CREATE TABLE resource_label_events (
    id bigint NOT NULL,
    action integer NOT NULL,
    issue_id integer,
    merge_request_id integer,
    epic_id integer,
    label_id integer,
    user_id integer,
    created_at timestamp with time zone NOT NULL,
    cached_markdown_version integer,
    reference text,
    reference_html text
);

CREATE SEQUENCE resource_label_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE resource_label_events_id_seq OWNED BY resource_label_events.id;

CREATE TABLE resource_milestone_events (
    id bigint NOT NULL,
    user_id bigint,
    issue_id bigint,
    merge_request_id bigint,
    milestone_id bigint,
    action smallint NOT NULL,
    state smallint NOT NULL,
    created_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE resource_milestone_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE resource_milestone_events_id_seq OWNED BY resource_milestone_events.id;

CREATE TABLE resource_state_events (
    id bigint NOT NULL,
    user_id bigint,
    issue_id bigint,
    merge_request_id bigint,
    created_at timestamp with time zone NOT NULL,
    state smallint NOT NULL,
    epic_id integer,
    source_commit text,
    close_after_error_tracking_resolve boolean DEFAULT false NOT NULL,
    close_auto_resolve_prometheus_alert boolean DEFAULT false NOT NULL,
    source_merge_request_id bigint,
    CONSTRAINT check_f0bcfaa3a2 CHECK ((char_length(source_commit) <= 40)),
    CONSTRAINT state_events_must_belong_to_issue_or_merge_request_or_epic CHECK ((((issue_id <> NULL::bigint) AND (merge_request_id IS NULL) AND (epic_id IS NULL)) OR ((issue_id IS NULL) AND (merge_request_id <> NULL::bigint) AND (epic_id IS NULL)) OR ((issue_id IS NULL) AND (merge_request_id IS NULL) AND (epic_id <> NULL::integer))))
);

CREATE SEQUENCE resource_state_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE resource_state_events_id_seq OWNED BY resource_state_events.id;

CREATE TABLE resource_weight_events (
    id bigint NOT NULL,
    user_id bigint,
    issue_id bigint NOT NULL,
    weight integer,
    created_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE resource_weight_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE resource_weight_events_id_seq OWNED BY resource_weight_events.id;

CREATE TABLE reviews (
    id bigint NOT NULL,
    author_id integer,
    merge_request_id integer NOT NULL,
    project_id integer NOT NULL,
    created_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE reviews_id_seq OWNED BY reviews.id;

CREATE TABLE routes (
    id integer NOT NULL,
    source_id integer NOT NULL,
    source_type character varying NOT NULL,
    path character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying
);

CREATE SEQUENCE routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE routes_id_seq OWNED BY routes.id;

CREATE TABLE saml_group_links (
    id bigint NOT NULL,
    access_level smallint NOT NULL,
    group_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    saml_group_name text NOT NULL,
    CONSTRAINT check_1b3fc49d1e CHECK ((char_length(saml_group_name) <= 255))
);

CREATE SEQUENCE saml_group_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE saml_group_links_id_seq OWNED BY saml_group_links.id;

CREATE TABLE saml_providers (
    id integer NOT NULL,
    group_id integer NOT NULL,
    enabled boolean NOT NULL,
    certificate_fingerprint character varying NOT NULL,
    sso_url character varying NOT NULL,
    enforced_sso boolean DEFAULT false NOT NULL,
    enforced_group_managed_accounts boolean DEFAULT false NOT NULL,
    prohibited_outer_forks boolean DEFAULT true NOT NULL,
    default_membership_role smallint DEFAULT 10 NOT NULL
);

CREATE SEQUENCE saml_providers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE saml_providers_id_seq OWNED BY saml_providers.id;

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

CREATE TABLE scim_identities (
    id bigint NOT NULL,
    group_id bigint NOT NULL,
    user_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    active boolean DEFAULT false,
    extern_uid character varying(255) NOT NULL
);

CREATE SEQUENCE scim_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE scim_identities_id_seq OWNED BY scim_identities.id;

CREATE TABLE scim_oauth_access_tokens (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    group_id integer NOT NULL,
    token_encrypted character varying NOT NULL
);

CREATE SEQUENCE scim_oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE scim_oauth_access_tokens_id_seq OWNED BY scim_oauth_access_tokens.id;

CREATE TABLE security_findings (
    id bigint NOT NULL,
    scan_id bigint NOT NULL,
    scanner_id bigint NOT NULL,
    severity smallint NOT NULL,
    confidence smallint NOT NULL,
    project_fingerprint text NOT NULL,
    deduplicated boolean DEFAULT false NOT NULL,
    "position" integer,
    CONSTRAINT check_b9508c6df8 CHECK ((char_length(project_fingerprint) <= 40))
);

CREATE SEQUENCE security_findings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE security_findings_id_seq OWNED BY security_findings.id;

CREATE TABLE security_scans (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    build_id bigint NOT NULL,
    scan_type smallint NOT NULL,
    scanned_resources_count integer
);

CREATE SEQUENCE security_scans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE security_scans_id_seq OWNED BY security_scans.id;

CREATE TABLE self_managed_prometheus_alert_events (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    environment_id bigint,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    status smallint NOT NULL,
    title character varying(255) NOT NULL,
    query_expression character varying(255),
    payload_key character varying(255) NOT NULL
);

CREATE SEQUENCE self_managed_prometheus_alert_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE self_managed_prometheus_alert_events_id_seq OWNED BY self_managed_prometheus_alert_events.id;

CREATE TABLE sent_notifications (
    id integer NOT NULL,
    project_id integer,
    noteable_id integer,
    noteable_type character varying,
    recipient_id integer,
    commit_id character varying,
    reply_key character varying NOT NULL,
    line_code character varying,
    note_type character varying,
    "position" text,
    in_reply_to_discussion_id character varying
);

CREATE SEQUENCE sent_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE sent_notifications_id_seq OWNED BY sent_notifications.id;

CREATE TABLE sentry_issues (
    id bigint NOT NULL,
    issue_id bigint NOT NULL,
    sentry_issue_identifier bigint NOT NULL
);

CREATE SEQUENCE sentry_issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE sentry_issues_id_seq OWNED BY sentry_issues.id;

CREATE TABLE serverless_domain_cluster (
    uuid character varying(14) NOT NULL,
    pages_domain_id bigint NOT NULL,
    clusters_applications_knative_id bigint NOT NULL,
    creator_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    encrypted_key text,
    encrypted_key_iv character varying(255),
    certificate text
);

CREATE TABLE service_desk_settings (
    project_id bigint NOT NULL,
    issue_template_key character varying(255),
    outgoing_name character varying(255),
    project_key character varying(255)
);

CREATE TABLE services (
    id integer NOT NULL,
    type character varying,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    active boolean DEFAULT false NOT NULL,
    properties text,
    push_events boolean DEFAULT true,
    issues_events boolean DEFAULT true,
    merge_requests_events boolean DEFAULT true,
    tag_push_events boolean DEFAULT true,
    note_events boolean DEFAULT true NOT NULL,
    category character varying DEFAULT 'common'::character varying NOT NULL,
    wiki_page_events boolean DEFAULT true,
    pipeline_events boolean DEFAULT false NOT NULL,
    confidential_issues_events boolean DEFAULT true NOT NULL,
    commit_events boolean DEFAULT true NOT NULL,
    job_events boolean DEFAULT false NOT NULL,
    confidential_note_events boolean DEFAULT true,
    deployment_events boolean DEFAULT false NOT NULL,
    comment_on_event_enabled boolean DEFAULT true NOT NULL,
    template boolean DEFAULT false,
    instance boolean DEFAULT false NOT NULL,
    comment_detail smallint,
    inherit_from_id bigint,
    alert_events boolean,
    group_id bigint
);

CREATE SEQUENCE services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE services_id_seq OWNED BY services.id;

CREATE TABLE shards (
    id integer NOT NULL,
    name character varying NOT NULL
);

CREATE SEQUENCE shards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE shards_id_seq OWNED BY shards.id;

CREATE TABLE slack_integrations (
    id integer NOT NULL,
    service_id integer NOT NULL,
    team_id character varying NOT NULL,
    team_name character varying NOT NULL,
    alias character varying NOT NULL,
    user_id character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE slack_integrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE slack_integrations_id_seq OWNED BY slack_integrations.id;

CREATE TABLE smartcard_identities (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    subject character varying NOT NULL,
    issuer character varying NOT NULL
);

CREATE SEQUENCE smartcard_identities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE smartcard_identities_id_seq OWNED BY smartcard_identities.id;

CREATE TABLE snippet_repositories (
    snippet_id bigint NOT NULL,
    shard_id bigint NOT NULL,
    disk_path character varying(80) NOT NULL,
    verification_retry_count smallint,
    verification_retry_at timestamp with time zone,
    verified_at timestamp with time zone,
    verification_checksum bytea,
    verification_failure text,
    verification_state smallint DEFAULT 0,
    verification_started_at timestamp with time zone,
    CONSTRAINT snippet_repositories_verification_failure_text_limit CHECK ((char_length(verification_failure) <= 255))
);

CREATE TABLE snippet_statistics (
    snippet_id bigint NOT NULL,
    repository_size bigint DEFAULT 0 NOT NULL,
    file_count bigint DEFAULT 0 NOT NULL,
    commit_count bigint DEFAULT 0 NOT NULL
);

CREATE TABLE snippet_user_mentions (
    id bigint NOT NULL,
    snippet_id integer NOT NULL,
    note_id integer,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[]
);

CREATE SEQUENCE snippet_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE snippet_user_mentions_id_seq OWNED BY snippet_user_mentions.id;

CREATE TABLE snippets (
    id integer NOT NULL,
    title character varying,
    content text,
    author_id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    file_name character varying,
    type character varying,
    visibility_level integer DEFAULT 0 NOT NULL,
    title_html text,
    content_html text,
    cached_markdown_version integer,
    description text,
    description_html text,
    encrypted_secret_token character varying(255),
    encrypted_secret_token_iv character varying(255),
    secret boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE snippets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE snippets_id_seq OWNED BY snippets.id;

CREATE TABLE software_license_policies (
    id integer NOT NULL,
    project_id integer NOT NULL,
    software_license_id integer NOT NULL,
    classification integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE software_license_policies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE software_license_policies_id_seq OWNED BY software_license_policies.id;

CREATE TABLE software_licenses (
    id integer NOT NULL,
    name character varying NOT NULL,
    spdx_identifier character varying(255)
);

CREATE SEQUENCE software_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE software_licenses_id_seq OWNED BY software_licenses.id;

CREATE TABLE spam_logs (
    id integer NOT NULL,
    user_id integer,
    source_ip character varying,
    user_agent character varying,
    via_api boolean,
    noteable_type character varying,
    title character varying,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    submitted_as_ham boolean DEFAULT false NOT NULL,
    recaptcha_verified boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE spam_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE spam_logs_id_seq OWNED BY spam_logs.id;

CREATE TABLE sprints (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    start_date date,
    due_date date,
    project_id bigint,
    group_id bigint,
    iid integer NOT NULL,
    cached_markdown_version integer,
    title text NOT NULL,
    title_html text,
    description text,
    description_html text,
    state_enum smallint DEFAULT 1 NOT NULL,
    CONSTRAINT sprints_must_belong_to_project_or_group CHECK ((((project_id <> NULL::bigint) AND (group_id IS NULL)) OR ((group_id <> NULL::bigint) AND (project_id IS NULL)))),
    CONSTRAINT sprints_title CHECK ((char_length(title) <= 255))
);

CREATE SEQUENCE sprints_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE sprints_id_seq OWNED BY sprints.id;

CREATE TABLE status_page_published_incidents (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    issue_id bigint NOT NULL
);

CREATE SEQUENCE status_page_published_incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE status_page_published_incidents_id_seq OWNED BY status_page_published_incidents.id;

CREATE TABLE status_page_settings (
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    aws_s3_bucket_name character varying(63) NOT NULL,
    aws_region character varying(255) NOT NULL,
    aws_access_key character varying(255) NOT NULL,
    encrypted_aws_secret_key character varying(255) NOT NULL,
    encrypted_aws_secret_key_iv character varying(255) NOT NULL,
    status_page_url text,
    CONSTRAINT check_75a79cd992 CHECK ((char_length(status_page_url) <= 1024))
);

CREATE SEQUENCE status_page_settings_project_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE status_page_settings_project_id_seq OWNED BY status_page_settings.project_id;

CREATE TABLE subscriptions (
    id integer NOT NULL,
    user_id integer,
    subscribable_id integer,
    subscribable_type character varying,
    subscribed boolean,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    project_id integer
);

CREATE SEQUENCE subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE subscriptions_id_seq OWNED BY subscriptions.id;

CREATE TABLE suggestions (
    id bigint NOT NULL,
    note_id integer NOT NULL,
    relative_order smallint NOT NULL,
    applied boolean DEFAULT false NOT NULL,
    commit_id character varying,
    from_content text NOT NULL,
    to_content text NOT NULL,
    lines_above integer DEFAULT 0 NOT NULL,
    lines_below integer DEFAULT 0 NOT NULL,
    outdated boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE suggestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE suggestions_id_seq OWNED BY suggestions.id;

CREATE TABLE system_note_metadata (
    id integer NOT NULL,
    note_id integer NOT NULL,
    commit_count integer,
    action character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description_version_id bigint
);

CREATE SEQUENCE system_note_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE system_note_metadata_id_seq OWNED BY system_note_metadata.id;

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    taggable_type character varying,
    tagger_id integer,
    tagger_type character varying,
    context character varying,
    created_at timestamp without time zone
);

CREATE SEQUENCE taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying,
    taggings_count integer DEFAULT 0
);

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;

CREATE TABLE term_agreements (
    id integer NOT NULL,
    term_id integer NOT NULL,
    user_id integer NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE term_agreements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE term_agreements_id_seq OWNED BY term_agreements.id;

CREATE TABLE terraform_state_versions (
    id bigint NOT NULL,
    terraform_state_id bigint NOT NULL,
    created_by_user_id bigint,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    version integer NOT NULL,
    file_store smallint NOT NULL,
    file text NOT NULL,
    verification_retry_count smallint,
    verification_retry_at timestamp with time zone,
    verified_at timestamp with time zone,
    verification_checksum bytea,
    verification_failure text,
    verification_state smallint DEFAULT 0,
    verification_started_at timestamp with time zone,
    CONSTRAINT check_0824bb7bbd CHECK ((char_length(file) <= 255)),
    CONSTRAINT tf_state_versions_verification_failure_text_limit CHECK ((char_length(verification_failure) <= 255))
);

CREATE SEQUENCE terraform_state_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE terraform_state_versions_id_seq OWNED BY terraform_state_versions.id;

CREATE TABLE terraform_states (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    file_store smallint,
    file character varying(255),
    lock_xid character varying(255),
    locked_at timestamp with time zone,
    locked_by_user_id bigint,
    uuid character varying(32) NOT NULL,
    name character varying(255),
    verification_retry_at timestamp with time zone,
    verified_at timestamp with time zone,
    verification_retry_count smallint,
    verification_checksum bytea,
    verification_failure text,
    versioning_enabled boolean DEFAULT false NOT NULL,
    CONSTRAINT check_21a47163ea CHECK ((char_length(verification_failure) <= 255))
);

CREATE SEQUENCE terraform_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE terraform_states_id_seq OWNED BY terraform_states.id;

CREATE TABLE timelogs (
    id integer NOT NULL,
    time_spent integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    issue_id integer,
    merge_request_id integer,
    spent_at timestamp without time zone,
    note_id integer
);

CREATE SEQUENCE timelogs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE timelogs_id_seq OWNED BY timelogs.id;

CREATE TABLE todos (
    id integer NOT NULL,
    user_id integer NOT NULL,
    project_id integer,
    target_id integer,
    target_type character varying NOT NULL,
    author_id integer NOT NULL,
    action integer NOT NULL,
    state character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    note_id integer,
    commit_id character varying,
    group_id integer,
    resolved_by_action smallint
);

CREATE SEQUENCE todos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE todos_id_seq OWNED BY todos.id;

CREATE TABLE trending_projects (
    id integer NOT NULL,
    project_id integer NOT NULL
);

CREATE SEQUENCE trending_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE trending_projects_id_seq OWNED BY trending_projects.id;

CREATE TABLE u2f_registrations (
    id integer NOT NULL,
    certificate text,
    key_handle character varying,
    public_key character varying,
    counter integer,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying
);

CREATE SEQUENCE u2f_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE u2f_registrations_id_seq OWNED BY u2f_registrations.id;

CREATE TABLE uploads (
    id integer NOT NULL,
    size bigint NOT NULL,
    path character varying(511) NOT NULL,
    checksum character varying(64),
    model_id integer,
    model_type character varying,
    uploader character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    store integer DEFAULT 1,
    mount_point character varying,
    secret character varying,
    CONSTRAINT check_5e9547379c CHECK ((store IS NOT NULL))
);

CREATE SEQUENCE uploads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE uploads_id_seq OWNED BY uploads.id;

CREATE TABLE user_agent_details (
    id integer NOT NULL,
    user_agent character varying NOT NULL,
    ip_address character varying NOT NULL,
    subject_id integer NOT NULL,
    subject_type character varying NOT NULL,
    submitted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE user_agent_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_agent_details_id_seq OWNED BY user_agent_details.id;

CREATE TABLE user_callouts (
    id integer NOT NULL,
    feature_name integer NOT NULL,
    user_id integer NOT NULL,
    dismissed_at timestamp with time zone
);

CREATE SEQUENCE user_callouts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_callouts_id_seq OWNED BY user_callouts.id;

CREATE TABLE user_canonical_emails (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    user_id bigint NOT NULL,
    canonical_email character varying NOT NULL
);

CREATE SEQUENCE user_canonical_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_canonical_emails_id_seq OWNED BY user_canonical_emails.id;

CREATE TABLE user_custom_attributes (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer NOT NULL,
    key character varying NOT NULL,
    value character varying NOT NULL
);

CREATE SEQUENCE user_custom_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_custom_attributes_id_seq OWNED BY user_custom_attributes.id;

CREATE TABLE user_details (
    user_id bigint NOT NULL,
    job_title character varying(200) DEFAULT ''::character varying NOT NULL,
    bio character varying(255) DEFAULT ''::character varying NOT NULL,
    bio_html text,
    cached_markdown_version integer,
    webauthn_xid text,
    CONSTRAINT check_245664af82 CHECK ((char_length(webauthn_xid) <= 100))
);

CREATE SEQUENCE user_details_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_details_user_id_seq OWNED BY user_details.user_id;

CREATE TABLE user_highest_roles (
    user_id bigint NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    highest_access_level integer
);

CREATE TABLE user_interacted_projects (
    user_id integer NOT NULL,
    project_id integer NOT NULL
);

CREATE TABLE user_preferences (
    id integer NOT NULL,
    user_id integer NOT NULL,
    issue_notes_filter smallint DEFAULT 0 NOT NULL,
    merge_request_notes_filter smallint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    epics_sort character varying,
    roadmap_epics_state integer,
    epic_notes_filter smallint DEFAULT 0 NOT NULL,
    issues_sort character varying,
    merge_requests_sort character varying,
    roadmaps_sort character varying,
    first_day_of_week integer,
    timezone character varying,
    time_display_relative boolean,
    time_format_in_24h boolean,
    projects_sort character varying(64),
    show_whitespace_in_diffs boolean DEFAULT true NOT NULL,
    sourcegraph_enabled boolean,
    setup_for_company boolean,
    render_whitespace_in_code boolean,
    tab_width smallint,
    feature_filter_type bigint,
    experience_level smallint,
    view_diffs_file_by_file boolean DEFAULT false NOT NULL,
    gitpod_enabled boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE user_preferences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_preferences_id_seq OWNED BY user_preferences.id;

CREATE TABLE user_statuses (
    user_id integer NOT NULL,
    cached_markdown_version integer,
    emoji character varying DEFAULT 'speech_balloon'::character varying NOT NULL,
    message character varying(100),
    message_html character varying
);

CREATE SEQUENCE user_statuses_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_statuses_user_id_seq OWNED BY user_statuses.user_id;

CREATE TABLE user_synced_attributes_metadata (
    id integer NOT NULL,
    name_synced boolean DEFAULT false,
    email_synced boolean DEFAULT false,
    location_synced boolean DEFAULT false,
    user_id integer NOT NULL,
    provider character varying
);

CREATE SEQUENCE user_synced_attributes_metadata_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE user_synced_attributes_metadata_id_seq OWNED BY user_synced_attributes_metadata.id;

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying,
    admin boolean DEFAULT false NOT NULL,
    projects_limit integer NOT NULL,
    skype character varying DEFAULT ''::character varying NOT NULL,
    linkedin character varying DEFAULT ''::character varying NOT NULL,
    twitter character varying DEFAULT ''::character varying NOT NULL,
    failed_attempts integer DEFAULT 0,
    locked_at timestamp without time zone,
    username character varying,
    can_create_group boolean DEFAULT true NOT NULL,
    can_create_team boolean DEFAULT true NOT NULL,
    state character varying,
    color_scheme_id integer DEFAULT 1 NOT NULL,
    password_expires_at timestamp without time zone,
    created_by_id integer,
    last_credential_check_at timestamp without time zone,
    avatar character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    hide_no_ssh_key boolean DEFAULT false,
    website_url character varying DEFAULT ''::character varying NOT NULL,
    admin_email_unsubscribed_at timestamp without time zone,
    notification_email character varying,
    hide_no_password boolean DEFAULT false,
    password_automatically_set boolean DEFAULT false,
    location character varying,
    encrypted_otp_secret character varying,
    encrypted_otp_secret_iv character varying,
    encrypted_otp_secret_salt character varying,
    otp_required_for_login boolean DEFAULT false NOT NULL,
    otp_backup_codes text,
    public_email character varying DEFAULT ''::character varying NOT NULL,
    dashboard integer DEFAULT 0,
    project_view integer DEFAULT 0,
    consumed_timestep integer,
    layout integer DEFAULT 0,
    hide_project_limit boolean DEFAULT false,
    note text,
    unlock_token character varying,
    otp_grace_period_started_at timestamp without time zone,
    external boolean DEFAULT false,
    incoming_email_token character varying,
    organization character varying,
    auditor boolean DEFAULT false NOT NULL,
    require_two_factor_authentication_from_group boolean DEFAULT false NOT NULL,
    two_factor_grace_period integer DEFAULT 48 NOT NULL,
    last_activity_on date,
    notified_of_own_activity boolean,
    preferred_language character varying,
    email_opted_in boolean,
    email_opted_in_ip character varying,
    email_opted_in_source_id integer,
    email_opted_in_at timestamp without time zone,
    theme_id smallint,
    accepted_term_id integer,
    feed_token character varying,
    private_profile boolean DEFAULT false NOT NULL,
    roadmap_layout smallint,
    include_private_contributions boolean,
    commit_email character varying,
    group_view integer,
    managing_group_id integer,
    first_name character varying(255),
    last_name character varying(255),
    static_object_token character varying(255),
    role smallint,
    user_type smallint
);

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE users_id_seq OWNED BY users.id;

CREATE TABLE users_ops_dashboard_projects (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    user_id integer NOT NULL,
    project_id integer NOT NULL
);

CREATE SEQUENCE users_ops_dashboard_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE users_ops_dashboard_projects_id_seq OWNED BY users_ops_dashboard_projects.id;

CREATE TABLE users_security_dashboard_projects (
    user_id bigint NOT NULL,
    project_id bigint NOT NULL
);

CREATE TABLE users_star_projects (
    id integer NOT NULL,
    project_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE users_star_projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE users_star_projects_id_seq OWNED BY users_star_projects.id;

CREATE TABLE users_statistics (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    without_groups_and_projects integer DEFAULT 0 NOT NULL,
    with_highest_role_guest integer DEFAULT 0 NOT NULL,
    with_highest_role_reporter integer DEFAULT 0 NOT NULL,
    with_highest_role_developer integer DEFAULT 0 NOT NULL,
    with_highest_role_maintainer integer DEFAULT 0 NOT NULL,
    with_highest_role_owner integer DEFAULT 0 NOT NULL,
    bots integer DEFAULT 0 NOT NULL,
    blocked integer DEFAULT 0 NOT NULL
);

CREATE SEQUENCE users_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE users_statistics_id_seq OWNED BY users_statistics.id;

CREATE TABLE vulnerabilities (
    id bigint NOT NULL,
    milestone_id bigint,
    epic_id bigint,
    project_id bigint NOT NULL,
    author_id bigint NOT NULL,
    updated_by_id bigint,
    last_edited_by_id bigint,
    start_date date,
    due_date date,
    last_edited_at timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    title character varying(255) NOT NULL,
    title_html text,
    description text,
    description_html text,
    start_date_sourcing_milestone_id bigint,
    due_date_sourcing_milestone_id bigint,
    state smallint DEFAULT 1 NOT NULL,
    severity smallint NOT NULL,
    severity_overridden boolean DEFAULT false,
    confidence smallint NOT NULL,
    confidence_overridden boolean DEFAULT false,
    resolved_by_id bigint,
    resolved_at timestamp with time zone,
    report_type smallint NOT NULL,
    cached_markdown_version integer,
    confirmed_by_id bigint,
    confirmed_at timestamp with time zone,
    dismissed_at timestamp with time zone,
    dismissed_by_id bigint,
    resolved_on_default_branch boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE vulnerabilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerabilities_id_seq OWNED BY vulnerabilities.id;

CREATE TABLE vulnerability_exports (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    status character varying(255) NOT NULL,
    file character varying(255),
    project_id bigint,
    author_id bigint NOT NULL,
    file_store integer,
    format smallint DEFAULT 0 NOT NULL,
    group_id integer
);

CREATE SEQUENCE vulnerability_exports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_exports_id_seq OWNED BY vulnerability_exports.id;

CREATE TABLE vulnerability_feedback (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    feedback_type smallint NOT NULL,
    category smallint NOT NULL,
    project_id integer NOT NULL,
    author_id integer NOT NULL,
    pipeline_id integer,
    issue_id integer,
    project_fingerprint character varying(40) NOT NULL,
    merge_request_id integer,
    comment_author_id integer,
    comment text,
    comment_timestamp timestamp with time zone
);

CREATE SEQUENCE vulnerability_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_feedback_id_seq OWNED BY vulnerability_feedback.id;

CREATE TABLE vulnerability_historical_statistics (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    critical integer DEFAULT 0 NOT NULL,
    high integer DEFAULT 0 NOT NULL,
    medium integer DEFAULT 0 NOT NULL,
    low integer DEFAULT 0 NOT NULL,
    unknown integer DEFAULT 0 NOT NULL,
    info integer DEFAULT 0 NOT NULL,
    date date NOT NULL,
    letter_grade smallint NOT NULL
);

CREATE SEQUENCE vulnerability_historical_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_historical_statistics_id_seq OWNED BY vulnerability_historical_statistics.id;

CREATE TABLE vulnerability_identifiers (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    fingerprint bytea NOT NULL,
    external_type character varying NOT NULL,
    external_id character varying NOT NULL,
    name character varying NOT NULL,
    url text
);

CREATE SEQUENCE vulnerability_identifiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_identifiers_id_seq OWNED BY vulnerability_identifiers.id;

CREATE TABLE vulnerability_issue_links (
    id bigint NOT NULL,
    vulnerability_id bigint NOT NULL,
    issue_id bigint NOT NULL,
    link_type smallint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);

CREATE SEQUENCE vulnerability_issue_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_issue_links_id_seq OWNED BY vulnerability_issue_links.id;

CREATE TABLE vulnerability_occurrence_identifiers (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    occurrence_id bigint NOT NULL,
    identifier_id bigint NOT NULL
);

CREATE SEQUENCE vulnerability_occurrence_identifiers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_occurrence_identifiers_id_seq OWNED BY vulnerability_occurrence_identifiers.id;

CREATE TABLE vulnerability_occurrence_pipelines (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    occurrence_id bigint NOT NULL,
    pipeline_id integer NOT NULL
);

CREATE SEQUENCE vulnerability_occurrence_pipelines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_occurrence_pipelines_id_seq OWNED BY vulnerability_occurrence_pipelines.id;

CREATE TABLE vulnerability_occurrences (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    severity smallint NOT NULL,
    confidence smallint NOT NULL,
    report_type smallint NOT NULL,
    project_id integer NOT NULL,
    scanner_id bigint NOT NULL,
    primary_identifier_id bigint NOT NULL,
    project_fingerprint bytea NOT NULL,
    location_fingerprint bytea NOT NULL,
    uuid character varying(36) NOT NULL,
    name character varying NOT NULL,
    metadata_version character varying NOT NULL,
    raw_metadata text NOT NULL,
    vulnerability_id bigint
);

CREATE SEQUENCE vulnerability_occurrences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_occurrences_id_seq OWNED BY vulnerability_occurrences.id;

CREATE TABLE vulnerability_scanners (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    external_id character varying NOT NULL,
    name character varying NOT NULL,
    vendor text DEFAULT 'GitLab'::text NOT NULL
);

CREATE SEQUENCE vulnerability_scanners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_scanners_id_seq OWNED BY vulnerability_scanners.id;

CREATE TABLE vulnerability_statistics (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    critical integer DEFAULT 0 NOT NULL,
    high integer DEFAULT 0 NOT NULL,
    medium integer DEFAULT 0 NOT NULL,
    low integer DEFAULT 0 NOT NULL,
    unknown integer DEFAULT 0 NOT NULL,
    info integer DEFAULT 0 NOT NULL,
    letter_grade smallint NOT NULL
);

CREATE SEQUENCE vulnerability_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_statistics_id_seq OWNED BY vulnerability_statistics.id;

CREATE TABLE vulnerability_user_mentions (
    id bigint NOT NULL,
    vulnerability_id bigint NOT NULL,
    note_id integer,
    mentioned_users_ids integer[],
    mentioned_projects_ids integer[],
    mentioned_groups_ids integer[]
);

CREATE SEQUENCE vulnerability_user_mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE vulnerability_user_mentions_id_seq OWNED BY vulnerability_user_mentions.id;

CREATE TABLE web_hook_logs (
    id integer NOT NULL,
    web_hook_id integer NOT NULL,
    trigger character varying,
    url character varying,
    request_headers text,
    request_data text,
    response_headers text,
    response_body text,
    response_status character varying,
    execution_duration double precision,
    internal_error_message character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE web_hook_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE web_hook_logs_id_seq OWNED BY web_hook_logs.id;

CREATE TABLE web_hooks (
    id integer NOT NULL,
    project_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying DEFAULT 'ProjectHook'::character varying,
    service_id integer,
    push_events boolean DEFAULT true NOT NULL,
    issues_events boolean DEFAULT false NOT NULL,
    merge_requests_events boolean DEFAULT false NOT NULL,
    tag_push_events boolean DEFAULT false,
    group_id integer,
    note_events boolean DEFAULT false NOT NULL,
    enable_ssl_verification boolean DEFAULT true,
    wiki_page_events boolean DEFAULT false NOT NULL,
    pipeline_events boolean DEFAULT false NOT NULL,
    confidential_issues_events boolean DEFAULT false NOT NULL,
    repository_update_events boolean DEFAULT false NOT NULL,
    job_events boolean DEFAULT false NOT NULL,
    confidential_note_events boolean,
    push_events_branch_filter text,
    encrypted_token character varying,
    encrypted_token_iv character varying,
    encrypted_url character varying,
    encrypted_url_iv character varying,
    deployment_events boolean DEFAULT false NOT NULL
);

CREATE SEQUENCE web_hooks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE web_hooks_id_seq OWNED BY web_hooks.id;

CREATE TABLE webauthn_registrations (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    counter bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    credential_xid text NOT NULL,
    name text NOT NULL,
    public_key text NOT NULL,
    u2f_registration_id integer,
    CONSTRAINT check_242f0cc65c CHECK ((char_length(credential_xid) <= 255)),
    CONSTRAINT check_2f02e74321 CHECK ((char_length(name) <= 255))
);

CREATE SEQUENCE webauthn_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE webauthn_registrations_id_seq OWNED BY webauthn_registrations.id;

CREATE TABLE wiki_page_meta (
    id integer NOT NULL,
    project_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    title character varying(255) NOT NULL
);

CREATE SEQUENCE wiki_page_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE wiki_page_meta_id_seq OWNED BY wiki_page_meta.id;

CREATE TABLE wiki_page_slugs (
    id integer NOT NULL,
    canonical boolean DEFAULT false NOT NULL,
    wiki_page_meta_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    slug character varying(2048) NOT NULL
);

CREATE SEQUENCE wiki_page_slugs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE wiki_page_slugs_id_seq OWNED BY wiki_page_slugs.id;

CREATE TABLE x509_certificates (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    subject_key_identifier character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    serial_number bytea NOT NULL,
    certificate_status smallint DEFAULT 0 NOT NULL,
    x509_issuer_id bigint NOT NULL
);

CREATE SEQUENCE x509_certificates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE x509_certificates_id_seq OWNED BY x509_certificates.id;

CREATE TABLE x509_commit_signatures (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    project_id bigint NOT NULL,
    x509_certificate_id bigint NOT NULL,
    commit_sha bytea NOT NULL,
    verification_status smallint DEFAULT 0 NOT NULL
);

CREATE SEQUENCE x509_commit_signatures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE x509_commit_signatures_id_seq OWNED BY x509_commit_signatures.id;

CREATE TABLE x509_issuers (
    id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    subject_key_identifier character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    crl_url character varying(255) NOT NULL
);

CREATE SEQUENCE x509_issuers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE x509_issuers_id_seq OWNED BY x509_issuers.id;

CREATE TABLE zoom_meetings (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    issue_id bigint NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    issue_status smallint DEFAULT 1 NOT NULL,
    url character varying(255)
);

CREATE SEQUENCE zoom_meetings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE zoom_meetings_id_seq OWNED BY zoom_meetings.id;

ALTER TABLE ONLY abuse_reports ALTER COLUMN id SET DEFAULT nextval('abuse_reports_id_seq'::regclass);

ALTER TABLE ONLY alert_management_alert_assignees ALTER COLUMN id SET DEFAULT nextval('alert_management_alert_assignees_id_seq'::regclass);

ALTER TABLE ONLY alert_management_alert_user_mentions ALTER COLUMN id SET DEFAULT nextval('alert_management_alert_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY alert_management_alerts ALTER COLUMN id SET DEFAULT nextval('alert_management_alerts_id_seq'::regclass);

ALTER TABLE ONLY alert_management_http_integrations ALTER COLUMN id SET DEFAULT nextval('alert_management_http_integrations_id_seq'::regclass);

ALTER TABLE ONLY alerts_service_data ALTER COLUMN id SET DEFAULT nextval('alerts_service_data_id_seq'::regclass);

ALTER TABLE ONLY allowed_email_domains ALTER COLUMN id SET DEFAULT nextval('allowed_email_domains_id_seq'::regclass);

ALTER TABLE ONLY analytics_cycle_analytics_group_stages ALTER COLUMN id SET DEFAULT nextval('analytics_cycle_analytics_group_stages_id_seq'::regclass);

ALTER TABLE ONLY analytics_cycle_analytics_group_value_streams ALTER COLUMN id SET DEFAULT nextval('analytics_cycle_analytics_group_value_streams_id_seq'::regclass);

ALTER TABLE ONLY analytics_cycle_analytics_project_stages ALTER COLUMN id SET DEFAULT nextval('analytics_cycle_analytics_project_stages_id_seq'::regclass);

ALTER TABLE ONLY analytics_instance_statistics_measurements ALTER COLUMN id SET DEFAULT nextval('analytics_instance_statistics_measurements_id_seq'::regclass);

ALTER TABLE ONLY appearances ALTER COLUMN id SET DEFAULT nextval('appearances_id_seq'::regclass);

ALTER TABLE ONLY application_setting_terms ALTER COLUMN id SET DEFAULT nextval('application_setting_terms_id_seq'::regclass);

ALTER TABLE ONLY application_settings ALTER COLUMN id SET DEFAULT nextval('application_settings_id_seq'::regclass);

ALTER TABLE ONLY approval_merge_request_rule_sources ALTER COLUMN id SET DEFAULT nextval('approval_merge_request_rule_sources_id_seq'::regclass);

ALTER TABLE ONLY approval_merge_request_rules ALTER COLUMN id SET DEFAULT nextval('approval_merge_request_rules_id_seq'::regclass);

ALTER TABLE ONLY approval_merge_request_rules_approved_approvers ALTER COLUMN id SET DEFAULT nextval('approval_merge_request_rules_approved_approvers_id_seq'::regclass);

ALTER TABLE ONLY approval_merge_request_rules_groups ALTER COLUMN id SET DEFAULT nextval('approval_merge_request_rules_groups_id_seq'::regclass);

ALTER TABLE ONLY approval_merge_request_rules_users ALTER COLUMN id SET DEFAULT nextval('approval_merge_request_rules_users_id_seq'::regclass);

ALTER TABLE ONLY approval_project_rules ALTER COLUMN id SET DEFAULT nextval('approval_project_rules_id_seq'::regclass);

ALTER TABLE ONLY approval_project_rules_groups ALTER COLUMN id SET DEFAULT nextval('approval_project_rules_groups_id_seq'::regclass);

ALTER TABLE ONLY approval_project_rules_users ALTER COLUMN id SET DEFAULT nextval('approval_project_rules_users_id_seq'::regclass);

ALTER TABLE ONLY approvals ALTER COLUMN id SET DEFAULT nextval('approvals_id_seq'::regclass);

ALTER TABLE ONLY approver_groups ALTER COLUMN id SET DEFAULT nextval('approver_groups_id_seq'::regclass);

ALTER TABLE ONLY approvers ALTER COLUMN id SET DEFAULT nextval('approvers_id_seq'::regclass);

ALTER TABLE ONLY atlassian_identities ALTER COLUMN user_id SET DEFAULT nextval('atlassian_identities_user_id_seq'::regclass);

ALTER TABLE ONLY audit_events ALTER COLUMN id SET DEFAULT nextval('audit_events_id_seq'::regclass);

ALTER TABLE ONLY authentication_events ALTER COLUMN id SET DEFAULT nextval('authentication_events_id_seq'::regclass);

ALTER TABLE ONLY award_emoji ALTER COLUMN id SET DEFAULT nextval('award_emoji_id_seq'::regclass);

ALTER TABLE ONLY background_migration_jobs ALTER COLUMN id SET DEFAULT nextval('background_migration_jobs_id_seq'::regclass);

ALTER TABLE ONLY badges ALTER COLUMN id SET DEFAULT nextval('badges_id_seq'::regclass);

ALTER TABLE ONLY board_assignees ALTER COLUMN id SET DEFAULT nextval('board_assignees_id_seq'::regclass);

ALTER TABLE ONLY board_group_recent_visits ALTER COLUMN id SET DEFAULT nextval('board_group_recent_visits_id_seq'::regclass);

ALTER TABLE ONLY board_labels ALTER COLUMN id SET DEFAULT nextval('board_labels_id_seq'::regclass);

ALTER TABLE ONLY board_project_recent_visits ALTER COLUMN id SET DEFAULT nextval('board_project_recent_visits_id_seq'::regclass);

ALTER TABLE ONLY board_user_preferences ALTER COLUMN id SET DEFAULT nextval('board_user_preferences_id_seq'::regclass);

ALTER TABLE ONLY boards ALTER COLUMN id SET DEFAULT nextval('boards_id_seq'::regclass);

ALTER TABLE ONLY boards_epic_user_preferences ALTER COLUMN id SET DEFAULT nextval('boards_epic_user_preferences_id_seq'::regclass);

ALTER TABLE ONLY broadcast_messages ALTER COLUMN id SET DEFAULT nextval('broadcast_messages_id_seq'::regclass);

ALTER TABLE ONLY bulk_import_configurations ALTER COLUMN id SET DEFAULT nextval('bulk_import_configurations_id_seq'::regclass);

ALTER TABLE ONLY bulk_import_entities ALTER COLUMN id SET DEFAULT nextval('bulk_import_entities_id_seq'::regclass);

ALTER TABLE ONLY bulk_imports ALTER COLUMN id SET DEFAULT nextval('bulk_imports_id_seq'::regclass);

ALTER TABLE ONLY chat_names ALTER COLUMN id SET DEFAULT nextval('chat_names_id_seq'::regclass);

ALTER TABLE ONLY chat_teams ALTER COLUMN id SET DEFAULT nextval('chat_teams_id_seq'::regclass);

ALTER TABLE ONLY ci_build_needs ALTER COLUMN id SET DEFAULT nextval('ci_build_needs_id_seq'::regclass);

ALTER TABLE ONLY ci_build_pending_states ALTER COLUMN id SET DEFAULT nextval('ci_build_pending_states_id_seq'::regclass);

ALTER TABLE ONLY ci_build_report_results ALTER COLUMN build_id SET DEFAULT nextval('ci_build_report_results_build_id_seq'::regclass);

ALTER TABLE ONLY ci_build_trace_chunks ALTER COLUMN id SET DEFAULT nextval('ci_build_trace_chunks_id_seq'::regclass);

ALTER TABLE ONLY ci_build_trace_section_names ALTER COLUMN id SET DEFAULT nextval('ci_build_trace_section_names_id_seq'::regclass);

ALTER TABLE ONLY ci_builds ALTER COLUMN id SET DEFAULT nextval('ci_builds_id_seq'::regclass);

ALTER TABLE ONLY ci_builds_metadata ALTER COLUMN id SET DEFAULT nextval('ci_builds_metadata_id_seq'::regclass);

ALTER TABLE ONLY ci_builds_runner_session ALTER COLUMN id SET DEFAULT nextval('ci_builds_runner_session_id_seq'::regclass);

ALTER TABLE ONLY ci_daily_build_group_report_results ALTER COLUMN id SET DEFAULT nextval('ci_daily_build_group_report_results_id_seq'::regclass);

ALTER TABLE ONLY ci_deleted_objects ALTER COLUMN id SET DEFAULT nextval('ci_deleted_objects_id_seq'::regclass);

ALTER TABLE ONLY ci_freeze_periods ALTER COLUMN id SET DEFAULT nextval('ci_freeze_periods_id_seq'::regclass);

ALTER TABLE ONLY ci_group_variables ALTER COLUMN id SET DEFAULT nextval('ci_group_variables_id_seq'::regclass);

ALTER TABLE ONLY ci_instance_variables ALTER COLUMN id SET DEFAULT nextval('ci_instance_variables_id_seq'::regclass);

ALTER TABLE ONLY ci_job_artifacts ALTER COLUMN id SET DEFAULT nextval('ci_job_artifacts_id_seq'::regclass);

ALTER TABLE ONLY ci_job_variables ALTER COLUMN id SET DEFAULT nextval('ci_job_variables_id_seq'::regclass);

ALTER TABLE ONLY ci_pipeline_artifacts ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_artifacts_id_seq'::regclass);

ALTER TABLE ONLY ci_pipeline_chat_data ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_chat_data_id_seq'::regclass);

ALTER TABLE ONLY ci_pipeline_messages ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_messages_id_seq'::regclass);

ALTER TABLE ONLY ci_pipeline_schedule_variables ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_schedule_variables_id_seq'::regclass);

ALTER TABLE ONLY ci_pipeline_schedules ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_schedules_id_seq'::regclass);

ALTER TABLE ONLY ci_pipeline_variables ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_variables_id_seq'::regclass);

ALTER TABLE ONLY ci_pipelines ALTER COLUMN id SET DEFAULT nextval('ci_pipelines_id_seq'::regclass);

ALTER TABLE ONLY ci_pipelines_config ALTER COLUMN pipeline_id SET DEFAULT nextval('ci_pipelines_config_pipeline_id_seq'::regclass);

ALTER TABLE ONLY ci_platform_metrics ALTER COLUMN id SET DEFAULT nextval('ci_platform_metrics_id_seq'::regclass);

ALTER TABLE ONLY ci_refs ALTER COLUMN id SET DEFAULT nextval('ci_refs_id_seq'::regclass);

ALTER TABLE ONLY ci_resource_groups ALTER COLUMN id SET DEFAULT nextval('ci_resource_groups_id_seq'::regclass);

ALTER TABLE ONLY ci_resources ALTER COLUMN id SET DEFAULT nextval('ci_resources_id_seq'::regclass);

ALTER TABLE ONLY ci_runner_namespaces ALTER COLUMN id SET DEFAULT nextval('ci_runner_namespaces_id_seq'::regclass);

ALTER TABLE ONLY ci_runner_projects ALTER COLUMN id SET DEFAULT nextval('ci_runner_projects_id_seq'::regclass);

ALTER TABLE ONLY ci_runners ALTER COLUMN id SET DEFAULT nextval('ci_runners_id_seq'::regclass);

ALTER TABLE ONLY ci_sources_pipelines ALTER COLUMN id SET DEFAULT nextval('ci_sources_pipelines_id_seq'::regclass);

ALTER TABLE ONLY ci_sources_projects ALTER COLUMN id SET DEFAULT nextval('ci_sources_projects_id_seq'::regclass);

ALTER TABLE ONLY ci_stages ALTER COLUMN id SET DEFAULT nextval('ci_stages_id_seq'::regclass);

ALTER TABLE ONLY ci_subscriptions_projects ALTER COLUMN id SET DEFAULT nextval('ci_subscriptions_projects_id_seq'::regclass);

ALTER TABLE ONLY ci_trigger_requests ALTER COLUMN id SET DEFAULT nextval('ci_trigger_requests_id_seq'::regclass);

ALTER TABLE ONLY ci_triggers ALTER COLUMN id SET DEFAULT nextval('ci_triggers_id_seq'::regclass);

ALTER TABLE ONLY ci_variables ALTER COLUMN id SET DEFAULT nextval('ci_variables_id_seq'::regclass);

ALTER TABLE ONLY cluster_agent_tokens ALTER COLUMN id SET DEFAULT nextval('cluster_agent_tokens_id_seq'::regclass);

ALTER TABLE ONLY cluster_agents ALTER COLUMN id SET DEFAULT nextval('cluster_agents_id_seq'::regclass);

ALTER TABLE ONLY cluster_groups ALTER COLUMN id SET DEFAULT nextval('cluster_groups_id_seq'::regclass);

ALTER TABLE ONLY cluster_platforms_kubernetes ALTER COLUMN id SET DEFAULT nextval('cluster_platforms_kubernetes_id_seq'::regclass);

ALTER TABLE ONLY cluster_projects ALTER COLUMN id SET DEFAULT nextval('cluster_projects_id_seq'::regclass);

ALTER TABLE ONLY cluster_providers_aws ALTER COLUMN id SET DEFAULT nextval('cluster_providers_aws_id_seq'::regclass);

ALTER TABLE ONLY cluster_providers_gcp ALTER COLUMN id SET DEFAULT nextval('cluster_providers_gcp_id_seq'::regclass);

ALTER TABLE ONLY clusters ALTER COLUMN id SET DEFAULT nextval('clusters_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_cert_managers ALTER COLUMN id SET DEFAULT nextval('clusters_applications_cert_managers_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_cilium ALTER COLUMN id SET DEFAULT nextval('clusters_applications_cilium_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_crossplane ALTER COLUMN id SET DEFAULT nextval('clusters_applications_crossplane_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_elastic_stacks ALTER COLUMN id SET DEFAULT nextval('clusters_applications_elastic_stacks_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_fluentd ALTER COLUMN id SET DEFAULT nextval('clusters_applications_fluentd_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_helm ALTER COLUMN id SET DEFAULT nextval('clusters_applications_helm_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_ingress ALTER COLUMN id SET DEFAULT nextval('clusters_applications_ingress_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_jupyter ALTER COLUMN id SET DEFAULT nextval('clusters_applications_jupyter_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_knative ALTER COLUMN id SET DEFAULT nextval('clusters_applications_knative_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_prometheus ALTER COLUMN id SET DEFAULT nextval('clusters_applications_prometheus_id_seq'::regclass);

ALTER TABLE ONLY clusters_applications_runners ALTER COLUMN id SET DEFAULT nextval('clusters_applications_runners_id_seq'::regclass);

ALTER TABLE ONLY clusters_kubernetes_namespaces ALTER COLUMN id SET DEFAULT nextval('clusters_kubernetes_namespaces_id_seq'::regclass);

ALTER TABLE ONLY commit_user_mentions ALTER COLUMN id SET DEFAULT nextval('commit_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY compliance_management_frameworks ALTER COLUMN id SET DEFAULT nextval('compliance_management_frameworks_id_seq'::regclass);

ALTER TABLE ONLY container_repositories ALTER COLUMN id SET DEFAULT nextval('container_repositories_id_seq'::regclass);

ALTER TABLE ONLY conversational_development_index_metrics ALTER COLUMN id SET DEFAULT nextval('conversational_development_index_metrics_id_seq'::regclass);

ALTER TABLE ONLY csv_issue_imports ALTER COLUMN id SET DEFAULT nextval('csv_issue_imports_id_seq'::regclass);

ALTER TABLE ONLY custom_emoji ALTER COLUMN id SET DEFAULT nextval('custom_emoji_id_seq'::regclass);

ALTER TABLE ONLY dast_scanner_profiles ALTER COLUMN id SET DEFAULT nextval('dast_scanner_profiles_id_seq'::regclass);

ALTER TABLE ONLY dast_site_profiles ALTER COLUMN id SET DEFAULT nextval('dast_site_profiles_id_seq'::regclass);

ALTER TABLE ONLY dast_site_tokens ALTER COLUMN id SET DEFAULT nextval('dast_site_tokens_id_seq'::regclass);

ALTER TABLE ONLY dast_site_validations ALTER COLUMN id SET DEFAULT nextval('dast_site_validations_id_seq'::regclass);

ALTER TABLE ONLY dast_sites ALTER COLUMN id SET DEFAULT nextval('dast_sites_id_seq'::regclass);

ALTER TABLE ONLY dependency_proxy_blobs ALTER COLUMN id SET DEFAULT nextval('dependency_proxy_blobs_id_seq'::regclass);

ALTER TABLE ONLY dependency_proxy_group_settings ALTER COLUMN id SET DEFAULT nextval('dependency_proxy_group_settings_id_seq'::regclass);

ALTER TABLE ONLY deploy_keys_projects ALTER COLUMN id SET DEFAULT nextval('deploy_keys_projects_id_seq'::regclass);

ALTER TABLE ONLY deploy_tokens ALTER COLUMN id SET DEFAULT nextval('deploy_tokens_id_seq'::regclass);

ALTER TABLE ONLY deployments ALTER COLUMN id SET DEFAULT nextval('deployments_id_seq'::regclass);

ALTER TABLE ONLY description_versions ALTER COLUMN id SET DEFAULT nextval('description_versions_id_seq'::regclass);

ALTER TABLE ONLY design_management_designs ALTER COLUMN id SET DEFAULT nextval('design_management_designs_id_seq'::regclass);

ALTER TABLE ONLY design_management_designs_versions ALTER COLUMN id SET DEFAULT nextval('design_management_designs_versions_id_seq'::regclass);

ALTER TABLE ONLY design_management_versions ALTER COLUMN id SET DEFAULT nextval('design_management_versions_id_seq'::regclass);

ALTER TABLE ONLY design_user_mentions ALTER COLUMN id SET DEFAULT nextval('design_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY diff_note_positions ALTER COLUMN id SET DEFAULT nextval('diff_note_positions_id_seq'::regclass);

ALTER TABLE ONLY draft_notes ALTER COLUMN id SET DEFAULT nextval('draft_notes_id_seq'::regclass);

ALTER TABLE ONLY elastic_reindexing_tasks ALTER COLUMN id SET DEFAULT nextval('elastic_reindexing_tasks_id_seq'::regclass);

ALTER TABLE ONLY emails ALTER COLUMN id SET DEFAULT nextval('emails_id_seq'::regclass);

ALTER TABLE ONLY environments ALTER COLUMN id SET DEFAULT nextval('environments_id_seq'::regclass);

ALTER TABLE ONLY epic_issues ALTER COLUMN id SET DEFAULT nextval('epic_issues_id_seq'::regclass);

ALTER TABLE ONLY epic_metrics ALTER COLUMN id SET DEFAULT nextval('epic_metrics_id_seq'::regclass);

ALTER TABLE ONLY epic_user_mentions ALTER COLUMN id SET DEFAULT nextval('epic_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY epics ALTER COLUMN id SET DEFAULT nextval('epics_id_seq'::regclass);

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);

ALTER TABLE ONLY evidences ALTER COLUMN id SET DEFAULT nextval('evidences_id_seq'::regclass);

ALTER TABLE ONLY experiment_users ALTER COLUMN id SET DEFAULT nextval('experiment_users_id_seq'::regclass);

ALTER TABLE ONLY experiments ALTER COLUMN id SET DEFAULT nextval('experiments_id_seq'::regclass);

ALTER TABLE ONLY external_pull_requests ALTER COLUMN id SET DEFAULT nextval('external_pull_requests_id_seq'::regclass);

ALTER TABLE ONLY feature_gates ALTER COLUMN id SET DEFAULT nextval('feature_gates_id_seq'::regclass);

ALTER TABLE ONLY features ALTER COLUMN id SET DEFAULT nextval('features_id_seq'::regclass);

ALTER TABLE ONLY fork_network_members ALTER COLUMN id SET DEFAULT nextval('fork_network_members_id_seq'::regclass);

ALTER TABLE ONLY fork_networks ALTER COLUMN id SET DEFAULT nextval('fork_networks_id_seq'::regclass);

ALTER TABLE ONLY geo_cache_invalidation_events ALTER COLUMN id SET DEFAULT nextval('geo_cache_invalidation_events_id_seq'::regclass);

ALTER TABLE ONLY geo_container_repository_updated_events ALTER COLUMN id SET DEFAULT nextval('geo_container_repository_updated_events_id_seq'::regclass);

ALTER TABLE ONLY geo_event_log ALTER COLUMN id SET DEFAULT nextval('geo_event_log_id_seq'::regclass);

ALTER TABLE ONLY geo_events ALTER COLUMN id SET DEFAULT nextval('geo_events_id_seq'::regclass);

ALTER TABLE ONLY geo_hashed_storage_attachments_events ALTER COLUMN id SET DEFAULT nextval('geo_hashed_storage_attachments_events_id_seq'::regclass);

ALTER TABLE ONLY geo_hashed_storage_migrated_events ALTER COLUMN id SET DEFAULT nextval('geo_hashed_storage_migrated_events_id_seq'::regclass);

ALTER TABLE ONLY geo_job_artifact_deleted_events ALTER COLUMN id SET DEFAULT nextval('geo_job_artifact_deleted_events_id_seq'::regclass);

ALTER TABLE ONLY geo_lfs_object_deleted_events ALTER COLUMN id SET DEFAULT nextval('geo_lfs_object_deleted_events_id_seq'::regclass);

ALTER TABLE ONLY geo_node_namespace_links ALTER COLUMN id SET DEFAULT nextval('geo_node_namespace_links_id_seq'::regclass);

ALTER TABLE ONLY geo_node_statuses ALTER COLUMN id SET DEFAULT nextval('geo_node_statuses_id_seq'::regclass);

ALTER TABLE ONLY geo_nodes ALTER COLUMN id SET DEFAULT nextval('geo_nodes_id_seq'::regclass);

ALTER TABLE ONLY geo_repositories_changed_events ALTER COLUMN id SET DEFAULT nextval('geo_repositories_changed_events_id_seq'::regclass);

ALTER TABLE ONLY geo_repository_created_events ALTER COLUMN id SET DEFAULT nextval('geo_repository_created_events_id_seq'::regclass);

ALTER TABLE ONLY geo_repository_deleted_events ALTER COLUMN id SET DEFAULT nextval('geo_repository_deleted_events_id_seq'::regclass);

ALTER TABLE ONLY geo_repository_renamed_events ALTER COLUMN id SET DEFAULT nextval('geo_repository_renamed_events_id_seq'::regclass);

ALTER TABLE ONLY geo_repository_updated_events ALTER COLUMN id SET DEFAULT nextval('geo_repository_updated_events_id_seq'::regclass);

ALTER TABLE ONLY geo_reset_checksum_events ALTER COLUMN id SET DEFAULT nextval('geo_reset_checksum_events_id_seq'::regclass);

ALTER TABLE ONLY geo_upload_deleted_events ALTER COLUMN id SET DEFAULT nextval('geo_upload_deleted_events_id_seq'::regclass);

ALTER TABLE ONLY gitlab_subscription_histories ALTER COLUMN id SET DEFAULT nextval('gitlab_subscription_histories_id_seq'::regclass);

ALTER TABLE ONLY gitlab_subscriptions ALTER COLUMN id SET DEFAULT nextval('gitlab_subscriptions_id_seq'::regclass);

ALTER TABLE ONLY gpg_key_subkeys ALTER COLUMN id SET DEFAULT nextval('gpg_key_subkeys_id_seq'::regclass);

ALTER TABLE ONLY gpg_keys ALTER COLUMN id SET DEFAULT nextval('gpg_keys_id_seq'::regclass);

ALTER TABLE ONLY gpg_signatures ALTER COLUMN id SET DEFAULT nextval('gpg_signatures_id_seq'::regclass);

ALTER TABLE ONLY grafana_integrations ALTER COLUMN id SET DEFAULT nextval('grafana_integrations_id_seq'::regclass);

ALTER TABLE ONLY group_custom_attributes ALTER COLUMN id SET DEFAULT nextval('group_custom_attributes_id_seq'::regclass);

ALTER TABLE ONLY group_deploy_keys ALTER COLUMN id SET DEFAULT nextval('group_deploy_keys_id_seq'::regclass);

ALTER TABLE ONLY group_deploy_keys_groups ALTER COLUMN id SET DEFAULT nextval('group_deploy_keys_groups_id_seq'::regclass);

ALTER TABLE ONLY group_deploy_tokens ALTER COLUMN id SET DEFAULT nextval('group_deploy_tokens_id_seq'::regclass);

ALTER TABLE ONLY group_group_links ALTER COLUMN id SET DEFAULT nextval('group_group_links_id_seq'::regclass);

ALTER TABLE ONLY group_import_states ALTER COLUMN group_id SET DEFAULT nextval('group_import_states_group_id_seq'::regclass);

ALTER TABLE ONLY historical_data ALTER COLUMN id SET DEFAULT nextval('historical_data_id_seq'::regclass);

ALTER TABLE ONLY identities ALTER COLUMN id SET DEFAULT nextval('identities_id_seq'::regclass);

ALTER TABLE ONLY import_export_uploads ALTER COLUMN id SET DEFAULT nextval('import_export_uploads_id_seq'::regclass);

ALTER TABLE ONLY import_failures ALTER COLUMN id SET DEFAULT nextval('import_failures_id_seq'::regclass);

ALTER TABLE ONLY index_statuses ALTER COLUMN id SET DEFAULT nextval('index_statuses_id_seq'::regclass);

ALTER TABLE ONLY insights ALTER COLUMN id SET DEFAULT nextval('insights_id_seq'::regclass);

ALTER TABLE ONLY internal_ids ALTER COLUMN id SET DEFAULT nextval('internal_ids_id_seq'::regclass);

ALTER TABLE ONLY ip_restrictions ALTER COLUMN id SET DEFAULT nextval('ip_restrictions_id_seq'::regclass);

ALTER TABLE ONLY issuable_severities ALTER COLUMN id SET DEFAULT nextval('issuable_severities_id_seq'::regclass);

ALTER TABLE ONLY issuable_slas ALTER COLUMN id SET DEFAULT nextval('issuable_slas_id_seq'::regclass);

ALTER TABLE ONLY issue_email_participants ALTER COLUMN id SET DEFAULT nextval('issue_email_participants_id_seq'::regclass);

ALTER TABLE ONLY issue_links ALTER COLUMN id SET DEFAULT nextval('issue_links_id_seq'::regclass);

ALTER TABLE ONLY issue_metrics ALTER COLUMN id SET DEFAULT nextval('issue_metrics_id_seq'::regclass);

ALTER TABLE ONLY issue_tracker_data ALTER COLUMN id SET DEFAULT nextval('issue_tracker_data_id_seq'::regclass);

ALTER TABLE ONLY issue_user_mentions ALTER COLUMN id SET DEFAULT nextval('issue_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY issues ALTER COLUMN id SET DEFAULT nextval('issues_id_seq'::regclass);

ALTER TABLE ONLY jira_connect_installations ALTER COLUMN id SET DEFAULT nextval('jira_connect_installations_id_seq'::regclass);

ALTER TABLE ONLY jira_connect_subscriptions ALTER COLUMN id SET DEFAULT nextval('jira_connect_subscriptions_id_seq'::regclass);

ALTER TABLE ONLY jira_imports ALTER COLUMN id SET DEFAULT nextval('jira_imports_id_seq'::regclass);

ALTER TABLE ONLY jira_tracker_data ALTER COLUMN id SET DEFAULT nextval('jira_tracker_data_id_seq'::regclass);

ALTER TABLE ONLY keys ALTER COLUMN id SET DEFAULT nextval('keys_id_seq'::regclass);

ALTER TABLE ONLY label_links ALTER COLUMN id SET DEFAULT nextval('label_links_id_seq'::regclass);

ALTER TABLE ONLY label_priorities ALTER COLUMN id SET DEFAULT nextval('label_priorities_id_seq'::regclass);

ALTER TABLE ONLY labels ALTER COLUMN id SET DEFAULT nextval('labels_id_seq'::regclass);

ALTER TABLE ONLY ldap_group_links ALTER COLUMN id SET DEFAULT nextval('ldap_group_links_id_seq'::regclass);

ALTER TABLE ONLY lfs_file_locks ALTER COLUMN id SET DEFAULT nextval('lfs_file_locks_id_seq'::regclass);

ALTER TABLE ONLY lfs_objects ALTER COLUMN id SET DEFAULT nextval('lfs_objects_id_seq'::regclass);

ALTER TABLE ONLY lfs_objects_projects ALTER COLUMN id SET DEFAULT nextval('lfs_objects_projects_id_seq'::regclass);

ALTER TABLE ONLY licenses ALTER COLUMN id SET DEFAULT nextval('licenses_id_seq'::regclass);

ALTER TABLE ONLY list_user_preferences ALTER COLUMN id SET DEFAULT nextval('list_user_preferences_id_seq'::regclass);

ALTER TABLE ONLY lists ALTER COLUMN id SET DEFAULT nextval('lists_id_seq'::regclass);

ALTER TABLE ONLY members ALTER COLUMN id SET DEFAULT nextval('members_id_seq'::regclass);

ALTER TABLE ONLY merge_request_assignees ALTER COLUMN id SET DEFAULT nextval('merge_request_assignees_id_seq'::regclass);

ALTER TABLE ONLY merge_request_blocks ALTER COLUMN id SET DEFAULT nextval('merge_request_blocks_id_seq'::regclass);

ALTER TABLE ONLY merge_request_context_commits ALTER COLUMN id SET DEFAULT nextval('merge_request_context_commits_id_seq'::regclass);

ALTER TABLE ONLY merge_request_diff_details ALTER COLUMN merge_request_diff_id SET DEFAULT nextval('merge_request_diff_details_merge_request_diff_id_seq'::regclass);

ALTER TABLE ONLY merge_request_diffs ALTER COLUMN id SET DEFAULT nextval('merge_request_diffs_id_seq'::regclass);

ALTER TABLE ONLY merge_request_metrics ALTER COLUMN id SET DEFAULT nextval('merge_request_metrics_id_seq'::regclass);

ALTER TABLE ONLY merge_request_reviewers ALTER COLUMN id SET DEFAULT nextval('merge_request_reviewers_id_seq'::regclass);

ALTER TABLE ONLY merge_request_user_mentions ALTER COLUMN id SET DEFAULT nextval('merge_request_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY merge_requests ALTER COLUMN id SET DEFAULT nextval('merge_requests_id_seq'::regclass);

ALTER TABLE ONLY merge_requests_closing_issues ALTER COLUMN id SET DEFAULT nextval('merge_requests_closing_issues_id_seq'::regclass);

ALTER TABLE ONLY merge_trains ALTER COLUMN id SET DEFAULT nextval('merge_trains_id_seq'::regclass);

ALTER TABLE ONLY metrics_dashboard_annotations ALTER COLUMN id SET DEFAULT nextval('metrics_dashboard_annotations_id_seq'::regclass);

ALTER TABLE ONLY metrics_users_starred_dashboards ALTER COLUMN id SET DEFAULT nextval('metrics_users_starred_dashboards_id_seq'::regclass);

ALTER TABLE ONLY milestones ALTER COLUMN id SET DEFAULT nextval('milestones_id_seq'::regclass);

ALTER TABLE ONLY namespace_statistics ALTER COLUMN id SET DEFAULT nextval('namespace_statistics_id_seq'::regclass);

ALTER TABLE ONLY namespaces ALTER COLUMN id SET DEFAULT nextval('namespaces_id_seq'::regclass);

ALTER TABLE ONLY note_diff_files ALTER COLUMN id SET DEFAULT nextval('note_diff_files_id_seq'::regclass);

ALTER TABLE ONLY notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);

ALTER TABLE ONLY notification_settings ALTER COLUMN id SET DEFAULT nextval('notification_settings_id_seq'::regclass);

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);

ALTER TABLE ONLY oauth_openid_requests ALTER COLUMN id SET DEFAULT nextval('oauth_openid_requests_id_seq'::regclass);

ALTER TABLE ONLY open_project_tracker_data ALTER COLUMN id SET DEFAULT nextval('open_project_tracker_data_id_seq'::regclass);

ALTER TABLE ONLY operations_feature_flag_scopes ALTER COLUMN id SET DEFAULT nextval('operations_feature_flag_scopes_id_seq'::regclass);

ALTER TABLE ONLY operations_feature_flags ALTER COLUMN id SET DEFAULT nextval('operations_feature_flags_id_seq'::regclass);

ALTER TABLE ONLY operations_feature_flags_clients ALTER COLUMN id SET DEFAULT nextval('operations_feature_flags_clients_id_seq'::regclass);

ALTER TABLE ONLY operations_feature_flags_issues ALTER COLUMN id SET DEFAULT nextval('operations_feature_flags_issues_id_seq'::regclass);

ALTER TABLE ONLY operations_scopes ALTER COLUMN id SET DEFAULT nextval('operations_scopes_id_seq'::regclass);

ALTER TABLE ONLY operations_strategies ALTER COLUMN id SET DEFAULT nextval('operations_strategies_id_seq'::regclass);

ALTER TABLE ONLY operations_strategies_user_lists ALTER COLUMN id SET DEFAULT nextval('operations_strategies_user_lists_id_seq'::regclass);

ALTER TABLE ONLY operations_user_lists ALTER COLUMN id SET DEFAULT nextval('operations_user_lists_id_seq'::regclass);

ALTER TABLE ONLY packages_build_infos ALTER COLUMN id SET DEFAULT nextval('packages_build_infos_id_seq'::regclass);

ALTER TABLE ONLY packages_conan_file_metadata ALTER COLUMN id SET DEFAULT nextval('packages_conan_file_metadata_id_seq'::regclass);

ALTER TABLE ONLY packages_conan_metadata ALTER COLUMN id SET DEFAULT nextval('packages_conan_metadata_id_seq'::regclass);

ALTER TABLE ONLY packages_dependencies ALTER COLUMN id SET DEFAULT nextval('packages_dependencies_id_seq'::regclass);

ALTER TABLE ONLY packages_dependency_links ALTER COLUMN id SET DEFAULT nextval('packages_dependency_links_id_seq'::regclass);

ALTER TABLE ONLY packages_events ALTER COLUMN id SET DEFAULT nextval('packages_events_id_seq'::regclass);

ALTER TABLE ONLY packages_maven_metadata ALTER COLUMN id SET DEFAULT nextval('packages_maven_metadata_id_seq'::regclass);

ALTER TABLE ONLY packages_package_files ALTER COLUMN id SET DEFAULT nextval('packages_package_files_id_seq'::regclass);

ALTER TABLE ONLY packages_packages ALTER COLUMN id SET DEFAULT nextval('packages_packages_id_seq'::regclass);

ALTER TABLE ONLY packages_tags ALTER COLUMN id SET DEFAULT nextval('packages_tags_id_seq'::regclass);

ALTER TABLE ONLY pages_deployments ALTER COLUMN id SET DEFAULT nextval('pages_deployments_id_seq'::regclass);

ALTER TABLE ONLY pages_domain_acme_orders ALTER COLUMN id SET DEFAULT nextval('pages_domain_acme_orders_id_seq'::regclass);

ALTER TABLE ONLY pages_domains ALTER COLUMN id SET DEFAULT nextval('pages_domains_id_seq'::regclass);

ALTER TABLE ONLY partitioned_foreign_keys ALTER COLUMN id SET DEFAULT nextval('partitioned_foreign_keys_id_seq'::regclass);

ALTER TABLE ONLY path_locks ALTER COLUMN id SET DEFAULT nextval('path_locks_id_seq'::regclass);

ALTER TABLE ONLY personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('personal_access_tokens_id_seq'::regclass);

ALTER TABLE ONLY plan_limits ALTER COLUMN id SET DEFAULT nextval('plan_limits_id_seq'::regclass);

ALTER TABLE ONLY plans ALTER COLUMN id SET DEFAULT nextval('plans_id_seq'::regclass);

ALTER TABLE ONLY pool_repositories ALTER COLUMN id SET DEFAULT nextval('pool_repositories_id_seq'::regclass);

ALTER TABLE ONLY postgres_reindex_actions ALTER COLUMN id SET DEFAULT nextval('postgres_reindex_actions_id_seq'::regclass);

ALTER TABLE ONLY product_analytics_events_experimental ALTER COLUMN id SET DEFAULT nextval('product_analytics_events_experimental_id_seq'::regclass);

ALTER TABLE ONLY programming_languages ALTER COLUMN id SET DEFAULT nextval('programming_languages_id_seq'::regclass);

ALTER TABLE ONLY project_aliases ALTER COLUMN id SET DEFAULT nextval('project_aliases_id_seq'::regclass);

ALTER TABLE ONLY project_auto_devops ALTER COLUMN id SET DEFAULT nextval('project_auto_devops_id_seq'::regclass);

ALTER TABLE ONLY project_ci_cd_settings ALTER COLUMN id SET DEFAULT nextval('project_ci_cd_settings_id_seq'::regclass);

ALTER TABLE ONLY project_compliance_framework_settings ALTER COLUMN project_id SET DEFAULT nextval('project_compliance_framework_settings_project_id_seq'::regclass);

ALTER TABLE ONLY project_custom_attributes ALTER COLUMN id SET DEFAULT nextval('project_custom_attributes_id_seq'::regclass);

ALTER TABLE ONLY project_daily_statistics ALTER COLUMN id SET DEFAULT nextval('project_daily_statistics_id_seq'::regclass);

ALTER TABLE ONLY project_deploy_tokens ALTER COLUMN id SET DEFAULT nextval('project_deploy_tokens_id_seq'::regclass);

ALTER TABLE ONLY project_export_jobs ALTER COLUMN id SET DEFAULT nextval('project_export_jobs_id_seq'::regclass);

ALTER TABLE ONLY project_features ALTER COLUMN id SET DEFAULT nextval('project_features_id_seq'::regclass);

ALTER TABLE ONLY project_group_links ALTER COLUMN id SET DEFAULT nextval('project_group_links_id_seq'::regclass);

ALTER TABLE ONLY project_import_data ALTER COLUMN id SET DEFAULT nextval('project_import_data_id_seq'::regclass);

ALTER TABLE ONLY project_incident_management_settings ALTER COLUMN project_id SET DEFAULT nextval('project_incident_management_settings_project_id_seq'::regclass);

ALTER TABLE ONLY project_mirror_data ALTER COLUMN id SET DEFAULT nextval('project_mirror_data_id_seq'::regclass);

ALTER TABLE ONLY project_repositories ALTER COLUMN id SET DEFAULT nextval('project_repositories_id_seq'::regclass);

ALTER TABLE ONLY project_repository_states ALTER COLUMN id SET DEFAULT nextval('project_repository_states_id_seq'::regclass);

ALTER TABLE ONLY project_repository_storage_moves ALTER COLUMN id SET DEFAULT nextval('project_repository_storage_moves_id_seq'::regclass);

ALTER TABLE ONLY project_security_settings ALTER COLUMN project_id SET DEFAULT nextval('project_security_settings_project_id_seq'::regclass);

ALTER TABLE ONLY project_statistics ALTER COLUMN id SET DEFAULT nextval('project_statistics_id_seq'::regclass);

ALTER TABLE ONLY project_tracing_settings ALTER COLUMN id SET DEFAULT nextval('project_tracing_settings_id_seq'::regclass);

ALTER TABLE ONLY projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);

ALTER TABLE ONLY prometheus_alert_events ALTER COLUMN id SET DEFAULT nextval('prometheus_alert_events_id_seq'::regclass);

ALTER TABLE ONLY prometheus_alerts ALTER COLUMN id SET DEFAULT nextval('prometheus_alerts_id_seq'::regclass);

ALTER TABLE ONLY prometheus_metrics ALTER COLUMN id SET DEFAULT nextval('prometheus_metrics_id_seq'::regclass);

ALTER TABLE ONLY protected_branch_merge_access_levels ALTER COLUMN id SET DEFAULT nextval('protected_branch_merge_access_levels_id_seq'::regclass);

ALTER TABLE ONLY protected_branch_push_access_levels ALTER COLUMN id SET DEFAULT nextval('protected_branch_push_access_levels_id_seq'::regclass);

ALTER TABLE ONLY protected_branch_unprotect_access_levels ALTER COLUMN id SET DEFAULT nextval('protected_branch_unprotect_access_levels_id_seq'::regclass);

ALTER TABLE ONLY protected_branches ALTER COLUMN id SET DEFAULT nextval('protected_branches_id_seq'::regclass);

ALTER TABLE ONLY protected_environment_deploy_access_levels ALTER COLUMN id SET DEFAULT nextval('protected_environment_deploy_access_levels_id_seq'::regclass);

ALTER TABLE ONLY protected_environments ALTER COLUMN id SET DEFAULT nextval('protected_environments_id_seq'::regclass);

ALTER TABLE ONLY protected_tag_create_access_levels ALTER COLUMN id SET DEFAULT nextval('protected_tag_create_access_levels_id_seq'::regclass);

ALTER TABLE ONLY protected_tags ALTER COLUMN id SET DEFAULT nextval('protected_tags_id_seq'::regclass);

ALTER TABLE ONLY push_rules ALTER COLUMN id SET DEFAULT nextval('push_rules_id_seq'::regclass);

ALTER TABLE ONLY raw_usage_data ALTER COLUMN id SET DEFAULT nextval('raw_usage_data_id_seq'::regclass);

ALTER TABLE ONLY redirect_routes ALTER COLUMN id SET DEFAULT nextval('redirect_routes_id_seq'::regclass);

ALTER TABLE ONLY release_links ALTER COLUMN id SET DEFAULT nextval('release_links_id_seq'::regclass);

ALTER TABLE ONLY releases ALTER COLUMN id SET DEFAULT nextval('releases_id_seq'::regclass);

ALTER TABLE ONLY remote_mirrors ALTER COLUMN id SET DEFAULT nextval('remote_mirrors_id_seq'::regclass);

ALTER TABLE ONLY required_code_owners_sections ALTER COLUMN id SET DEFAULT nextval('required_code_owners_sections_id_seq'::regclass);

ALTER TABLE ONLY requirements ALTER COLUMN id SET DEFAULT nextval('requirements_id_seq'::regclass);

ALTER TABLE ONLY requirements_management_test_reports ALTER COLUMN id SET DEFAULT nextval('requirements_management_test_reports_id_seq'::regclass);

ALTER TABLE ONLY resource_iteration_events ALTER COLUMN id SET DEFAULT nextval('resource_iteration_events_id_seq'::regclass);

ALTER TABLE ONLY resource_label_events ALTER COLUMN id SET DEFAULT nextval('resource_label_events_id_seq'::regclass);

ALTER TABLE ONLY resource_milestone_events ALTER COLUMN id SET DEFAULT nextval('resource_milestone_events_id_seq'::regclass);

ALTER TABLE ONLY resource_state_events ALTER COLUMN id SET DEFAULT nextval('resource_state_events_id_seq'::regclass);

ALTER TABLE ONLY resource_weight_events ALTER COLUMN id SET DEFAULT nextval('resource_weight_events_id_seq'::regclass);

ALTER TABLE ONLY reviews ALTER COLUMN id SET DEFAULT nextval('reviews_id_seq'::regclass);

ALTER TABLE ONLY routes ALTER COLUMN id SET DEFAULT nextval('routes_id_seq'::regclass);

ALTER TABLE ONLY saml_group_links ALTER COLUMN id SET DEFAULT nextval('saml_group_links_id_seq'::regclass);

ALTER TABLE ONLY saml_providers ALTER COLUMN id SET DEFAULT nextval('saml_providers_id_seq'::regclass);

ALTER TABLE ONLY scim_identities ALTER COLUMN id SET DEFAULT nextval('scim_identities_id_seq'::regclass);

ALTER TABLE ONLY scim_oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('scim_oauth_access_tokens_id_seq'::regclass);

ALTER TABLE ONLY security_findings ALTER COLUMN id SET DEFAULT nextval('security_findings_id_seq'::regclass);

ALTER TABLE ONLY security_scans ALTER COLUMN id SET DEFAULT nextval('security_scans_id_seq'::regclass);

ALTER TABLE ONLY self_managed_prometheus_alert_events ALTER COLUMN id SET DEFAULT nextval('self_managed_prometheus_alert_events_id_seq'::regclass);

ALTER TABLE ONLY sent_notifications ALTER COLUMN id SET DEFAULT nextval('sent_notifications_id_seq'::regclass);

ALTER TABLE ONLY sentry_issues ALTER COLUMN id SET DEFAULT nextval('sentry_issues_id_seq'::regclass);

ALTER TABLE ONLY services ALTER COLUMN id SET DEFAULT nextval('services_id_seq'::regclass);

ALTER TABLE ONLY shards ALTER COLUMN id SET DEFAULT nextval('shards_id_seq'::regclass);

ALTER TABLE ONLY slack_integrations ALTER COLUMN id SET DEFAULT nextval('slack_integrations_id_seq'::regclass);

ALTER TABLE ONLY smartcard_identities ALTER COLUMN id SET DEFAULT nextval('smartcard_identities_id_seq'::regclass);

ALTER TABLE ONLY snippet_user_mentions ALTER COLUMN id SET DEFAULT nextval('snippet_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY snippets ALTER COLUMN id SET DEFAULT nextval('snippets_id_seq'::regclass);

ALTER TABLE ONLY software_license_policies ALTER COLUMN id SET DEFAULT nextval('software_license_policies_id_seq'::regclass);

ALTER TABLE ONLY software_licenses ALTER COLUMN id SET DEFAULT nextval('software_licenses_id_seq'::regclass);

ALTER TABLE ONLY spam_logs ALTER COLUMN id SET DEFAULT nextval('spam_logs_id_seq'::regclass);

ALTER TABLE ONLY sprints ALTER COLUMN id SET DEFAULT nextval('sprints_id_seq'::regclass);

ALTER TABLE ONLY status_page_published_incidents ALTER COLUMN id SET DEFAULT nextval('status_page_published_incidents_id_seq'::regclass);

ALTER TABLE ONLY status_page_settings ALTER COLUMN project_id SET DEFAULT nextval('status_page_settings_project_id_seq'::regclass);

ALTER TABLE ONLY subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);

ALTER TABLE ONLY suggestions ALTER COLUMN id SET DEFAULT nextval('suggestions_id_seq'::regclass);

ALTER TABLE ONLY system_note_metadata ALTER COLUMN id SET DEFAULT nextval('system_note_metadata_id_seq'::regclass);

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);

ALTER TABLE ONLY term_agreements ALTER COLUMN id SET DEFAULT nextval('term_agreements_id_seq'::regclass);

ALTER TABLE ONLY terraform_state_versions ALTER COLUMN id SET DEFAULT nextval('terraform_state_versions_id_seq'::regclass);

ALTER TABLE ONLY terraform_states ALTER COLUMN id SET DEFAULT nextval('terraform_states_id_seq'::regclass);

ALTER TABLE ONLY timelogs ALTER COLUMN id SET DEFAULT nextval('timelogs_id_seq'::regclass);

ALTER TABLE ONLY todos ALTER COLUMN id SET DEFAULT nextval('todos_id_seq'::regclass);

ALTER TABLE ONLY trending_projects ALTER COLUMN id SET DEFAULT nextval('trending_projects_id_seq'::regclass);

ALTER TABLE ONLY u2f_registrations ALTER COLUMN id SET DEFAULT nextval('u2f_registrations_id_seq'::regclass);

ALTER TABLE ONLY uploads ALTER COLUMN id SET DEFAULT nextval('uploads_id_seq'::regclass);

ALTER TABLE ONLY user_agent_details ALTER COLUMN id SET DEFAULT nextval('user_agent_details_id_seq'::regclass);

ALTER TABLE ONLY user_callouts ALTER COLUMN id SET DEFAULT nextval('user_callouts_id_seq'::regclass);

ALTER TABLE ONLY user_canonical_emails ALTER COLUMN id SET DEFAULT nextval('user_canonical_emails_id_seq'::regclass);

ALTER TABLE ONLY user_custom_attributes ALTER COLUMN id SET DEFAULT nextval('user_custom_attributes_id_seq'::regclass);

ALTER TABLE ONLY user_details ALTER COLUMN user_id SET DEFAULT nextval('user_details_user_id_seq'::regclass);

ALTER TABLE ONLY user_preferences ALTER COLUMN id SET DEFAULT nextval('user_preferences_id_seq'::regclass);

ALTER TABLE ONLY user_statuses ALTER COLUMN user_id SET DEFAULT nextval('user_statuses_user_id_seq'::regclass);

ALTER TABLE ONLY user_synced_attributes_metadata ALTER COLUMN id SET DEFAULT nextval('user_synced_attributes_metadata_id_seq'::regclass);

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);

ALTER TABLE ONLY users_ops_dashboard_projects ALTER COLUMN id SET DEFAULT nextval('users_ops_dashboard_projects_id_seq'::regclass);

ALTER TABLE ONLY users_star_projects ALTER COLUMN id SET DEFAULT nextval('users_star_projects_id_seq'::regclass);

ALTER TABLE ONLY users_statistics ALTER COLUMN id SET DEFAULT nextval('users_statistics_id_seq'::regclass);

ALTER TABLE ONLY vulnerabilities ALTER COLUMN id SET DEFAULT nextval('vulnerabilities_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_exports ALTER COLUMN id SET DEFAULT nextval('vulnerability_exports_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_feedback ALTER COLUMN id SET DEFAULT nextval('vulnerability_feedback_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_historical_statistics ALTER COLUMN id SET DEFAULT nextval('vulnerability_historical_statistics_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_identifiers ALTER COLUMN id SET DEFAULT nextval('vulnerability_identifiers_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_issue_links ALTER COLUMN id SET DEFAULT nextval('vulnerability_issue_links_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_occurrence_identifiers ALTER COLUMN id SET DEFAULT nextval('vulnerability_occurrence_identifiers_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_occurrence_pipelines ALTER COLUMN id SET DEFAULT nextval('vulnerability_occurrence_pipelines_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_occurrences ALTER COLUMN id SET DEFAULT nextval('vulnerability_occurrences_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_scanners ALTER COLUMN id SET DEFAULT nextval('vulnerability_scanners_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_statistics ALTER COLUMN id SET DEFAULT nextval('vulnerability_statistics_id_seq'::regclass);

ALTER TABLE ONLY vulnerability_user_mentions ALTER COLUMN id SET DEFAULT nextval('vulnerability_user_mentions_id_seq'::regclass);

ALTER TABLE ONLY web_hook_logs ALTER COLUMN id SET DEFAULT nextval('web_hook_logs_id_seq'::regclass);

ALTER TABLE ONLY web_hooks ALTER COLUMN id SET DEFAULT nextval('web_hooks_id_seq'::regclass);

ALTER TABLE ONLY webauthn_registrations ALTER COLUMN id SET DEFAULT nextval('webauthn_registrations_id_seq'::regclass);

ALTER TABLE ONLY wiki_page_meta ALTER COLUMN id SET DEFAULT nextval('wiki_page_meta_id_seq'::regclass);

ALTER TABLE ONLY wiki_page_slugs ALTER COLUMN id SET DEFAULT nextval('wiki_page_slugs_id_seq'::regclass);

ALTER TABLE ONLY x509_certificates ALTER COLUMN id SET DEFAULT nextval('x509_certificates_id_seq'::regclass);

ALTER TABLE ONLY x509_commit_signatures ALTER COLUMN id SET DEFAULT nextval('x509_commit_signatures_id_seq'::regclass);

ALTER TABLE ONLY x509_issuers ALTER COLUMN id SET DEFAULT nextval('x509_issuers_id_seq'::regclass);

ALTER TABLE ONLY zoom_meetings ALTER COLUMN id SET DEFAULT nextval('zoom_meetings_id_seq'::regclass);

ALTER TABLE ONLY product_analytics_events_experimental
    ADD CONSTRAINT product_analytics_events_experimental_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_00
    ADD CONSTRAINT product_analytics_events_experimental_00_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_01
    ADD CONSTRAINT product_analytics_events_experimental_01_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_02
    ADD CONSTRAINT product_analytics_events_experimental_02_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_03
    ADD CONSTRAINT product_analytics_events_experimental_03_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_04
    ADD CONSTRAINT product_analytics_events_experimental_04_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_05
    ADD CONSTRAINT product_analytics_events_experimental_05_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_06
    ADD CONSTRAINT product_analytics_events_experimental_06_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_07
    ADD CONSTRAINT product_analytics_events_experimental_07_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_08
    ADD CONSTRAINT product_analytics_events_experimental_08_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_09
    ADD CONSTRAINT product_analytics_events_experimental_09_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_10
    ADD CONSTRAINT product_analytics_events_experimental_10_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_11
    ADD CONSTRAINT product_analytics_events_experimental_11_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_12
    ADD CONSTRAINT product_analytics_events_experimental_12_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_13
    ADD CONSTRAINT product_analytics_events_experimental_13_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_14
    ADD CONSTRAINT product_analytics_events_experimental_14_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_15
    ADD CONSTRAINT product_analytics_events_experimental_15_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_16
    ADD CONSTRAINT product_analytics_events_experimental_16_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_17
    ADD CONSTRAINT product_analytics_events_experimental_17_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_18
    ADD CONSTRAINT product_analytics_events_experimental_18_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_19
    ADD CONSTRAINT product_analytics_events_experimental_19_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_20
    ADD CONSTRAINT product_analytics_events_experimental_20_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_21
    ADD CONSTRAINT product_analytics_events_experimental_21_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_22
    ADD CONSTRAINT product_analytics_events_experimental_22_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_23
    ADD CONSTRAINT product_analytics_events_experimental_23_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_24
    ADD CONSTRAINT product_analytics_events_experimental_24_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_25
    ADD CONSTRAINT product_analytics_events_experimental_25_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_26
    ADD CONSTRAINT product_analytics_events_experimental_26_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_27
    ADD CONSTRAINT product_analytics_events_experimental_27_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_28
    ADD CONSTRAINT product_analytics_events_experimental_28_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_29
    ADD CONSTRAINT product_analytics_events_experimental_29_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_30
    ADD CONSTRAINT product_analytics_events_experimental_30_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_31
    ADD CONSTRAINT product_analytics_events_experimental_31_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_32
    ADD CONSTRAINT product_analytics_events_experimental_32_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_33
    ADD CONSTRAINT product_analytics_events_experimental_33_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_34
    ADD CONSTRAINT product_analytics_events_experimental_34_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_35
    ADD CONSTRAINT product_analytics_events_experimental_35_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_36
    ADD CONSTRAINT product_analytics_events_experimental_36_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_37
    ADD CONSTRAINT product_analytics_events_experimental_37_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_38
    ADD CONSTRAINT product_analytics_events_experimental_38_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_39
    ADD CONSTRAINT product_analytics_events_experimental_39_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_40
    ADD CONSTRAINT product_analytics_events_experimental_40_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_41
    ADD CONSTRAINT product_analytics_events_experimental_41_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_42
    ADD CONSTRAINT product_analytics_events_experimental_42_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_43
    ADD CONSTRAINT product_analytics_events_experimental_43_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_44
    ADD CONSTRAINT product_analytics_events_experimental_44_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_45
    ADD CONSTRAINT product_analytics_events_experimental_45_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_46
    ADD CONSTRAINT product_analytics_events_experimental_46_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_47
    ADD CONSTRAINT product_analytics_events_experimental_47_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_48
    ADD CONSTRAINT product_analytics_events_experimental_48_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_49
    ADD CONSTRAINT product_analytics_events_experimental_49_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_50
    ADD CONSTRAINT product_analytics_events_experimental_50_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_51
    ADD CONSTRAINT product_analytics_events_experimental_51_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_52
    ADD CONSTRAINT product_analytics_events_experimental_52_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_53
    ADD CONSTRAINT product_analytics_events_experimental_53_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_54
    ADD CONSTRAINT product_analytics_events_experimental_54_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_55
    ADD CONSTRAINT product_analytics_events_experimental_55_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_56
    ADD CONSTRAINT product_analytics_events_experimental_56_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_57
    ADD CONSTRAINT product_analytics_events_experimental_57_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_58
    ADD CONSTRAINT product_analytics_events_experimental_58_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_59
    ADD CONSTRAINT product_analytics_events_experimental_59_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_60
    ADD CONSTRAINT product_analytics_events_experimental_60_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_61
    ADD CONSTRAINT product_analytics_events_experimental_61_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_62
    ADD CONSTRAINT product_analytics_events_experimental_62_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY gitlab_partitions_static.product_analytics_events_experimental_63
    ADD CONSTRAINT product_analytics_events_experimental_63_pkey PRIMARY KEY (id, project_id);

ALTER TABLE ONLY abuse_reports
    ADD CONSTRAINT abuse_reports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY alert_management_alert_assignees
    ADD CONSTRAINT alert_management_alert_assignees_pkey PRIMARY KEY (id);

ALTER TABLE ONLY alert_management_alert_user_mentions
    ADD CONSTRAINT alert_management_alert_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY alert_management_alerts
    ADD CONSTRAINT alert_management_alerts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY alert_management_http_integrations
    ADD CONSTRAINT alert_management_http_integrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY alerts_service_data
    ADD CONSTRAINT alerts_service_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY allowed_email_domains
    ADD CONSTRAINT allowed_email_domains_pkey PRIMARY KEY (id);

ALTER TABLE ONLY analytics_cycle_analytics_group_stages
    ADD CONSTRAINT analytics_cycle_analytics_group_stages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY analytics_cycle_analytics_group_value_streams
    ADD CONSTRAINT analytics_cycle_analytics_group_value_streams_pkey PRIMARY KEY (id);

ALTER TABLE ONLY analytics_cycle_analytics_project_stages
    ADD CONSTRAINT analytics_cycle_analytics_project_stages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY analytics_instance_statistics_measurements
    ADD CONSTRAINT analytics_instance_statistics_measurements_pkey PRIMARY KEY (id);

ALTER TABLE ONLY analytics_language_trend_repository_languages
    ADD CONSTRAINT analytics_language_trend_repository_languages_pkey PRIMARY KEY (programming_language_id, project_id, snapshot_date);

ALTER TABLE ONLY appearances
    ADD CONSTRAINT appearances_pkey PRIMARY KEY (id);

ALTER TABLE ONLY application_setting_terms
    ADD CONSTRAINT application_setting_terms_pkey PRIMARY KEY (id);

ALTER TABLE ONLY application_settings
    ADD CONSTRAINT application_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_merge_request_rule_sources
    ADD CONSTRAINT approval_merge_request_rule_sources_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_merge_request_rules_approved_approvers
    ADD CONSTRAINT approval_merge_request_rules_approved_approvers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_merge_request_rules_groups
    ADD CONSTRAINT approval_merge_request_rules_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_merge_request_rules
    ADD CONSTRAINT approval_merge_request_rules_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_merge_request_rules_users
    ADD CONSTRAINT approval_merge_request_rules_users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_project_rules_groups
    ADD CONSTRAINT approval_project_rules_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_project_rules
    ADD CONSTRAINT approval_project_rules_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approval_project_rules_protected_branches
    ADD CONSTRAINT approval_project_rules_protected_branches_pkey PRIMARY KEY (approval_project_rule_id, protected_branch_id);

ALTER TABLE ONLY approval_project_rules_users
    ADD CONSTRAINT approval_project_rules_users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approvals
    ADD CONSTRAINT approvals_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approver_groups
    ADD CONSTRAINT approver_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY approvers
    ADD CONSTRAINT approvers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);

ALTER TABLE ONLY atlassian_identities
    ADD CONSTRAINT atlassian_identities_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY audit_events_part_5fc467ac26
    ADD CONSTRAINT audit_events_part_5fc467ac26_pkey PRIMARY KEY (id, created_at);

ALTER TABLE ONLY audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY authentication_events
    ADD CONSTRAINT authentication_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY award_emoji
    ADD CONSTRAINT award_emoji_pkey PRIMARY KEY (id);

ALTER TABLE ONLY aws_roles
    ADD CONSTRAINT aws_roles_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY background_migration_jobs
    ADD CONSTRAINT background_migration_jobs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY backup_labels
    ADD CONSTRAINT backup_labels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY badges
    ADD CONSTRAINT badges_pkey PRIMARY KEY (id);

ALTER TABLE ONLY board_assignees
    ADD CONSTRAINT board_assignees_pkey PRIMARY KEY (id);

ALTER TABLE ONLY board_group_recent_visits
    ADD CONSTRAINT board_group_recent_visits_pkey PRIMARY KEY (id);

ALTER TABLE ONLY board_labels
    ADD CONSTRAINT board_labels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY board_project_recent_visits
    ADD CONSTRAINT board_project_recent_visits_pkey PRIMARY KEY (id);

ALTER TABLE ONLY board_user_preferences
    ADD CONSTRAINT board_user_preferences_pkey PRIMARY KEY (id);

ALTER TABLE ONLY boards_epic_user_preferences
    ADD CONSTRAINT boards_epic_user_preferences_pkey PRIMARY KEY (id);

ALTER TABLE ONLY boards
    ADD CONSTRAINT boards_pkey PRIMARY KEY (id);

ALTER TABLE ONLY broadcast_messages
    ADD CONSTRAINT broadcast_messages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY bulk_import_configurations
    ADD CONSTRAINT bulk_import_configurations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY bulk_import_entities
    ADD CONSTRAINT bulk_import_entities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY bulk_imports
    ADD CONSTRAINT bulk_imports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY chat_names
    ADD CONSTRAINT chat_names_pkey PRIMARY KEY (id);

ALTER TABLE ONLY chat_teams
    ADD CONSTRAINT chat_teams_pkey PRIMARY KEY (id);

ALTER TABLE vulnerability_scanners
    ADD CONSTRAINT check_37608c9db5 CHECK ((char_length(vendor) <= 255)) NOT VALID;

ALTER TABLE group_import_states
    ADD CONSTRAINT check_cda75c7c3f CHECK ((user_id IS NOT NULL)) NOT VALID;

ALTER TABLE ONLY ci_build_needs
    ADD CONSTRAINT ci_build_needs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_build_pending_states
    ADD CONSTRAINT ci_build_pending_states_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_build_report_results
    ADD CONSTRAINT ci_build_report_results_pkey PRIMARY KEY (build_id);

ALTER TABLE ONLY ci_build_trace_chunks
    ADD CONSTRAINT ci_build_trace_chunks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_build_trace_section_names
    ADD CONSTRAINT ci_build_trace_section_names_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_build_trace_sections
    ADD CONSTRAINT ci_build_trace_sections_pkey PRIMARY KEY (build_id, section_name_id);

ALTER TABLE ONLY ci_builds_metadata
    ADD CONSTRAINT ci_builds_metadata_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_builds
    ADD CONSTRAINT ci_builds_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_builds_runner_session
    ADD CONSTRAINT ci_builds_runner_session_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_daily_build_group_report_results
    ADD CONSTRAINT ci_daily_build_group_report_results_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_deleted_objects
    ADD CONSTRAINT ci_deleted_objects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_freeze_periods
    ADD CONSTRAINT ci_freeze_periods_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_group_variables
    ADD CONSTRAINT ci_group_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_instance_variables
    ADD CONSTRAINT ci_instance_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_job_artifacts
    ADD CONSTRAINT ci_job_artifacts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_job_variables
    ADD CONSTRAINT ci_job_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_pipeline_artifacts
    ADD CONSTRAINT ci_pipeline_artifacts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_pipeline_chat_data
    ADD CONSTRAINT ci_pipeline_chat_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_pipeline_messages
    ADD CONSTRAINT ci_pipeline_messages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_pipeline_schedule_variables
    ADD CONSTRAINT ci_pipeline_schedule_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_pipeline_schedules
    ADD CONSTRAINT ci_pipeline_schedules_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_pipeline_variables
    ADD CONSTRAINT ci_pipeline_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_pipelines_config
    ADD CONSTRAINT ci_pipelines_config_pkey PRIMARY KEY (pipeline_id);

ALTER TABLE ONLY ci_pipelines
    ADD CONSTRAINT ci_pipelines_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_platform_metrics
    ADD CONSTRAINT ci_platform_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_refs
    ADD CONSTRAINT ci_refs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_resource_groups
    ADD CONSTRAINT ci_resource_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_resources
    ADD CONSTRAINT ci_resources_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_runner_namespaces
    ADD CONSTRAINT ci_runner_namespaces_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_runner_projects
    ADD CONSTRAINT ci_runner_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_runners
    ADD CONSTRAINT ci_runners_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_sources_pipelines
    ADD CONSTRAINT ci_sources_pipelines_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_sources_projects
    ADD CONSTRAINT ci_sources_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_stages
    ADD CONSTRAINT ci_stages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_subscriptions_projects
    ADD CONSTRAINT ci_subscriptions_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_trigger_requests
    ADD CONSTRAINT ci_trigger_requests_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_triggers
    ADD CONSTRAINT ci_triggers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_variables
    ADD CONSTRAINT ci_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cluster_agent_tokens
    ADD CONSTRAINT cluster_agent_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cluster_agents
    ADD CONSTRAINT cluster_agents_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cluster_groups
    ADD CONSTRAINT cluster_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cluster_platforms_kubernetes
    ADD CONSTRAINT cluster_platforms_kubernetes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cluster_projects
    ADD CONSTRAINT cluster_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cluster_providers_aws
    ADD CONSTRAINT cluster_providers_aws_pkey PRIMARY KEY (id);

ALTER TABLE ONLY cluster_providers_gcp
    ADD CONSTRAINT cluster_providers_gcp_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_cert_managers
    ADD CONSTRAINT clusters_applications_cert_managers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_cilium
    ADD CONSTRAINT clusters_applications_cilium_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_crossplane
    ADD CONSTRAINT clusters_applications_crossplane_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_elastic_stacks
    ADD CONSTRAINT clusters_applications_elastic_stacks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_fluentd
    ADD CONSTRAINT clusters_applications_fluentd_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_helm
    ADD CONSTRAINT clusters_applications_helm_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_ingress
    ADD CONSTRAINT clusters_applications_ingress_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_jupyter
    ADD CONSTRAINT clusters_applications_jupyter_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_knative
    ADD CONSTRAINT clusters_applications_knative_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_prometheus
    ADD CONSTRAINT clusters_applications_prometheus_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_applications_runners
    ADD CONSTRAINT clusters_applications_runners_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters_kubernetes_namespaces
    ADD CONSTRAINT clusters_kubernetes_namespaces_pkey PRIMARY KEY (id);

ALTER TABLE ONLY clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);

ALTER TABLE ONLY commit_user_mentions
    ADD CONSTRAINT commit_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY compliance_management_frameworks
    ADD CONSTRAINT compliance_management_frameworks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY container_expiration_policies
    ADD CONSTRAINT container_expiration_policies_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY container_repositories
    ADD CONSTRAINT container_repositories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY conversational_development_index_metrics
    ADD CONSTRAINT conversational_development_index_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY csv_issue_imports
    ADD CONSTRAINT csv_issue_imports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY custom_emoji
    ADD CONSTRAINT custom_emoji_pkey PRIMARY KEY (id);

ALTER TABLE ONLY dast_scanner_profiles
    ADD CONSTRAINT dast_scanner_profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY dast_site_profiles
    ADD CONSTRAINT dast_site_profiles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY dast_site_tokens
    ADD CONSTRAINT dast_site_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY dast_site_validations
    ADD CONSTRAINT dast_site_validations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY dast_sites
    ADD CONSTRAINT dast_sites_pkey PRIMARY KEY (id);

ALTER TABLE ONLY dependency_proxy_blobs
    ADD CONSTRAINT dependency_proxy_blobs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY dependency_proxy_group_settings
    ADD CONSTRAINT dependency_proxy_group_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY deploy_keys_projects
    ADD CONSTRAINT deploy_keys_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY deploy_tokens
    ADD CONSTRAINT deploy_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY deployment_clusters
    ADD CONSTRAINT deployment_clusters_pkey PRIMARY KEY (deployment_id);

ALTER TABLE ONLY deployment_merge_requests
    ADD CONSTRAINT deployment_merge_requests_pkey PRIMARY KEY (deployment_id, merge_request_id);

ALTER TABLE ONLY deployments
    ADD CONSTRAINT deployments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY description_versions
    ADD CONSTRAINT description_versions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY design_management_designs
    ADD CONSTRAINT design_management_designs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY design_management_designs_versions
    ADD CONSTRAINT design_management_designs_versions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY design_management_versions
    ADD CONSTRAINT design_management_versions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY design_user_mentions
    ADD CONSTRAINT design_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY diff_note_positions
    ADD CONSTRAINT diff_note_positions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY draft_notes
    ADD CONSTRAINT draft_notes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY elastic_reindexing_tasks
    ADD CONSTRAINT elastic_reindexing_tasks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);

ALTER TABLE ONLY environments
    ADD CONSTRAINT environments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY epic_issues
    ADD CONSTRAINT epic_issues_pkey PRIMARY KEY (id);

ALTER TABLE ONLY epic_metrics
    ADD CONSTRAINT epic_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY epic_user_mentions
    ADD CONSTRAINT epic_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY epics
    ADD CONSTRAINT epics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY evidences
    ADD CONSTRAINT evidences_pkey PRIMARY KEY (id);

ALTER TABLE ONLY experiment_users
    ADD CONSTRAINT experiment_users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY experiments
    ADD CONSTRAINT experiments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY external_pull_requests
    ADD CONSTRAINT external_pull_requests_pkey PRIMARY KEY (id);

ALTER TABLE ONLY feature_gates
    ADD CONSTRAINT feature_gates_pkey PRIMARY KEY (id);

ALTER TABLE ONLY features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);

ALTER TABLE ONLY fork_network_members
    ADD CONSTRAINT fork_network_members_pkey PRIMARY KEY (id);

ALTER TABLE ONLY fork_networks
    ADD CONSTRAINT fork_networks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_cache_invalidation_events
    ADD CONSTRAINT geo_cache_invalidation_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_container_repository_updated_events
    ADD CONSTRAINT geo_container_repository_updated_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT geo_event_log_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_events
    ADD CONSTRAINT geo_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_hashed_storage_attachments_events
    ADD CONSTRAINT geo_hashed_storage_attachments_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_hashed_storage_migrated_events
    ADD CONSTRAINT geo_hashed_storage_migrated_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_job_artifact_deleted_events
    ADD CONSTRAINT geo_job_artifact_deleted_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_lfs_object_deleted_events
    ADD CONSTRAINT geo_lfs_object_deleted_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_node_namespace_links
    ADD CONSTRAINT geo_node_namespace_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_node_statuses
    ADD CONSTRAINT geo_node_statuses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_nodes
    ADD CONSTRAINT geo_nodes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_repositories_changed_events
    ADD CONSTRAINT geo_repositories_changed_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_repository_created_events
    ADD CONSTRAINT geo_repository_created_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_repository_deleted_events
    ADD CONSTRAINT geo_repository_deleted_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_repository_renamed_events
    ADD CONSTRAINT geo_repository_renamed_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_repository_updated_events
    ADD CONSTRAINT geo_repository_updated_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_reset_checksum_events
    ADD CONSTRAINT geo_reset_checksum_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY geo_upload_deleted_events
    ADD CONSTRAINT geo_upload_deleted_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY gitlab_subscription_histories
    ADD CONSTRAINT gitlab_subscription_histories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY gitlab_subscriptions
    ADD CONSTRAINT gitlab_subscriptions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY gpg_key_subkeys
    ADD CONSTRAINT gpg_key_subkeys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY gpg_keys
    ADD CONSTRAINT gpg_keys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY gpg_signatures
    ADD CONSTRAINT gpg_signatures_pkey PRIMARY KEY (id);

ALTER TABLE ONLY grafana_integrations
    ADD CONSTRAINT grafana_integrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY group_custom_attributes
    ADD CONSTRAINT group_custom_attributes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY group_deletion_schedules
    ADD CONSTRAINT group_deletion_schedules_pkey PRIMARY KEY (group_id);

ALTER TABLE ONLY group_deploy_keys_groups
    ADD CONSTRAINT group_deploy_keys_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY group_deploy_keys
    ADD CONSTRAINT group_deploy_keys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY group_deploy_tokens
    ADD CONSTRAINT group_deploy_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY group_group_links
    ADD CONSTRAINT group_group_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY group_import_states
    ADD CONSTRAINT group_import_states_pkey PRIMARY KEY (group_id);

ALTER TABLE ONLY group_wiki_repositories
    ADD CONSTRAINT group_wiki_repositories_pkey PRIMARY KEY (group_id);

ALTER TABLE ONLY historical_data
    ADD CONSTRAINT historical_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY import_export_uploads
    ADD CONSTRAINT import_export_uploads_pkey PRIMARY KEY (id);

ALTER TABLE ONLY import_failures
    ADD CONSTRAINT import_failures_pkey PRIMARY KEY (id);

ALTER TABLE ONLY index_statuses
    ADD CONSTRAINT index_statuses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY insights
    ADD CONSTRAINT insights_pkey PRIMARY KEY (id);

ALTER TABLE ONLY internal_ids
    ADD CONSTRAINT internal_ids_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ip_restrictions
    ADD CONSTRAINT ip_restrictions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issuable_severities
    ADD CONSTRAINT issuable_severities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issuable_slas
    ADD CONSTRAINT issuable_slas_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issue_assignees
    ADD CONSTRAINT issue_assignees_pkey PRIMARY KEY (issue_id, user_id);

ALTER TABLE ONLY issue_email_participants
    ADD CONSTRAINT issue_email_participants_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issue_links
    ADD CONSTRAINT issue_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issue_metrics
    ADD CONSTRAINT issue_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issue_tracker_data
    ADD CONSTRAINT issue_tracker_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issue_user_mentions
    ADD CONSTRAINT issue_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);

ALTER TABLE ONLY issues_prometheus_alert_events
    ADD CONSTRAINT issues_prometheus_alert_events_pkey PRIMARY KEY (issue_id, prometheus_alert_event_id);

ALTER TABLE ONLY issues_self_managed_prometheus_alert_events
    ADD CONSTRAINT issues_self_managed_prometheus_alert_events_pkey PRIMARY KEY (issue_id, self_managed_prometheus_alert_event_id);

ALTER TABLE ONLY sprints
    ADD CONSTRAINT iteration_start_and_due_daterange_group_id_constraint EXCLUDE USING gist (group_id WITH =, daterange(start_date, due_date, '[]'::text) WITH &&) WHERE ((group_id IS NOT NULL));

ALTER TABLE ONLY sprints
    ADD CONSTRAINT iteration_start_and_due_daterange_project_id_constraint EXCLUDE USING gist (project_id WITH =, daterange(start_date, due_date, '[]'::text) WITH &&) WHERE ((project_id IS NOT NULL));

ALTER TABLE ONLY jira_connect_installations
    ADD CONSTRAINT jira_connect_installations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY jira_connect_subscriptions
    ADD CONSTRAINT jira_connect_subscriptions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY jira_imports
    ADD CONSTRAINT jira_imports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY jira_tracker_data
    ADD CONSTRAINT jira_tracker_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY keys
    ADD CONSTRAINT keys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY label_links
    ADD CONSTRAINT label_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY label_priorities
    ADD CONSTRAINT label_priorities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY labels
    ADD CONSTRAINT labels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ldap_group_links
    ADD CONSTRAINT ldap_group_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY lfs_file_locks
    ADD CONSTRAINT lfs_file_locks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY lfs_objects
    ADD CONSTRAINT lfs_objects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY lfs_objects_projects
    ADD CONSTRAINT lfs_objects_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY licenses
    ADD CONSTRAINT licenses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY list_user_preferences
    ADD CONSTRAINT list_user_preferences_pkey PRIMARY KEY (id);

ALTER TABLE ONLY lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);

ALTER TABLE ONLY members
    ADD CONSTRAINT members_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_request_assignees
    ADD CONSTRAINT merge_request_assignees_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_request_blocks
    ADD CONSTRAINT merge_request_blocks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_request_context_commits
    ADD CONSTRAINT merge_request_context_commits_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_request_diff_commits
    ADD CONSTRAINT merge_request_diff_commits_pkey PRIMARY KEY (merge_request_diff_id, relative_order);

ALTER TABLE ONLY merge_request_diff_details
    ADD CONSTRAINT merge_request_diff_details_pkey PRIMARY KEY (merge_request_diff_id);

ALTER TABLE ONLY merge_request_diff_files
    ADD CONSTRAINT merge_request_diff_files_pkey PRIMARY KEY (merge_request_diff_id, relative_order);

ALTER TABLE ONLY merge_request_diffs
    ADD CONSTRAINT merge_request_diffs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_request_metrics
    ADD CONSTRAINT merge_request_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_request_reviewers
    ADD CONSTRAINT merge_request_reviewers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_request_user_mentions
    ADD CONSTRAINT merge_request_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_requests_closing_issues
    ADD CONSTRAINT merge_requests_closing_issues_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT merge_requests_pkey PRIMARY KEY (id);

ALTER TABLE ONLY merge_trains
    ADD CONSTRAINT merge_trains_pkey PRIMARY KEY (id);

ALTER TABLE ONLY metrics_dashboard_annotations
    ADD CONSTRAINT metrics_dashboard_annotations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY metrics_users_starred_dashboards
    ADD CONSTRAINT metrics_users_starred_dashboards_pkey PRIMARY KEY (id);

ALTER TABLE ONLY milestone_releases
    ADD CONSTRAINT milestone_releases_pkey PRIMARY KEY (milestone_id, release_id);

ALTER TABLE ONLY milestones
    ADD CONSTRAINT milestones_pkey PRIMARY KEY (id);

ALTER TABLE ONLY namespace_aggregation_schedules
    ADD CONSTRAINT namespace_aggregation_schedules_pkey PRIMARY KEY (namespace_id);

ALTER TABLE ONLY namespace_limits
    ADD CONSTRAINT namespace_limits_pkey PRIMARY KEY (namespace_id);

ALTER TABLE ONLY namespace_root_storage_statistics
    ADD CONSTRAINT namespace_root_storage_statistics_pkey PRIMARY KEY (namespace_id);

ALTER TABLE ONLY namespace_settings
    ADD CONSTRAINT namespace_settings_pkey PRIMARY KEY (namespace_id);

ALTER TABLE ONLY namespace_statistics
    ADD CONSTRAINT namespace_statistics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY namespaces
    ADD CONSTRAINT namespaces_pkey PRIMARY KEY (id);

ALTER TABLE ONLY note_diff_files
    ADD CONSTRAINT note_diff_files_pkey PRIMARY KEY (id);

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY oauth_openid_requests
    ADD CONSTRAINT oauth_openid_requests_pkey PRIMARY KEY (id);

ALTER TABLE ONLY open_project_tracker_data
    ADD CONSTRAINT open_project_tracker_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_feature_flag_scopes
    ADD CONSTRAINT operations_feature_flag_scopes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_feature_flags_clients
    ADD CONSTRAINT operations_feature_flags_clients_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_feature_flags_issues
    ADD CONSTRAINT operations_feature_flags_issues_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_feature_flags
    ADD CONSTRAINT operations_feature_flags_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_scopes
    ADD CONSTRAINT operations_scopes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_strategies
    ADD CONSTRAINT operations_strategies_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_strategies_user_lists
    ADD CONSTRAINT operations_strategies_user_lists_pkey PRIMARY KEY (id);

ALTER TABLE ONLY operations_user_lists
    ADD CONSTRAINT operations_user_lists_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_build_infos
    ADD CONSTRAINT packages_build_infos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_composer_metadata
    ADD CONSTRAINT packages_composer_metadata_pkey PRIMARY KEY (package_id);

ALTER TABLE ONLY packages_conan_file_metadata
    ADD CONSTRAINT packages_conan_file_metadata_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_conan_metadata
    ADD CONSTRAINT packages_conan_metadata_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_dependencies
    ADD CONSTRAINT packages_dependencies_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_dependency_links
    ADD CONSTRAINT packages_dependency_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_events
    ADD CONSTRAINT packages_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_maven_metadata
    ADD CONSTRAINT packages_maven_metadata_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_nuget_dependency_link_metadata
    ADD CONSTRAINT packages_nuget_dependency_link_metadata_pkey PRIMARY KEY (dependency_link_id);

ALTER TABLE ONLY packages_nuget_metadata
    ADD CONSTRAINT packages_nuget_metadata_pkey PRIMARY KEY (package_id);

ALTER TABLE ONLY packages_package_files
    ADD CONSTRAINT packages_package_files_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_packages
    ADD CONSTRAINT packages_packages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY packages_pypi_metadata
    ADD CONSTRAINT packages_pypi_metadata_pkey PRIMARY KEY (package_id);

ALTER TABLE ONLY packages_tags
    ADD CONSTRAINT packages_tags_pkey PRIMARY KEY (id);

ALTER TABLE ONLY pages_deployments
    ADD CONSTRAINT pages_deployments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY pages_domain_acme_orders
    ADD CONSTRAINT pages_domain_acme_orders_pkey PRIMARY KEY (id);

ALTER TABLE ONLY pages_domains
    ADD CONSTRAINT pages_domains_pkey PRIMARY KEY (id);

ALTER TABLE ONLY partitioned_foreign_keys
    ADD CONSTRAINT partitioned_foreign_keys_pkey PRIMARY KEY (id);

ALTER TABLE ONLY path_locks
    ADD CONSTRAINT path_locks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY plan_limits
    ADD CONSTRAINT plan_limits_pkey PRIMARY KEY (id);

ALTER TABLE ONLY plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);

ALTER TABLE ONLY pool_repositories
    ADD CONSTRAINT pool_repositories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY postgres_reindex_actions
    ADD CONSTRAINT postgres_reindex_actions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY programming_languages
    ADD CONSTRAINT programming_languages_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_access_tokens
    ADD CONSTRAINT project_access_tokens_pkey PRIMARY KEY (personal_access_token_id, project_id);

ALTER TABLE ONLY project_alerting_settings
    ADD CONSTRAINT project_alerting_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_aliases
    ADD CONSTRAINT project_aliases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_authorizations
    ADD CONSTRAINT project_authorizations_pkey PRIMARY KEY (user_id, project_id, access_level);

ALTER TABLE ONLY project_auto_devops
    ADD CONSTRAINT project_auto_devops_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_ci_cd_settings
    ADD CONSTRAINT project_ci_cd_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_compliance_framework_settings
    ADD CONSTRAINT project_compliance_framework_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_custom_attributes
    ADD CONSTRAINT project_custom_attributes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_daily_statistics
    ADD CONSTRAINT project_daily_statistics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_deploy_tokens
    ADD CONSTRAINT project_deploy_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_error_tracking_settings
    ADD CONSTRAINT project_error_tracking_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_export_jobs
    ADD CONSTRAINT project_export_jobs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_feature_usages
    ADD CONSTRAINT project_feature_usages_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_features
    ADD CONSTRAINT project_features_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_group_links
    ADD CONSTRAINT project_group_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_import_data
    ADD CONSTRAINT project_import_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_incident_management_settings
    ADD CONSTRAINT project_incident_management_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_metrics_settings
    ADD CONSTRAINT project_metrics_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_mirror_data
    ADD CONSTRAINT project_mirror_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_pages_metadata
    ADD CONSTRAINT project_pages_metadata_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_repositories
    ADD CONSTRAINT project_repositories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_repository_states
    ADD CONSTRAINT project_repository_states_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_repository_storage_moves
    ADD CONSTRAINT project_repository_storage_moves_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_security_settings
    ADD CONSTRAINT project_security_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_settings
    ADD CONSTRAINT project_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY project_statistics
    ADD CONSTRAINT project_statistics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY project_tracing_settings
    ADD CONSTRAINT project_tracing_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY prometheus_alert_events
    ADD CONSTRAINT prometheus_alert_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY prometheus_alerts
    ADD CONSTRAINT prometheus_alerts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY prometheus_metrics
    ADD CONSTRAINT prometheus_metrics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_branch_merge_access_levels
    ADD CONSTRAINT protected_branch_merge_access_levels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_branch_push_access_levels
    ADD CONSTRAINT protected_branch_push_access_levels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_branch_unprotect_access_levels
    ADD CONSTRAINT protected_branch_unprotect_access_levels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_branches
    ADD CONSTRAINT protected_branches_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_environment_deploy_access_levels
    ADD CONSTRAINT protected_environment_deploy_access_levels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_environments
    ADD CONSTRAINT protected_environments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_tag_create_access_levels
    ADD CONSTRAINT protected_tag_create_access_levels_pkey PRIMARY KEY (id);

ALTER TABLE ONLY protected_tags
    ADD CONSTRAINT protected_tags_pkey PRIMARY KEY (id);

ALTER TABLE ONLY push_event_payloads
    ADD CONSTRAINT push_event_payloads_pkey PRIMARY KEY (event_id);

ALTER TABLE ONLY push_rules
    ADD CONSTRAINT push_rules_pkey PRIMARY KEY (id);

ALTER TABLE ONLY raw_usage_data
    ADD CONSTRAINT raw_usage_data_pkey PRIMARY KEY (id);

ALTER TABLE ONLY redirect_routes
    ADD CONSTRAINT redirect_routes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY release_links
    ADD CONSTRAINT release_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY remote_mirrors
    ADD CONSTRAINT remote_mirrors_pkey PRIMARY KEY (id);

ALTER TABLE ONLY repository_languages
    ADD CONSTRAINT repository_languages_pkey PRIMARY KEY (project_id, programming_language_id);

ALTER TABLE ONLY required_code_owners_sections
    ADD CONSTRAINT required_code_owners_sections_pkey PRIMARY KEY (id);

ALTER TABLE ONLY requirements_management_test_reports
    ADD CONSTRAINT requirements_management_test_reports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY requirements
    ADD CONSTRAINT requirements_pkey PRIMARY KEY (id);

ALTER TABLE ONLY resource_iteration_events
    ADD CONSTRAINT resource_iteration_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY resource_label_events
    ADD CONSTRAINT resource_label_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY resource_milestone_events
    ADD CONSTRAINT resource_milestone_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY resource_state_events
    ADD CONSTRAINT resource_state_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY resource_weight_events
    ADD CONSTRAINT resource_weight_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);

ALTER TABLE ONLY routes
    ADD CONSTRAINT routes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY saml_group_links
    ADD CONSTRAINT saml_group_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

ALTER TABLE ONLY scim_identities
    ADD CONSTRAINT scim_identities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY scim_oauth_access_tokens
    ADD CONSTRAINT scim_oauth_access_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY security_findings
    ADD CONSTRAINT security_findings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY security_scans
    ADD CONSTRAINT security_scans_pkey PRIMARY KEY (id);

ALTER TABLE ONLY self_managed_prometheus_alert_events
    ADD CONSTRAINT self_managed_prometheus_alert_events_pkey PRIMARY KEY (id);

ALTER TABLE ONLY sent_notifications
    ADD CONSTRAINT sent_notifications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY sentry_issues
    ADD CONSTRAINT sentry_issues_pkey PRIMARY KEY (id);

ALTER TABLE ONLY serverless_domain_cluster
    ADD CONSTRAINT serverless_domain_cluster_pkey PRIMARY KEY (uuid);

ALTER TABLE ONLY service_desk_settings
    ADD CONSTRAINT service_desk_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);

ALTER TABLE ONLY shards
    ADD CONSTRAINT shards_pkey PRIMARY KEY (id);

ALTER TABLE ONLY slack_integrations
    ADD CONSTRAINT slack_integrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY smartcard_identities
    ADD CONSTRAINT smartcard_identities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY snippet_repositories
    ADD CONSTRAINT snippet_repositories_pkey PRIMARY KEY (snippet_id);

ALTER TABLE ONLY snippet_statistics
    ADD CONSTRAINT snippet_statistics_pkey PRIMARY KEY (snippet_id);

ALTER TABLE ONLY snippet_user_mentions
    ADD CONSTRAINT snippet_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY snippets
    ADD CONSTRAINT snippets_pkey PRIMARY KEY (id);

ALTER TABLE ONLY software_license_policies
    ADD CONSTRAINT software_license_policies_pkey PRIMARY KEY (id);

ALTER TABLE ONLY software_licenses
    ADD CONSTRAINT software_licenses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY spam_logs
    ADD CONSTRAINT spam_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY sprints
    ADD CONSTRAINT sprints_pkey PRIMARY KEY (id);

ALTER TABLE ONLY status_page_published_incidents
    ADD CONSTRAINT status_page_published_incidents_pkey PRIMARY KEY (id);

ALTER TABLE ONLY status_page_settings
    ADD CONSTRAINT status_page_settings_pkey PRIMARY KEY (project_id);

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY suggestions
    ADD CONSTRAINT suggestions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY system_note_metadata
    ADD CONSTRAINT system_note_metadata_pkey PRIMARY KEY (id);

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);

ALTER TABLE ONLY term_agreements
    ADD CONSTRAINT term_agreements_pkey PRIMARY KEY (id);

ALTER TABLE ONLY terraform_state_versions
    ADD CONSTRAINT terraform_state_versions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY terraform_states
    ADD CONSTRAINT terraform_states_pkey PRIMARY KEY (id);

ALTER TABLE ONLY timelogs
    ADD CONSTRAINT timelogs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY todos
    ADD CONSTRAINT todos_pkey PRIMARY KEY (id);

ALTER TABLE ONLY trending_projects
    ADD CONSTRAINT trending_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY u2f_registrations
    ADD CONSTRAINT u2f_registrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);

ALTER TABLE ONLY user_agent_details
    ADD CONSTRAINT user_agent_details_pkey PRIMARY KEY (id);

ALTER TABLE ONLY user_callouts
    ADD CONSTRAINT user_callouts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY user_canonical_emails
    ADD CONSTRAINT user_canonical_emails_pkey PRIMARY KEY (id);

ALTER TABLE ONLY user_custom_attributes
    ADD CONSTRAINT user_custom_attributes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY user_details
    ADD CONSTRAINT user_details_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY user_highest_roles
    ADD CONSTRAINT user_highest_roles_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY user_interacted_projects
    ADD CONSTRAINT user_interacted_projects_pkey PRIMARY KEY (project_id, user_id);

ALTER TABLE ONLY user_preferences
    ADD CONSTRAINT user_preferences_pkey PRIMARY KEY (id);

ALTER TABLE ONLY user_statuses
    ADD CONSTRAINT user_statuses_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY user_synced_attributes_metadata
    ADD CONSTRAINT user_synced_attributes_metadata_pkey PRIMARY KEY (id);

ALTER TABLE ONLY users_ops_dashboard_projects
    ADD CONSTRAINT users_ops_dashboard_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

ALTER TABLE ONLY users_security_dashboard_projects
    ADD CONSTRAINT users_security_dashboard_projects_pkey PRIMARY KEY (project_id, user_id);

ALTER TABLE ONLY users_star_projects
    ADD CONSTRAINT users_star_projects_pkey PRIMARY KEY (id);

ALTER TABLE ONLY users_statistics
    ADD CONSTRAINT users_statistics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT vulnerabilities_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_exports
    ADD CONSTRAINT vulnerability_exports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_feedback
    ADD CONSTRAINT vulnerability_feedback_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_historical_statistics
    ADD CONSTRAINT vulnerability_historical_statistics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_identifiers
    ADD CONSTRAINT vulnerability_identifiers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_issue_links
    ADD CONSTRAINT vulnerability_issue_links_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_occurrence_identifiers
    ADD CONSTRAINT vulnerability_occurrence_identifiers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_occurrence_pipelines
    ADD CONSTRAINT vulnerability_occurrence_pipelines_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_occurrences
    ADD CONSTRAINT vulnerability_occurrences_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_scanners
    ADD CONSTRAINT vulnerability_scanners_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_statistics
    ADD CONSTRAINT vulnerability_statistics_pkey PRIMARY KEY (id);

ALTER TABLE ONLY vulnerability_user_mentions
    ADD CONSTRAINT vulnerability_user_mentions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY web_hook_logs
    ADD CONSTRAINT web_hook_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY web_hooks
    ADD CONSTRAINT web_hooks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY webauthn_registrations
    ADD CONSTRAINT webauthn_registrations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY wiki_page_meta
    ADD CONSTRAINT wiki_page_meta_pkey PRIMARY KEY (id);

ALTER TABLE ONLY wiki_page_slugs
    ADD CONSTRAINT wiki_page_slugs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY x509_certificates
    ADD CONSTRAINT x509_certificates_pkey PRIMARY KEY (id);

ALTER TABLE ONLY x509_commit_signatures
    ADD CONSTRAINT x509_commit_signatures_pkey PRIMARY KEY (id);

ALTER TABLE ONLY x509_issuers
    ADD CONSTRAINT x509_issuers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY zoom_meetings
    ADD CONSTRAINT zoom_meetings_pkey PRIMARY KEY (id);

CREATE INDEX index_product_analytics_events_experimental_project_and_time ON ONLY product_analytics_events_experimental USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx10 ON gitlab_partitions_static.product_analytics_events_experimental_10 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx11 ON gitlab_partitions_static.product_analytics_events_experimental_11 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx12 ON gitlab_partitions_static.product_analytics_events_experimental_12 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx13 ON gitlab_partitions_static.product_analytics_events_experimental_13 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx14 ON gitlab_partitions_static.product_analytics_events_experimental_14 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx15 ON gitlab_partitions_static.product_analytics_events_experimental_15 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx16 ON gitlab_partitions_static.product_analytics_events_experimental_16 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx17 ON gitlab_partitions_static.product_analytics_events_experimental_17 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx18 ON gitlab_partitions_static.product_analytics_events_experimental_18 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx19 ON gitlab_partitions_static.product_analytics_events_experimental_19 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx20 ON gitlab_partitions_static.product_analytics_events_experimental_20 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx21 ON gitlab_partitions_static.product_analytics_events_experimental_21 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx22 ON gitlab_partitions_static.product_analytics_events_experimental_22 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx23 ON gitlab_partitions_static.product_analytics_events_experimental_23 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx24 ON gitlab_partitions_static.product_analytics_events_experimental_24 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx25 ON gitlab_partitions_static.product_analytics_events_experimental_25 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx26 ON gitlab_partitions_static.product_analytics_events_experimental_26 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx27 ON gitlab_partitions_static.product_analytics_events_experimental_27 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx28 ON gitlab_partitions_static.product_analytics_events_experimental_28 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx29 ON gitlab_partitions_static.product_analytics_events_experimental_29 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx30 ON gitlab_partitions_static.product_analytics_events_experimental_30 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx31 ON gitlab_partitions_static.product_analytics_events_experimental_31 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx32 ON gitlab_partitions_static.product_analytics_events_experimental_32 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx33 ON gitlab_partitions_static.product_analytics_events_experimental_33 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx34 ON gitlab_partitions_static.product_analytics_events_experimental_34 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx35 ON gitlab_partitions_static.product_analytics_events_experimental_35 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx36 ON gitlab_partitions_static.product_analytics_events_experimental_36 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx37 ON gitlab_partitions_static.product_analytics_events_experimental_37 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx38 ON gitlab_partitions_static.product_analytics_events_experimental_38 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx39 ON gitlab_partitions_static.product_analytics_events_experimental_39 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx40 ON gitlab_partitions_static.product_analytics_events_experimental_40 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx41 ON gitlab_partitions_static.product_analytics_events_experimental_41 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx42 ON gitlab_partitions_static.product_analytics_events_experimental_42 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx43 ON gitlab_partitions_static.product_analytics_events_experimental_43 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx44 ON gitlab_partitions_static.product_analytics_events_experimental_44 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx45 ON gitlab_partitions_static.product_analytics_events_experimental_45 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx46 ON gitlab_partitions_static.product_analytics_events_experimental_46 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx47 ON gitlab_partitions_static.product_analytics_events_experimental_47 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx48 ON gitlab_partitions_static.product_analytics_events_experimental_48 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx49 ON gitlab_partitions_static.product_analytics_events_experimental_49 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx50 ON gitlab_partitions_static.product_analytics_events_experimental_50 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx51 ON gitlab_partitions_static.product_analytics_events_experimental_51 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx52 ON gitlab_partitions_static.product_analytics_events_experimental_52 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx53 ON gitlab_partitions_static.product_analytics_events_experimental_53 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx54 ON gitlab_partitions_static.product_analytics_events_experimental_54 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx55 ON gitlab_partitions_static.product_analytics_events_experimental_55 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx56 ON gitlab_partitions_static.product_analytics_events_experimental_56 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx57 ON gitlab_partitions_static.product_analytics_events_experimental_57 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx58 ON gitlab_partitions_static.product_analytics_events_experimental_58 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx59 ON gitlab_partitions_static.product_analytics_events_experimental_59 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx60 ON gitlab_partitions_static.product_analytics_events_experimental_60 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx61 ON gitlab_partitions_static.product_analytics_events_experimental_61 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx62 ON gitlab_partitions_static.product_analytics_events_experimental_62 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_expe_project_id_collector_tstamp_idx63 ON gitlab_partitions_static.product_analytics_events_experimental_63 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx1 ON gitlab_partitions_static.product_analytics_events_experimental_01 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx2 ON gitlab_partitions_static.product_analytics_events_experimental_02 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx3 ON gitlab_partitions_static.product_analytics_events_experimental_03 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx4 ON gitlab_partitions_static.product_analytics_events_experimental_04 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx5 ON gitlab_partitions_static.product_analytics_events_experimental_05 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx6 ON gitlab_partitions_static.product_analytics_events_experimental_06 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx7 ON gitlab_partitions_static.product_analytics_events_experimental_07 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx8 ON gitlab_partitions_static.product_analytics_events_experimental_08 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_exper_project_id_collector_tstamp_idx9 ON gitlab_partitions_static.product_analytics_events_experimental_09 USING btree (project_id, collector_tstamp);

CREATE INDEX product_analytics_events_experi_project_id_collector_tstamp_idx ON gitlab_partitions_static.product_analytics_events_experimental_00 USING btree (project_id, collector_tstamp);

CREATE INDEX analytics_index_audit_events_on_created_at_and_author_id ON audit_events USING btree (created_at, author_id);

CREATE INDEX analytics_index_events_on_created_at_and_author_id ON events USING btree (created_at, author_id);

CREATE INDEX analytics_repository_languages_on_project_id ON analytics_language_trend_repository_languages USING btree (project_id);

CREATE UNIQUE INDEX any_approver_merge_request_rule_type_unique_index ON approval_merge_request_rules USING btree (merge_request_id, rule_type) WHERE (rule_type = 4);

CREATE UNIQUE INDEX any_approver_project_rule_type_unique_index ON approval_project_rules USING btree (project_id) WHERE (rule_type = 3);

CREATE INDEX approval_mr_rule_index_merge_request_id ON approval_merge_request_rules USING btree (merge_request_id);

CREATE UNIQUE INDEX backup_labels_group_id_project_id_title_idx ON backup_labels USING btree (group_id, project_id, title);

CREATE INDEX backup_labels_group_id_title_idx ON backup_labels USING btree (group_id, title) WHERE (project_id = NULL::integer);

CREATE INDEX backup_labels_project_id_idx ON backup_labels USING btree (project_id);

CREATE UNIQUE INDEX backup_labels_project_id_title_idx ON backup_labels USING btree (project_id, title) WHERE (group_id = NULL::integer);

CREATE INDEX backup_labels_template_idx ON backup_labels USING btree (template) WHERE template;

CREATE INDEX backup_labels_title_idx ON backup_labels USING btree (title);

CREATE INDEX backup_labels_type_project_id_idx ON backup_labels USING btree (type, project_id);

CREATE INDEX ci_builds_gitlab_monitor_metrics ON ci_builds USING btree (status, created_at, project_id) WHERE ((type)::text = 'Ci::Build'::text);

CREATE INDEX code_owner_approval_required ON protected_branches USING btree (project_id, code_owner_approval_required) WHERE (code_owner_approval_required = true);

CREATE INDEX commit_id_and_note_id_index ON commit_user_mentions USING btree (commit_id, note_id);

CREATE UNIQUE INDEX design_management_designs_versions_uniqueness ON design_management_designs_versions USING btree (design_id, version_id);

CREATE INDEX design_user_mentions_on_design_id_and_note_id_index ON design_user_mentions USING btree (design_id, note_id);

CREATE UNIQUE INDEX epic_user_mentions_on_epic_id_and_note_id_index ON epic_user_mentions USING btree (epic_id, note_id);

CREATE UNIQUE INDEX epic_user_mentions_on_epic_id_index ON epic_user_mentions USING btree (epic_id) WHERE (note_id IS NULL);

CREATE INDEX idx_audit_events_on_entity_id_desc_author_id_created_at ON audit_events USING btree (entity_id, entity_type, id DESC, author_id, created_at);

CREATE INDEX idx_ci_pipelines_artifacts_locked ON ci_pipelines USING btree (ci_ref_id, id) WHERE (locked = 1);

CREATE INDEX idx_container_exp_policies_on_project_id_next_run_at_enabled ON container_expiration_policies USING btree (project_id, next_run_at, enabled);

CREATE INDEX idx_deployment_clusters_on_cluster_id_and_kubernetes_namespace ON deployment_clusters USING btree (cluster_id, kubernetes_namespace);

CREATE UNIQUE INDEX idx_environment_merge_requests_unique_index ON deployment_merge_requests USING btree (environment_id, merge_request_id);

CREATE INDEX idx_geo_con_rep_updated_events_on_container_repository_id ON geo_container_repository_updated_events USING btree (container_repository_id);

CREATE INDEX idx_issues_on_health_status_not_null ON issues USING btree (health_status) WHERE (health_status IS NOT NULL);

CREATE INDEX idx_issues_on_project_id_and_created_at_and_id_and_state_id ON issues USING btree (project_id, created_at, id, state_id);

CREATE INDEX idx_issues_on_project_id_and_due_date_and_id_and_state_id ON issues USING btree (project_id, due_date, id, state_id) WHERE (due_date IS NOT NULL);

CREATE INDEX idx_issues_on_project_id_and_rel_position_and_state_id_and_id ON issues USING btree (project_id, relative_position, state_id, id DESC);

CREATE INDEX idx_issues_on_project_id_and_updated_at_and_id_and_state_id ON issues USING btree (project_id, updated_at, id, state_id);

CREATE INDEX idx_issues_on_state_id ON issues USING btree (state_id);

CREATE INDEX idx_jira_connect_subscriptions_on_installation_id ON jira_connect_subscriptions USING btree (jira_connect_installation_id);

CREATE UNIQUE INDEX idx_jira_connect_subscriptions_on_installation_id_namespace_id ON jira_connect_subscriptions USING btree (jira_connect_installation_id, namespace_id);

CREATE INDEX idx_members_created_at_user_id_invite_token ON members USING btree (created_at) WHERE ((invite_token IS NOT NULL) AND (user_id IS NULL));

CREATE INDEX idx_merge_requests_on_id_and_merge_jid ON merge_requests USING btree (id, merge_jid) WHERE ((merge_jid IS NOT NULL) AND (state_id = 4));

CREATE INDEX idx_merge_requests_on_merged_state ON merge_requests USING btree (id) WHERE (state_id = 3);

CREATE INDEX idx_merge_requests_on_source_project_and_branch_state_opened ON merge_requests USING btree (source_project_id, source_branch) WHERE (state_id = 1);

CREATE INDEX idx_merge_requests_on_state_id_and_merge_status ON merge_requests USING btree (state_id, merge_status) WHERE ((state_id = 1) AND ((merge_status)::text = 'can_be_merged'::text));

CREATE INDEX idx_merge_requests_on_target_project_id_and_iid_opened ON merge_requests USING btree (target_project_id, iid) WHERE (state_id = 1);

CREATE INDEX idx_merge_requests_on_target_project_id_and_locked_state ON merge_requests USING btree (target_project_id) WHERE (state_id = 4);

CREATE UNIQUE INDEX idx_metrics_users_starred_dashboard_on_user_project_dashboard ON metrics_users_starred_dashboards USING btree (user_id, project_id, dashboard_path);

CREATE INDEX idx_mr_cc_diff_files_on_mr_cc_id_and_sha ON merge_request_context_commit_diff_files USING btree (merge_request_context_commit_id, sha);

CREATE UNIQUE INDEX idx_on_compliance_management_frameworks_namespace_id_name ON compliance_management_frameworks USING btree (namespace_id, name);

CREATE INDEX idx_packages_packages_on_project_id_name_version_package_type ON packages_packages USING btree (project_id, name, version, package_type);

CREATE UNIQUE INDEX idx_pkgs_dep_links_on_pkg_id_dependency_id_dependency_type ON packages_dependency_links USING btree (package_id, dependency_id, dependency_type);

CREATE INDEX idx_proj_feat_usg_on_jira_dvcs_cloud_last_sync_at_and_proj_id ON project_feature_usages USING btree (jira_dvcs_cloud_last_sync_at, project_id) WHERE (jira_dvcs_cloud_last_sync_at IS NOT NULL);

CREATE INDEX idx_proj_feat_usg_on_jira_dvcs_server_last_sync_at_and_proj_id ON project_feature_usages USING btree (jira_dvcs_server_last_sync_at, project_id) WHERE (jira_dvcs_server_last_sync_at IS NOT NULL);

CREATE UNIQUE INDEX idx_project_id_payload_key_self_managed_prometheus_alert_events ON self_managed_prometheus_alert_events USING btree (project_id, payload_key);

CREATE INDEX idx_project_repository_check_partial ON projects USING btree (repository_storage, created_at) WHERE (last_repository_check_at IS NULL);

CREATE INDEX idx_projects_id_created_at_disable_overriding_approvers_false ON projects USING btree (id, created_at) WHERE ((disable_overriding_approvers_per_merge_request = false) OR (disable_overriding_approvers_per_merge_request IS NULL));

CREATE INDEX idx_projects_id_created_at_disable_overriding_approvers_true ON projects USING btree (id, created_at) WHERE (disable_overriding_approvers_per_merge_request = true);

CREATE INDEX idx_projects_on_repository_storage_last_repository_updated_at ON projects USING btree (id, repository_storage, last_repository_updated_at);

CREATE INDEX idx_repository_states_on_last_repository_verification_ran_at ON project_repository_states USING btree (project_id, last_repository_verification_ran_at) WHERE ((repository_verification_checksum IS NOT NULL) AND (last_repository_verification_failure IS NULL));

CREATE INDEX idx_repository_states_on_last_wiki_verification_ran_at ON project_repository_states USING btree (project_id, last_wiki_verification_ran_at) WHERE ((wiki_verification_checksum IS NOT NULL) AND (last_wiki_verification_failure IS NULL));

CREATE INDEX idx_repository_states_on_repository_failure_partial ON project_repository_states USING btree (last_repository_verification_failure) WHERE (last_repository_verification_failure IS NOT NULL);

CREATE INDEX idx_repository_states_on_wiki_failure_partial ON project_repository_states USING btree (last_wiki_verification_failure) WHERE (last_wiki_verification_failure IS NOT NULL);

CREATE INDEX idx_repository_states_outdated_checksums ON project_repository_states USING btree (project_id) WHERE (((repository_verification_checksum IS NULL) AND (last_repository_verification_failure IS NULL)) OR ((wiki_verification_checksum IS NULL) AND (last_wiki_verification_failure IS NULL)));

CREATE UNIQUE INDEX idx_security_scans_on_build_and_scan_type ON security_scans USING btree (build_id, scan_type);

CREATE INDEX idx_security_scans_on_scan_type ON security_scans USING btree (scan_type);

CREATE UNIQUE INDEX idx_serverless_domain_cluster_on_clusters_applications_knative ON serverless_domain_cluster USING btree (clusters_applications_knative_id);

CREATE UNIQUE INDEX idx_vulnerability_issue_links_on_vulnerability_id_and_issue_id ON vulnerability_issue_links USING btree (vulnerability_id, issue_id);

CREATE UNIQUE INDEX idx_vulnerability_issue_links_on_vulnerability_id_and_link_type ON vulnerability_issue_links USING btree (vulnerability_id, link_type) WHERE (link_type = 2);

CREATE INDEX index_abuse_reports_on_user_id ON abuse_reports USING btree (user_id);

CREATE INDEX index_alert_assignees_on_alert_id ON alert_management_alert_assignees USING btree (alert_id);

CREATE UNIQUE INDEX index_alert_assignees_on_user_id_and_alert_id ON alert_management_alert_assignees USING btree (user_id, alert_id);

CREATE INDEX index_alert_management_alerts_on_environment_id ON alert_management_alerts USING btree (environment_id) WHERE (environment_id IS NOT NULL);

CREATE INDEX index_alert_management_alerts_on_issue_id ON alert_management_alerts USING btree (issue_id);

CREATE UNIQUE INDEX index_alert_management_alerts_on_project_id_and_iid ON alert_management_alerts USING btree (project_id, iid);

CREATE INDEX index_alert_management_alerts_on_prometheus_alert_id ON alert_management_alerts USING btree (prometheus_alert_id) WHERE (prometheus_alert_id IS NOT NULL);

CREATE INDEX index_alert_management_http_integrations_on_project_id ON alert_management_http_integrations USING btree (project_id);

CREATE UNIQUE INDEX index_alert_user_mentions_on_alert_id ON alert_management_alert_user_mentions USING btree (alert_management_alert_id) WHERE (note_id IS NULL);

CREATE UNIQUE INDEX index_alert_user_mentions_on_alert_id_and_note_id ON alert_management_alert_user_mentions USING btree (alert_management_alert_id, note_id);

CREATE UNIQUE INDEX index_alert_user_mentions_on_note_id ON alert_management_alert_user_mentions USING btree (note_id) WHERE (note_id IS NOT NULL);

CREATE INDEX index_alerts_service_data_on_service_id ON alerts_service_data USING btree (service_id);

CREATE INDEX index_allowed_email_domains_on_group_id ON allowed_email_domains USING btree (group_id);

CREATE INDEX index_analytics_ca_group_stages_on_end_event_label_id ON analytics_cycle_analytics_group_stages USING btree (end_event_label_id);

CREATE INDEX index_analytics_ca_group_stages_on_group_id ON analytics_cycle_analytics_group_stages USING btree (group_id);

CREATE INDEX index_analytics_ca_group_stages_on_relative_position ON analytics_cycle_analytics_group_stages USING btree (relative_position);

CREATE INDEX index_analytics_ca_group_stages_on_start_event_label_id ON analytics_cycle_analytics_group_stages USING btree (start_event_label_id);

CREATE INDEX index_analytics_ca_group_stages_on_value_stream_id ON analytics_cycle_analytics_group_stages USING btree (group_value_stream_id);

CREATE UNIQUE INDEX index_analytics_ca_group_value_streams_on_group_id_and_name ON analytics_cycle_analytics_group_value_streams USING btree (group_id, name);

CREATE INDEX index_analytics_ca_project_stages_on_end_event_label_id ON analytics_cycle_analytics_project_stages USING btree (end_event_label_id);

CREATE INDEX index_analytics_ca_project_stages_on_project_id ON analytics_cycle_analytics_project_stages USING btree (project_id);

CREATE UNIQUE INDEX index_analytics_ca_project_stages_on_project_id_and_name ON analytics_cycle_analytics_project_stages USING btree (project_id, name);

CREATE INDEX index_analytics_ca_project_stages_on_relative_position ON analytics_cycle_analytics_project_stages USING btree (relative_position);

CREATE INDEX index_analytics_ca_project_stages_on_start_event_label_id ON analytics_cycle_analytics_project_stages USING btree (start_event_label_id);

CREATE INDEX index_analytics_cycle_analytics_group_stages_custom_only ON analytics_cycle_analytics_group_stages USING btree (id) WHERE (custom = true);

CREATE INDEX index_application_settings_on_custom_project_templates_group_id ON application_settings USING btree (custom_project_templates_group_id);

CREATE INDEX index_application_settings_on_file_template_project_id ON application_settings USING btree (file_template_project_id);

CREATE INDEX index_application_settings_on_instance_administrators_group_id ON application_settings USING btree (instance_administrators_group_id);

CREATE UNIQUE INDEX index_application_settings_on_push_rule_id ON application_settings USING btree (push_rule_id);

CREATE INDEX index_application_settings_on_usage_stats_set_by_user_id ON application_settings USING btree (usage_stats_set_by_user_id);

CREATE INDEX index_applicationsettings_on_instance_administration_project_id ON application_settings USING btree (instance_administration_project_id);

CREATE UNIQUE INDEX index_approval_merge_request_rule_sources_1 ON approval_merge_request_rule_sources USING btree (approval_merge_request_rule_id);

CREATE INDEX index_approval_merge_request_rule_sources_2 ON approval_merge_request_rule_sources USING btree (approval_project_rule_id);

CREATE UNIQUE INDEX index_approval_merge_request_rules_approved_approvers_1 ON approval_merge_request_rules_approved_approvers USING btree (approval_merge_request_rule_id, user_id);

CREATE INDEX index_approval_merge_request_rules_approved_approvers_2 ON approval_merge_request_rules_approved_approvers USING btree (user_id);

CREATE UNIQUE INDEX index_approval_merge_request_rules_groups_1 ON approval_merge_request_rules_groups USING btree (approval_merge_request_rule_id, group_id);

CREATE INDEX index_approval_merge_request_rules_groups_2 ON approval_merge_request_rules_groups USING btree (group_id);

CREATE UNIQUE INDEX index_approval_merge_request_rules_users_1 ON approval_merge_request_rules_users USING btree (approval_merge_request_rule_id, user_id);

CREATE INDEX index_approval_merge_request_rules_users_2 ON approval_merge_request_rules_users USING btree (user_id);

CREATE UNIQUE INDEX index_approval_project_rules_groups_1 ON approval_project_rules_groups USING btree (approval_project_rule_id, group_id);

CREATE INDEX index_approval_project_rules_groups_2 ON approval_project_rules_groups USING btree (group_id);

CREATE INDEX index_approval_project_rules_on_id_with_regular_type ON approval_project_rules USING btree (id) WHERE (rule_type = 0);

CREATE INDEX index_approval_project_rules_on_project_id ON approval_project_rules USING btree (project_id);

CREATE INDEX index_approval_project_rules_on_rule_type ON approval_project_rules USING btree (rule_type);

CREATE INDEX index_approval_project_rules_protected_branches_pb_id ON approval_project_rules_protected_branches USING btree (protected_branch_id);

CREATE UNIQUE INDEX index_approval_project_rules_users_1 ON approval_project_rules_users USING btree (approval_project_rule_id, user_id);

CREATE INDEX index_approval_project_rules_users_2 ON approval_project_rules_users USING btree (user_id);

CREATE INDEX index_approval_project_rules_users_on_approval_project_rule_id ON approval_project_rules_users USING btree (approval_project_rule_id);

CREATE UNIQUE INDEX index_approval_rule_name_for_code_owners_rule_type ON approval_merge_request_rules USING btree (merge_request_id, name) WHERE ((rule_type = 2) AND (section IS NULL));

CREATE UNIQUE INDEX index_approval_rule_name_for_sectional_code_owners_rule_type ON approval_merge_request_rules USING btree (merge_request_id, name, section) WHERE (rule_type = 2);

CREATE INDEX index_approval_rules_code_owners_rule_type ON approval_merge_request_rules USING btree (merge_request_id) WHERE (rule_type = 2);

CREATE INDEX index_approvals_on_merge_request_id ON approvals USING btree (merge_request_id);

CREATE UNIQUE INDEX index_approvals_on_user_id_and_merge_request_id ON approvals USING btree (user_id, merge_request_id);

CREATE INDEX index_approver_groups_on_group_id ON approver_groups USING btree (group_id);

CREATE INDEX index_approver_groups_on_target_id_and_target_type ON approver_groups USING btree (target_id, target_type);

CREATE INDEX index_approvers_on_target_id_and_target_type ON approvers USING btree (target_id, target_type);

CREATE INDEX index_approvers_on_user_id ON approvers USING btree (user_id);

CREATE UNIQUE INDEX index_atlassian_identities_on_extern_uid ON atlassian_identities USING btree (extern_uid);

CREATE INDEX index_authentication_events_on_provider ON authentication_events USING btree (provider);

CREATE INDEX index_authentication_events_on_provider_user_id_created_at ON authentication_events USING btree (provider, user_id, created_at) WHERE (result = 1);

CREATE INDEX index_authentication_events_on_user_id ON authentication_events USING btree (user_id);

CREATE INDEX index_award_emoji_on_awardable_type_and_awardable_id ON award_emoji USING btree (awardable_type, awardable_id);

CREATE INDEX index_award_emoji_on_user_id_and_name ON award_emoji USING btree (user_id, name);

CREATE UNIQUE INDEX index_aws_roles_on_role_external_id ON aws_roles USING btree (role_external_id);

CREATE UNIQUE INDEX index_aws_roles_on_user_id ON aws_roles USING btree (user_id);

CREATE INDEX index_background_migration_jobs_for_partitioning_migrations ON background_migration_jobs USING btree (((arguments ->> 2))) WHERE (class_name = 'Gitlab::Database::PartitioningMigrationHelpers::BackfillPartitionedTable'::text);

CREATE INDEX index_background_migration_jobs_on_class_name_and_arguments ON background_migration_jobs USING btree (class_name, arguments);

CREATE INDEX index_background_migration_jobs_on_class_name_and_status_and_id ON background_migration_jobs USING btree (class_name, status, id);

CREATE INDEX index_badges_on_group_id ON badges USING btree (group_id);

CREATE INDEX index_badges_on_project_id ON badges USING btree (project_id);

CREATE INDEX index_board_assignees_on_assignee_id ON board_assignees USING btree (assignee_id);

CREATE UNIQUE INDEX index_board_assignees_on_board_id_and_assignee_id ON board_assignees USING btree (board_id, assignee_id);

CREATE INDEX index_board_group_recent_visits_on_board_id ON board_group_recent_visits USING btree (board_id);

CREATE INDEX index_board_group_recent_visits_on_group_id ON board_group_recent_visits USING btree (group_id);

CREATE UNIQUE INDEX index_board_group_recent_visits_on_user_group_and_board ON board_group_recent_visits USING btree (user_id, group_id, board_id);

CREATE INDEX index_board_group_recent_visits_on_user_id ON board_group_recent_visits USING btree (user_id);

CREATE UNIQUE INDEX index_board_labels_on_board_id_and_label_id ON board_labels USING btree (board_id, label_id);

CREATE INDEX index_board_labels_on_label_id ON board_labels USING btree (label_id);

CREATE INDEX index_board_project_recent_visits_on_board_id ON board_project_recent_visits USING btree (board_id);

CREATE INDEX index_board_project_recent_visits_on_project_id ON board_project_recent_visits USING btree (project_id);

CREATE INDEX index_board_project_recent_visits_on_user_id ON board_project_recent_visits USING btree (user_id);

CREATE UNIQUE INDEX index_board_project_recent_visits_on_user_project_and_board ON board_project_recent_visits USING btree (user_id, project_id, board_id);

CREATE INDEX index_board_user_preferences_on_board_id ON board_user_preferences USING btree (board_id);

CREATE INDEX index_board_user_preferences_on_user_id ON board_user_preferences USING btree (user_id);

CREATE UNIQUE INDEX index_board_user_preferences_on_user_id_and_board_id ON board_user_preferences USING btree (user_id, board_id);

CREATE INDEX index_boards_epic_user_preferences_on_board_id ON boards_epic_user_preferences USING btree (board_id);

CREATE UNIQUE INDEX index_boards_epic_user_preferences_on_board_user_epic_unique ON boards_epic_user_preferences USING btree (board_id, user_id, epic_id);

CREATE INDEX index_boards_epic_user_preferences_on_epic_id ON boards_epic_user_preferences USING btree (epic_id);

CREATE INDEX index_boards_epic_user_preferences_on_user_id ON boards_epic_user_preferences USING btree (user_id);

CREATE INDEX index_boards_on_group_id ON boards USING btree (group_id);

CREATE INDEX index_boards_on_milestone_id ON boards USING btree (milestone_id);

CREATE INDEX index_boards_on_project_id ON boards USING btree (project_id);

CREATE INDEX index_broadcast_message_on_ends_at_and_broadcast_type_and_id ON broadcast_messages USING btree (ends_at, broadcast_type, id);

CREATE INDEX index_bulk_import_configurations_on_bulk_import_id ON bulk_import_configurations USING btree (bulk_import_id);

CREATE INDEX index_bulk_import_entities_on_bulk_import_id ON bulk_import_entities USING btree (bulk_import_id);

CREATE INDEX index_bulk_import_entities_on_namespace_id ON bulk_import_entities USING btree (namespace_id);

CREATE INDEX index_bulk_import_entities_on_parent_id ON bulk_import_entities USING btree (parent_id);

CREATE INDEX index_bulk_import_entities_on_project_id ON bulk_import_entities USING btree (project_id);

CREATE INDEX index_bulk_imports_on_user_id ON bulk_imports USING btree (user_id);

CREATE UNIQUE INDEX index_chat_names_on_service_id_and_team_id_and_chat_id ON chat_names USING btree (service_id, team_id, chat_id);

CREATE UNIQUE INDEX index_chat_names_on_user_id_and_service_id ON chat_names USING btree (user_id, service_id);

CREATE UNIQUE INDEX index_chat_teams_on_namespace_id ON chat_teams USING btree (namespace_id);

CREATE UNIQUE INDEX index_ci_build_needs_on_build_id_and_name ON ci_build_needs USING btree (build_id, name);

CREATE UNIQUE INDEX index_ci_build_pending_states_on_build_id ON ci_build_pending_states USING btree (build_id);

CREATE INDEX index_ci_build_report_results_on_project_id ON ci_build_report_results USING btree (project_id);

CREATE UNIQUE INDEX index_ci_build_trace_chunks_on_build_id_and_chunk_index ON ci_build_trace_chunks USING btree (build_id, chunk_index);

CREATE UNIQUE INDEX index_ci_build_trace_section_names_on_project_id_and_name ON ci_build_trace_section_names USING btree (project_id, name);

CREATE INDEX index_ci_build_trace_sections_on_project_id ON ci_build_trace_sections USING btree (project_id);

CREATE INDEX index_ci_build_trace_sections_on_section_name_id ON ci_build_trace_sections USING btree (section_name_id);

CREATE UNIQUE INDEX index_ci_builds_metadata_on_build_id ON ci_builds_metadata USING btree (build_id);

CREATE INDEX index_ci_builds_metadata_on_build_id_and_has_exposed_artifacts ON ci_builds_metadata USING btree (build_id) WHERE (has_exposed_artifacts IS TRUE);

CREATE INDEX index_ci_builds_metadata_on_build_id_and_interruptible ON ci_builds_metadata USING btree (build_id) WHERE (interruptible = true);

CREATE INDEX index_ci_builds_metadata_on_project_id ON ci_builds_metadata USING btree (project_id);

CREATE INDEX index_ci_builds_on_artifacts_expire_at ON ci_builds USING btree (artifacts_expire_at) WHERE (artifacts_file <> ''::text);

CREATE INDEX index_ci_builds_on_auto_canceled_by_id ON ci_builds USING btree (auto_canceled_by_id);

CREATE INDEX index_ci_builds_on_commit_id_and_stage_idx_and_created_at ON ci_builds USING btree (commit_id, stage_idx, created_at);

CREATE INDEX index_ci_builds_on_commit_id_and_status_and_type ON ci_builds USING btree (commit_id, status, type);

CREATE INDEX index_ci_builds_on_commit_id_and_type_and_name_and_ref ON ci_builds USING btree (commit_id, type, name, ref);

CREATE INDEX index_ci_builds_on_commit_id_and_type_and_ref ON ci_builds USING btree (commit_id, type, ref);

CREATE INDEX index_ci_builds_on_commit_id_artifacts_expired_at_and_id ON ci_builds USING btree (commit_id, artifacts_expire_at, id) WHERE (((type)::text = 'Ci::Build'::text) AND ((retried = false) OR (retried IS NULL)) AND ((name)::text = ANY (ARRAY[('sast'::character varying)::text, ('secret_detection'::character varying)::text, ('dependency_scanning'::character varying)::text, ('container_scanning'::character varying)::text, ('dast'::character varying)::text])));

CREATE INDEX index_ci_builds_on_project_id_and_id ON ci_builds USING btree (project_id, id);

CREATE INDEX index_ci_builds_on_project_id_and_name_and_ref ON ci_builds USING btree (project_id, name, ref) WHERE (((type)::text = 'Ci::Build'::text) AND ((status)::text = 'success'::text) AND ((retried = false) OR (retried IS NULL)));

CREATE INDEX index_ci_builds_on_project_id_for_successfull_pages_deploy ON ci_builds USING btree (project_id) WHERE (((type)::text = 'GenericCommitStatus'::text) AND ((stage)::text = 'deploy'::text) AND ((name)::text = 'pages:deploy'::text) AND ((status)::text = 'success'::text));

CREATE INDEX index_ci_builds_on_protected ON ci_builds USING btree (protected);

CREATE INDEX index_ci_builds_on_queued_at ON ci_builds USING btree (queued_at);

CREATE INDEX index_ci_builds_on_runner_id ON ci_builds USING btree (runner_id);

CREATE INDEX index_ci_builds_on_stage_id ON ci_builds USING btree (stage_id);

CREATE INDEX index_ci_builds_on_status_and_type_and_runner_id ON ci_builds USING btree (status, type, runner_id);

CREATE UNIQUE INDEX index_ci_builds_on_token ON ci_builds USING btree (token);

CREATE UNIQUE INDEX index_ci_builds_on_token_encrypted ON ci_builds USING btree (token_encrypted) WHERE (token_encrypted IS NOT NULL);

CREATE INDEX index_ci_builds_on_updated_at ON ci_builds USING btree (updated_at);

CREATE INDEX index_ci_builds_on_upstream_pipeline_id ON ci_builds USING btree (upstream_pipeline_id) WHERE (upstream_pipeline_id IS NOT NULL);

CREATE INDEX index_ci_builds_on_user_id ON ci_builds USING btree (user_id);

CREATE INDEX index_ci_builds_on_user_id_and_created_at_and_type_eq_ci_build ON ci_builds USING btree (user_id, created_at) WHERE ((type)::text = 'Ci::Build'::text);

CREATE INDEX index_ci_builds_project_id_and_status_for_live_jobs_partial2 ON ci_builds USING btree (project_id, status) WHERE (((type)::text = 'Ci::Build'::text) AND ((status)::text = ANY (ARRAY[('running'::character varying)::text, ('pending'::character varying)::text, ('created'::character varying)::text])));

CREATE UNIQUE INDEX index_ci_builds_runner_session_on_build_id ON ci_builds_runner_session USING btree (build_id);

CREATE INDEX index_ci_daily_build_group_report_results_on_last_pipeline_id ON ci_daily_build_group_report_results USING btree (last_pipeline_id);

CREATE INDEX index_ci_deleted_objects_on_pick_up_at ON ci_deleted_objects USING btree (pick_up_at);

CREATE INDEX index_ci_freeze_periods_on_project_id ON ci_freeze_periods USING btree (project_id);

CREATE UNIQUE INDEX index_ci_group_variables_on_group_id_and_key ON ci_group_variables USING btree (group_id, key);

CREATE UNIQUE INDEX index_ci_instance_variables_on_key ON ci_instance_variables USING btree (key);

CREATE INDEX index_ci_job_artifacts_for_terraform_reports ON ci_job_artifacts USING btree (project_id, id) WHERE (file_type = 18);

CREATE INDEX index_ci_job_artifacts_id_for_terraform_reports ON ci_job_artifacts USING btree (id) WHERE (file_type = 18);

CREATE INDEX index_ci_job_artifacts_on_expire_at_and_job_id ON ci_job_artifacts USING btree (expire_at, job_id);

CREATE INDEX index_ci_job_artifacts_on_file_store ON ci_job_artifacts USING btree (file_store);

CREATE UNIQUE INDEX index_ci_job_artifacts_on_job_id_and_file_type ON ci_job_artifacts USING btree (job_id, file_type);

CREATE INDEX index_ci_job_artifacts_on_project_id ON ci_job_artifacts USING btree (project_id);

CREATE INDEX index_ci_job_artifacts_on_project_id_for_security_reports ON ci_job_artifacts USING btree (project_id) WHERE (file_type = ANY (ARRAY[5, 6, 7, 8]));

CREATE INDEX index_ci_job_variables_on_job_id ON ci_job_variables USING btree (job_id);

CREATE UNIQUE INDEX index_ci_job_variables_on_key_and_job_id ON ci_job_variables USING btree (key, job_id);

CREATE INDEX index_ci_pipeline_artifacts_on_expire_at ON ci_pipeline_artifacts USING btree (expire_at);

CREATE INDEX index_ci_pipeline_artifacts_on_pipeline_id ON ci_pipeline_artifacts USING btree (pipeline_id);

CREATE UNIQUE INDEX index_ci_pipeline_artifacts_on_pipeline_id_and_file_type ON ci_pipeline_artifacts USING btree (pipeline_id, file_type);

CREATE INDEX index_ci_pipeline_artifacts_on_project_id ON ci_pipeline_artifacts USING btree (project_id);

CREATE INDEX index_ci_pipeline_chat_data_on_chat_name_id ON ci_pipeline_chat_data USING btree (chat_name_id);

CREATE UNIQUE INDEX index_ci_pipeline_chat_data_on_pipeline_id ON ci_pipeline_chat_data USING btree (pipeline_id);

CREATE INDEX index_ci_pipeline_messages_on_pipeline_id ON ci_pipeline_messages USING btree (pipeline_id);

CREATE UNIQUE INDEX index_ci_pipeline_schedule_variables_on_schedule_id_and_key ON ci_pipeline_schedule_variables USING btree (pipeline_schedule_id, key);

CREATE INDEX index_ci_pipeline_schedules_on_next_run_at_and_active ON ci_pipeline_schedules USING btree (next_run_at, active);

CREATE INDEX index_ci_pipeline_schedules_on_owner_id ON ci_pipeline_schedules USING btree (owner_id);

CREATE INDEX index_ci_pipeline_schedules_on_project_id ON ci_pipeline_schedules USING btree (project_id);

CREATE UNIQUE INDEX index_ci_pipeline_variables_on_pipeline_id_and_key ON ci_pipeline_variables USING btree (pipeline_id, key);

CREATE INDEX index_ci_pipelines_config_on_pipeline_id ON ci_pipelines_config USING btree (pipeline_id);

CREATE INDEX index_ci_pipelines_for_ondemand_dast_scans ON ci_pipelines USING btree (id) WHERE (source = 13);

CREATE INDEX index_ci_pipelines_on_auto_canceled_by_id ON ci_pipelines USING btree (auto_canceled_by_id);

CREATE INDEX index_ci_pipelines_on_ci_ref_id ON ci_pipelines USING btree (ci_ref_id) WHERE (ci_ref_id IS NOT NULL);

CREATE INDEX index_ci_pipelines_on_external_pull_request_id ON ci_pipelines USING btree (external_pull_request_id) WHERE (external_pull_request_id IS NOT NULL);

CREATE INDEX index_ci_pipelines_on_merge_request_id ON ci_pipelines USING btree (merge_request_id) WHERE (merge_request_id IS NOT NULL);

CREATE INDEX index_ci_pipelines_on_pipeline_schedule_id ON ci_pipelines USING btree (pipeline_schedule_id);

CREATE INDEX index_ci_pipelines_on_project_id_and_created_at ON ci_pipelines USING btree (project_id, created_at);

CREATE INDEX index_ci_pipelines_on_project_id_and_id_desc ON ci_pipelines USING btree (project_id, id DESC);

CREATE UNIQUE INDEX index_ci_pipelines_on_project_id_and_iid ON ci_pipelines USING btree (project_id, iid) WHERE (iid IS NOT NULL);

CREATE INDEX index_ci_pipelines_on_project_id_and_ref_and_status_and_id ON ci_pipelines USING btree (project_id, ref, status, id);

CREATE INDEX index_ci_pipelines_on_project_id_and_sha ON ci_pipelines USING btree (project_id, sha);

CREATE INDEX index_ci_pipelines_on_project_id_and_source ON ci_pipelines USING btree (project_id, source);

CREATE INDEX index_ci_pipelines_on_project_id_and_status_and_config_source ON ci_pipelines USING btree (project_id, status, config_source);

CREATE INDEX index_ci_pipelines_on_project_id_and_status_and_updated_at ON ci_pipelines USING btree (project_id, status, updated_at);

CREATE INDEX index_ci_pipelines_on_project_id_and_user_id_and_status_and_ref ON ci_pipelines USING btree (project_id, user_id, status, ref) WHERE (source <> 12);

CREATE INDEX index_ci_pipelines_on_project_idandrefandiddesc ON ci_pipelines USING btree (project_id, ref, id DESC);

CREATE INDEX index_ci_pipelines_on_status_and_id ON ci_pipelines USING btree (status, id);

CREATE INDEX index_ci_pipelines_on_user_id_and_created_at_and_config_source ON ci_pipelines USING btree (user_id, created_at, config_source);

CREATE INDEX index_ci_pipelines_on_user_id_and_created_at_and_source ON ci_pipelines USING btree (user_id, created_at, source);

CREATE UNIQUE INDEX index_ci_refs_on_project_id_and_ref_path ON ci_refs USING btree (project_id, ref_path);

CREATE UNIQUE INDEX index_ci_resource_groups_on_project_id_and_key ON ci_resource_groups USING btree (project_id, key);

CREATE INDEX index_ci_resources_on_build_id ON ci_resources USING btree (build_id);

CREATE UNIQUE INDEX index_ci_resources_on_resource_group_id_and_build_id ON ci_resources USING btree (resource_group_id, build_id);

CREATE INDEX index_ci_runner_namespaces_on_namespace_id ON ci_runner_namespaces USING btree (namespace_id);

CREATE UNIQUE INDEX index_ci_runner_namespaces_on_runner_id_and_namespace_id ON ci_runner_namespaces USING btree (runner_id, namespace_id);

CREATE INDEX index_ci_runner_projects_on_project_id ON ci_runner_projects USING btree (project_id);

CREATE INDEX index_ci_runner_projects_on_runner_id ON ci_runner_projects USING btree (runner_id);

CREATE INDEX index_ci_runners_on_contacted_at ON ci_runners USING btree (contacted_at);

CREATE INDEX index_ci_runners_on_is_shared ON ci_runners USING btree (is_shared);

CREATE INDEX index_ci_runners_on_locked ON ci_runners USING btree (locked);

CREATE INDEX index_ci_runners_on_runner_type ON ci_runners USING btree (runner_type);

CREATE INDEX index_ci_runners_on_token ON ci_runners USING btree (token);

CREATE INDEX index_ci_runners_on_token_encrypted ON ci_runners USING btree (token_encrypted);

CREATE INDEX index_ci_sources_pipelines_on_pipeline_id ON ci_sources_pipelines USING btree (pipeline_id);

CREATE INDEX index_ci_sources_pipelines_on_project_id ON ci_sources_pipelines USING btree (project_id);

CREATE INDEX index_ci_sources_pipelines_on_source_job_id ON ci_sources_pipelines USING btree (source_job_id);

CREATE INDEX index_ci_sources_pipelines_on_source_pipeline_id ON ci_sources_pipelines USING btree (source_pipeline_id);

CREATE INDEX index_ci_sources_pipelines_on_source_project_id ON ci_sources_pipelines USING btree (source_project_id);

CREATE INDEX index_ci_sources_projects_on_pipeline_id ON ci_sources_projects USING btree (pipeline_id);

CREATE UNIQUE INDEX index_ci_sources_projects_on_source_project_id_and_pipeline_id ON ci_sources_projects USING btree (source_project_id, pipeline_id);

CREATE INDEX index_ci_stages_on_pipeline_id ON ci_stages USING btree (pipeline_id);

CREATE UNIQUE INDEX index_ci_stages_on_pipeline_id_and_name ON ci_stages USING btree (pipeline_id, name);

CREATE INDEX index_ci_stages_on_pipeline_id_and_position ON ci_stages USING btree (pipeline_id, "position");

CREATE INDEX index_ci_stages_on_project_id ON ci_stages USING btree (project_id);

CREATE INDEX index_ci_subscriptions_projects_on_upstream_project_id ON ci_subscriptions_projects USING btree (upstream_project_id);

CREATE UNIQUE INDEX index_ci_subscriptions_projects_unique_subscription ON ci_subscriptions_projects USING btree (downstream_project_id, upstream_project_id);

CREATE INDEX index_ci_trigger_requests_on_commit_id ON ci_trigger_requests USING btree (commit_id);

CREATE INDEX index_ci_trigger_requests_on_trigger_id_and_id ON ci_trigger_requests USING btree (trigger_id, id DESC);

CREATE INDEX index_ci_triggers_on_owner_id ON ci_triggers USING btree (owner_id);

CREATE INDEX index_ci_triggers_on_project_id ON ci_triggers USING btree (project_id);

CREATE INDEX index_ci_variables_on_key ON ci_variables USING btree (key);

CREATE UNIQUE INDEX index_ci_variables_on_project_id_and_key_and_environment_scope ON ci_variables USING btree (project_id, key, environment_scope);

CREATE INDEX index_cluster_agent_tokens_on_agent_id ON cluster_agent_tokens USING btree (agent_id);

CREATE UNIQUE INDEX index_cluster_agent_tokens_on_token_encrypted ON cluster_agent_tokens USING btree (token_encrypted);

CREATE UNIQUE INDEX index_cluster_agents_on_project_id_and_name ON cluster_agents USING btree (project_id, name);

CREATE UNIQUE INDEX index_cluster_groups_on_cluster_id_and_group_id ON cluster_groups USING btree (cluster_id, group_id);

CREATE INDEX index_cluster_groups_on_group_id ON cluster_groups USING btree (group_id);

CREATE UNIQUE INDEX index_cluster_platforms_kubernetes_on_cluster_id ON cluster_platforms_kubernetes USING btree (cluster_id);

CREATE INDEX index_cluster_projects_on_cluster_id ON cluster_projects USING btree (cluster_id);

CREATE INDEX index_cluster_projects_on_project_id ON cluster_projects USING btree (project_id);

CREATE UNIQUE INDEX index_cluster_providers_aws_on_cluster_id ON cluster_providers_aws USING btree (cluster_id);

CREATE INDEX index_cluster_providers_aws_on_cluster_id_and_status ON cluster_providers_aws USING btree (cluster_id, status);

CREATE INDEX index_cluster_providers_gcp_on_cloud_run ON cluster_providers_gcp USING btree (cloud_run);

CREATE UNIQUE INDEX index_cluster_providers_gcp_on_cluster_id ON cluster_providers_gcp USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_cert_managers_on_cluster_id ON clusters_applications_cert_managers USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_cilium_on_cluster_id ON clusters_applications_cilium USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_crossplane_on_cluster_id ON clusters_applications_crossplane USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_elastic_stacks_on_cluster_id ON clusters_applications_elastic_stacks USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_fluentd_on_cluster_id ON clusters_applications_fluentd USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_helm_on_cluster_id ON clusters_applications_helm USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_ingress_on_cluster_id ON clusters_applications_ingress USING btree (cluster_id);

CREATE INDEX index_clusters_applications_ingress_on_modsecurity ON clusters_applications_ingress USING btree (modsecurity_enabled, modsecurity_mode, cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_jupyter_on_cluster_id ON clusters_applications_jupyter USING btree (cluster_id);

CREATE INDEX index_clusters_applications_jupyter_on_oauth_application_id ON clusters_applications_jupyter USING btree (oauth_application_id);

CREATE UNIQUE INDEX index_clusters_applications_knative_on_cluster_id ON clusters_applications_knative USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_prometheus_on_cluster_id ON clusters_applications_prometheus USING btree (cluster_id);

CREATE UNIQUE INDEX index_clusters_applications_runners_on_cluster_id ON clusters_applications_runners USING btree (cluster_id);

CREATE INDEX index_clusters_applications_runners_on_runner_id ON clusters_applications_runners USING btree (runner_id);

CREATE INDEX index_clusters_kubernetes_namespaces_on_cluster_id ON clusters_kubernetes_namespaces USING btree (cluster_id);

CREATE INDEX index_clusters_kubernetes_namespaces_on_cluster_project_id ON clusters_kubernetes_namespaces USING btree (cluster_project_id);

CREATE INDEX index_clusters_kubernetes_namespaces_on_environment_id ON clusters_kubernetes_namespaces USING btree (environment_id);

CREATE INDEX index_clusters_kubernetes_namespaces_on_project_id ON clusters_kubernetes_namespaces USING btree (project_id);

CREATE INDEX index_clusters_on_enabled_and_provider_type_and_id ON clusters USING btree (enabled, provider_type, id);

CREATE INDEX index_clusters_on_enabled_cluster_type_id_and_created_at ON clusters USING btree (enabled, cluster_type, id, created_at);

CREATE INDEX index_clusters_on_management_project_id ON clusters USING btree (management_project_id) WHERE (management_project_id IS NOT NULL);

CREATE INDEX index_clusters_on_user_id ON clusters USING btree (user_id);

CREATE UNIQUE INDEX index_commit_user_mentions_on_note_id ON commit_user_mentions USING btree (note_id);

CREATE INDEX index_container_expiration_policies_on_next_run_at_and_enabled ON container_expiration_policies USING btree (next_run_at, enabled);

CREATE INDEX index_container_repositories_on_project_id ON container_repositories USING btree (project_id);

CREATE UNIQUE INDEX index_container_repositories_on_project_id_and_name ON container_repositories USING btree (project_id, name);

CREATE INDEX index_container_repository_on_name_trigram ON container_repositories USING gin (name gin_trgm_ops);

CREATE INDEX index_created_at_on_codeowner_approval_merge_request_rules ON approval_merge_request_rules USING btree (created_at) WHERE ((rule_type = 2) AND (section <> 'codeowners'::text));

CREATE INDEX index_csv_issue_imports_on_project_id ON csv_issue_imports USING btree (project_id);

CREATE INDEX index_csv_issue_imports_on_user_id ON csv_issue_imports USING btree (user_id);

CREATE UNIQUE INDEX index_custom_emoji_on_namespace_id_and_name ON custom_emoji USING btree (namespace_id, name);

CREATE UNIQUE INDEX index_daily_build_group_report_results_unique_columns ON ci_daily_build_group_report_results USING btree (project_id, ref_path, date, group_name);

CREATE UNIQUE INDEX index_dast_scanner_profiles_on_project_id_and_name ON dast_scanner_profiles USING btree (project_id, name);

CREATE INDEX index_dast_site_profiles_on_dast_site_id ON dast_site_profiles USING btree (dast_site_id);

CREATE UNIQUE INDEX index_dast_site_profiles_on_project_id_and_name ON dast_site_profiles USING btree (project_id, name);

CREATE INDEX index_dast_site_tokens_on_project_id ON dast_site_tokens USING btree (project_id);

CREATE INDEX index_dast_site_validations_on_dast_site_token_id ON dast_site_validations USING btree (dast_site_token_id);

CREATE INDEX index_dast_site_validations_on_url_base ON dast_site_validations USING btree (url_base);

CREATE INDEX index_dast_sites_on_dast_site_validation_id ON dast_sites USING btree (dast_site_validation_id);

CREATE UNIQUE INDEX index_dast_sites_on_project_id_and_url ON dast_sites USING btree (project_id, url);

CREATE INDEX index_dependency_proxy_blobs_on_group_id_and_file_name ON dependency_proxy_blobs USING btree (group_id, file_name);

CREATE INDEX index_dependency_proxy_group_settings_on_group_id ON dependency_proxy_group_settings USING btree (group_id);

CREATE INDEX index_deploy_key_id_on_protected_branch_push_access_levels ON protected_branch_push_access_levels USING btree (deploy_key_id);

CREATE INDEX index_deploy_keys_projects_on_deploy_key_id ON deploy_keys_projects USING btree (deploy_key_id);

CREATE INDEX index_deploy_keys_projects_on_project_id ON deploy_keys_projects USING btree (project_id);

CREATE UNIQUE INDEX index_deploy_tokens_on_token ON deploy_tokens USING btree (token);

CREATE INDEX index_deploy_tokens_on_token_and_expires_at_and_id ON deploy_tokens USING btree (token, expires_at, id) WHERE (revoked IS FALSE);

CREATE UNIQUE INDEX index_deploy_tokens_on_token_encrypted ON deploy_tokens USING btree (token_encrypted);

CREATE UNIQUE INDEX index_deployment_clusters_on_cluster_id_and_deployment_id ON deployment_clusters USING btree (cluster_id, deployment_id);

CREATE INDEX index_deployment_merge_requests_on_merge_request_id ON deployment_merge_requests USING btree (merge_request_id);

CREATE INDEX index_deployments_on_cluster_id_and_status ON deployments USING btree (cluster_id, status);

CREATE INDEX index_deployments_on_created_at ON deployments USING btree (created_at);

CREATE INDEX index_deployments_on_deployable_type_and_deployable_id ON deployments USING btree (deployable_type, deployable_id);

CREATE INDEX index_deployments_on_environment_id_and_id ON deployments USING btree (environment_id, id);

CREATE INDEX index_deployments_on_environment_id_and_iid_and_project_id ON deployments USING btree (environment_id, iid, project_id);

CREATE INDEX index_deployments_on_environment_id_and_status ON deployments USING btree (environment_id, status);

CREATE INDEX index_deployments_on_id_and_status_and_created_at ON deployments USING btree (id, status, created_at);

CREATE INDEX index_deployments_on_id_where_cluster_id_present ON deployments USING btree (id) WHERE (cluster_id IS NOT NULL);

CREATE INDEX index_deployments_on_project_id_and_id ON deployments USING btree (project_id, id DESC);

CREATE UNIQUE INDEX index_deployments_on_project_id_and_iid ON deployments USING btree (project_id, iid);

CREATE INDEX index_deployments_on_project_id_and_ref ON deployments USING btree (project_id, ref);

CREATE INDEX index_deployments_on_project_id_and_status ON deployments USING btree (project_id, status);

CREATE INDEX index_deployments_on_project_id_and_status_and_created_at ON deployments USING btree (project_id, status, created_at);

CREATE INDEX index_deployments_on_project_id_and_updated_at_and_id ON deployments USING btree (project_id, updated_at DESC, id DESC);

CREATE INDEX index_deployments_on_project_id_sha ON deployments USING btree (project_id, sha);

CREATE INDEX index_deployments_on_user_id_and_status_and_created_at ON deployments USING btree (user_id, status, created_at);

CREATE INDEX index_description_versions_on_epic_id ON description_versions USING btree (epic_id) WHERE (epic_id IS NOT NULL);

CREATE INDEX index_description_versions_on_issue_id ON description_versions USING btree (issue_id) WHERE (issue_id IS NOT NULL);

CREATE INDEX index_description_versions_on_merge_request_id ON description_versions USING btree (merge_request_id) WHERE (merge_request_id IS NOT NULL);

CREATE INDEX index_design_management_designs_issue_id_relative_position_id ON design_management_designs USING btree (issue_id, relative_position, id);

CREATE UNIQUE INDEX index_design_management_designs_on_issue_id_and_filename ON design_management_designs USING btree (issue_id, filename);

CREATE INDEX index_design_management_designs_on_project_id ON design_management_designs USING btree (project_id);

CREATE INDEX index_design_management_designs_versions_on_design_id ON design_management_designs_versions USING btree (design_id);

CREATE INDEX index_design_management_designs_versions_on_event ON design_management_designs_versions USING btree (event);

CREATE INDEX index_design_management_designs_versions_on_version_id ON design_management_designs_versions USING btree (version_id);

CREATE INDEX index_design_management_versions_on_author_id ON design_management_versions USING btree (author_id) WHERE (author_id IS NOT NULL);

CREATE INDEX index_design_management_versions_on_issue_id ON design_management_versions USING btree (issue_id);

CREATE UNIQUE INDEX index_design_management_versions_on_sha_and_issue_id ON design_management_versions USING btree (sha, issue_id);

CREATE UNIQUE INDEX index_design_user_mentions_on_note_id ON design_user_mentions USING btree (note_id);

CREATE UNIQUE INDEX index_diff_note_positions_on_note_id_and_diff_type ON diff_note_positions USING btree (note_id, diff_type);

CREATE INDEX index_draft_notes_on_author_id ON draft_notes USING btree (author_id);

CREATE INDEX index_draft_notes_on_discussion_id ON draft_notes USING btree (discussion_id);

CREATE INDEX index_draft_notes_on_merge_request_id ON draft_notes USING btree (merge_request_id);

CREATE UNIQUE INDEX index_elastic_reindexing_tasks_on_in_progress ON elastic_reindexing_tasks USING btree (in_progress) WHERE in_progress;

CREATE INDEX index_elastic_reindexing_tasks_on_state ON elastic_reindexing_tasks USING btree (state);

CREATE INDEX index_elasticsearch_indexed_namespaces_on_created_at ON elasticsearch_indexed_namespaces USING btree (created_at);

CREATE UNIQUE INDEX index_elasticsearch_indexed_namespaces_on_namespace_id ON elasticsearch_indexed_namespaces USING btree (namespace_id);

CREATE UNIQUE INDEX index_elasticsearch_indexed_projects_on_project_id ON elasticsearch_indexed_projects USING btree (project_id);

CREATE UNIQUE INDEX index_emails_on_confirmation_token ON emails USING btree (confirmation_token);

CREATE UNIQUE INDEX index_emails_on_email ON emails USING btree (email);

CREATE INDEX index_emails_on_user_id ON emails USING btree (user_id);

CREATE INDEX index_enabled_clusters_on_id ON clusters USING btree (id) WHERE (enabled = true);

CREATE INDEX index_environments_on_auto_stop_at ON environments USING btree (auto_stop_at) WHERE (auto_stop_at IS NOT NULL);

CREATE INDEX index_environments_on_name_varchar_pattern_ops ON environments USING btree (name varchar_pattern_ops);

CREATE UNIQUE INDEX index_environments_on_project_id_and_name ON environments USING btree (project_id, name);

CREATE UNIQUE INDEX index_environments_on_project_id_and_slug ON environments USING btree (project_id, slug);

CREATE INDEX index_environments_on_project_id_state_environment_type ON environments USING btree (project_id, state, environment_type);

CREATE INDEX index_environments_on_state_and_auto_stop_at ON environments USING btree (state, auto_stop_at) WHERE ((auto_stop_at IS NOT NULL) AND ((state)::text = 'available'::text));

CREATE INDEX index_epic_issues_on_epic_id ON epic_issues USING btree (epic_id);

CREATE UNIQUE INDEX index_epic_issues_on_issue_id ON epic_issues USING btree (issue_id);

CREATE INDEX index_epic_metrics ON epic_metrics USING btree (epic_id);

CREATE UNIQUE INDEX index_epic_user_mentions_on_note_id ON epic_user_mentions USING btree (note_id) WHERE (note_id IS NOT NULL);

CREATE INDEX index_epics_on_assignee_id ON epics USING btree (assignee_id);

CREATE INDEX index_epics_on_author_id ON epics USING btree (author_id);

CREATE INDEX index_epics_on_closed_by_id ON epics USING btree (closed_by_id);

CREATE INDEX index_epics_on_confidential ON epics USING btree (confidential);

CREATE INDEX index_epics_on_due_date_sourcing_epic_id ON epics USING btree (due_date_sourcing_epic_id) WHERE (due_date_sourcing_epic_id IS NOT NULL);

CREATE INDEX index_epics_on_due_date_sourcing_milestone_id ON epics USING btree (due_date_sourcing_milestone_id);

CREATE INDEX index_epics_on_end_date ON epics USING btree (end_date);

CREATE INDEX index_epics_on_group_id ON epics USING btree (group_id);

CREATE UNIQUE INDEX index_epics_on_group_id_and_external_key ON epics USING btree (group_id, external_key) WHERE (external_key IS NOT NULL);

CREATE INDEX index_epics_on_group_id_and_iid_varchar_pattern ON epics USING btree (group_id, ((iid)::character varying) varchar_pattern_ops);

CREATE INDEX index_epics_on_iid ON epics USING btree (iid);

CREATE INDEX index_epics_on_last_edited_by_id ON epics USING btree (last_edited_by_id);

CREATE INDEX index_epics_on_parent_id ON epics USING btree (parent_id);

CREATE INDEX index_epics_on_start_date ON epics USING btree (start_date);

CREATE INDEX index_epics_on_start_date_sourcing_epic_id ON epics USING btree (start_date_sourcing_epic_id) WHERE (start_date_sourcing_epic_id IS NOT NULL);

CREATE INDEX index_epics_on_start_date_sourcing_milestone_id ON epics USING btree (start_date_sourcing_milestone_id);

CREATE INDEX index_events_on_action ON events USING btree (action);

CREATE INDEX index_events_on_author_id_and_created_at ON events USING btree (author_id, created_at);

CREATE INDEX index_events_on_author_id_and_created_at_merge_requests ON events USING btree (author_id, created_at) WHERE ((target_type)::text = 'MergeRequest'::text);

CREATE INDEX index_events_on_author_id_and_project_id ON events USING btree (author_id, project_id);

CREATE INDEX index_events_on_group_id_partial ON events USING btree (group_id) WHERE (group_id IS NOT NULL);

CREATE INDEX index_events_on_project_id_and_created_at ON events USING btree (project_id, created_at);

CREATE INDEX index_events_on_project_id_and_id ON events USING btree (project_id, id);

CREATE INDEX index_events_on_project_id_and_id_desc_on_merged_action ON events USING btree (project_id, id DESC) WHERE (action = 7);

CREATE INDEX index_events_on_target_type_and_target_id ON events USING btree (target_type, target_id);

CREATE UNIQUE INDEX index_events_on_target_type_and_target_id_and_fingerprint ON events USING btree (target_type, target_id, fingerprint);

CREATE INDEX index_evidences_on_release_id ON evidences USING btree (release_id);

CREATE INDEX index_experiment_users_on_experiment_id ON experiment_users USING btree (experiment_id);

CREATE INDEX index_experiment_users_on_user_id ON experiment_users USING btree (user_id);

CREATE UNIQUE INDEX index_experiments_on_name ON experiments USING btree (name);

CREATE INDEX index_expired_and_not_notified_personal_access_tokens ON personal_access_tokens USING btree (id, expires_at) WHERE ((impersonation = false) AND (revoked = false) AND (expire_notification_delivered = false));

CREATE UNIQUE INDEX index_external_pull_requests_on_project_and_branches ON external_pull_requests USING btree (project_id, source_branch, target_branch);

CREATE UNIQUE INDEX index_feature_flag_scopes_on_flag_id_and_environment_scope ON operations_feature_flag_scopes USING btree (feature_flag_id, environment_scope);

CREATE UNIQUE INDEX index_feature_flags_clients_on_project_id_and_token_encrypted ON operations_feature_flags_clients USING btree (project_id, token_encrypted);

CREATE UNIQUE INDEX index_feature_gates_on_feature_key_and_key_and_value ON feature_gates USING btree (feature_key, key, value);

CREATE UNIQUE INDEX index_features_on_key ON features USING btree (key);

CREATE INDEX index_for_resource_group ON ci_builds USING btree (resource_group_id, id) WHERE (resource_group_id IS NOT NULL);

CREATE INDEX index_for_status_per_branch_per_project ON merge_trains USING btree (target_project_id, target_branch, status);

CREATE INDEX index_fork_network_members_on_fork_network_id ON fork_network_members USING btree (fork_network_id);

CREATE INDEX index_fork_network_members_on_forked_from_project_id ON fork_network_members USING btree (forked_from_project_id);

CREATE UNIQUE INDEX index_fork_network_members_on_project_id ON fork_network_members USING btree (project_id);

CREATE UNIQUE INDEX index_fork_networks_on_root_project_id ON fork_networks USING btree (root_project_id);

CREATE INDEX index_geo_event_log_on_cache_invalidation_event_id ON geo_event_log USING btree (cache_invalidation_event_id) WHERE (cache_invalidation_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_container_repository_updated_event_id ON geo_event_log USING btree (container_repository_updated_event_id);

CREATE INDEX index_geo_event_log_on_geo_event_id ON geo_event_log USING btree (geo_event_id) WHERE (geo_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_hashed_storage_attachments_event_id ON geo_event_log USING btree (hashed_storage_attachments_event_id) WHERE (hashed_storage_attachments_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_hashed_storage_migrated_event_id ON geo_event_log USING btree (hashed_storage_migrated_event_id) WHERE (hashed_storage_migrated_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_job_artifact_deleted_event_id ON geo_event_log USING btree (job_artifact_deleted_event_id) WHERE (job_artifact_deleted_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_lfs_object_deleted_event_id ON geo_event_log USING btree (lfs_object_deleted_event_id) WHERE (lfs_object_deleted_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_repositories_changed_event_id ON geo_event_log USING btree (repositories_changed_event_id) WHERE (repositories_changed_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_repository_created_event_id ON geo_event_log USING btree (repository_created_event_id) WHERE (repository_created_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_repository_deleted_event_id ON geo_event_log USING btree (repository_deleted_event_id) WHERE (repository_deleted_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_repository_renamed_event_id ON geo_event_log USING btree (repository_renamed_event_id) WHERE (repository_renamed_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_repository_updated_event_id ON geo_event_log USING btree (repository_updated_event_id) WHERE (repository_updated_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_reset_checksum_event_id ON geo_event_log USING btree (reset_checksum_event_id) WHERE (reset_checksum_event_id IS NOT NULL);

CREATE INDEX index_geo_event_log_on_upload_deleted_event_id ON geo_event_log USING btree (upload_deleted_event_id) WHERE (upload_deleted_event_id IS NOT NULL);

CREATE INDEX index_geo_hashed_storage_attachments_events_on_project_id ON geo_hashed_storage_attachments_events USING btree (project_id);

CREATE INDEX index_geo_hashed_storage_migrated_events_on_project_id ON geo_hashed_storage_migrated_events USING btree (project_id);

CREATE INDEX index_geo_job_artifact_deleted_events_on_job_artifact_id ON geo_job_artifact_deleted_events USING btree (job_artifact_id);

CREATE INDEX index_geo_lfs_object_deleted_events_on_lfs_object_id ON geo_lfs_object_deleted_events USING btree (lfs_object_id);

CREATE INDEX index_geo_node_namespace_links_on_geo_node_id ON geo_node_namespace_links USING btree (geo_node_id);

CREATE UNIQUE INDEX index_geo_node_namespace_links_on_geo_node_id_and_namespace_id ON geo_node_namespace_links USING btree (geo_node_id, namespace_id);

CREATE INDEX index_geo_node_namespace_links_on_namespace_id ON geo_node_namespace_links USING btree (namespace_id);

CREATE UNIQUE INDEX index_geo_node_statuses_on_geo_node_id ON geo_node_statuses USING btree (geo_node_id);

CREATE INDEX index_geo_nodes_on_access_key ON geo_nodes USING btree (access_key);

CREATE UNIQUE INDEX index_geo_nodes_on_name ON geo_nodes USING btree (name);

CREATE INDEX index_geo_nodes_on_primary ON geo_nodes USING btree ("primary");

CREATE INDEX index_geo_repositories_changed_events_on_geo_node_id ON geo_repositories_changed_events USING btree (geo_node_id);

CREATE INDEX index_geo_repository_created_events_on_project_id ON geo_repository_created_events USING btree (project_id);

CREATE INDEX index_geo_repository_deleted_events_on_project_id ON geo_repository_deleted_events USING btree (project_id);

CREATE INDEX index_geo_repository_renamed_events_on_project_id ON geo_repository_renamed_events USING btree (project_id);

CREATE INDEX index_geo_repository_updated_events_on_project_id ON geo_repository_updated_events USING btree (project_id);

CREATE INDEX index_geo_repository_updated_events_on_source ON geo_repository_updated_events USING btree (source);

CREATE INDEX index_geo_reset_checksum_events_on_project_id ON geo_reset_checksum_events USING btree (project_id);

CREATE INDEX index_geo_upload_deleted_events_on_upload_id ON geo_upload_deleted_events USING btree (upload_id);

CREATE INDEX index_gitlab_subscription_histories_on_gitlab_subscription_id ON gitlab_subscription_histories USING btree (gitlab_subscription_id);

CREATE INDEX index_gitlab_subscriptions_on_end_date_and_namespace_id ON gitlab_subscriptions USING btree (end_date, namespace_id);

CREATE INDEX index_gitlab_subscriptions_on_hosted_plan_id ON gitlab_subscriptions USING btree (hosted_plan_id);

CREATE UNIQUE INDEX index_gitlab_subscriptions_on_namespace_id ON gitlab_subscriptions USING btree (namespace_id);

CREATE UNIQUE INDEX index_gpg_key_subkeys_on_fingerprint ON gpg_key_subkeys USING btree (fingerprint);

CREATE INDEX index_gpg_key_subkeys_on_gpg_key_id ON gpg_key_subkeys USING btree (gpg_key_id);

CREATE UNIQUE INDEX index_gpg_key_subkeys_on_keyid ON gpg_key_subkeys USING btree (keyid);

CREATE UNIQUE INDEX index_gpg_keys_on_fingerprint ON gpg_keys USING btree (fingerprint);

CREATE UNIQUE INDEX index_gpg_keys_on_primary_keyid ON gpg_keys USING btree (primary_keyid);

CREATE INDEX index_gpg_keys_on_user_id ON gpg_keys USING btree (user_id);

CREATE UNIQUE INDEX index_gpg_signatures_on_commit_sha ON gpg_signatures USING btree (commit_sha);

CREATE INDEX index_gpg_signatures_on_gpg_key_id ON gpg_signatures USING btree (gpg_key_id);

CREATE INDEX index_gpg_signatures_on_gpg_key_primary_keyid ON gpg_signatures USING btree (gpg_key_primary_keyid);

CREATE INDEX index_gpg_signatures_on_gpg_key_subkey_id ON gpg_signatures USING btree (gpg_key_subkey_id);

CREATE INDEX index_gpg_signatures_on_project_id ON gpg_signatures USING btree (project_id);

CREATE INDEX index_grafana_integrations_on_enabled ON grafana_integrations USING btree (enabled) WHERE (enabled IS TRUE);

CREATE INDEX index_grafana_integrations_on_project_id ON grafana_integrations USING btree (project_id);

CREATE UNIQUE INDEX index_group_custom_attributes_on_group_id_and_key ON group_custom_attributes USING btree (group_id, key);

CREATE INDEX index_group_custom_attributes_on_key_and_value ON group_custom_attributes USING btree (key, value);

CREATE INDEX index_group_deletion_schedules_on_marked_for_deletion_on ON group_deletion_schedules USING btree (marked_for_deletion_on);

CREATE INDEX index_group_deletion_schedules_on_user_id ON group_deletion_schedules USING btree (user_id);

CREATE UNIQUE INDEX index_group_deploy_keys_group_on_group_deploy_key_and_group_ids ON group_deploy_keys_groups USING btree (group_id, group_deploy_key_id);

CREATE INDEX index_group_deploy_keys_groups_on_group_deploy_key_id ON group_deploy_keys_groups USING btree (group_deploy_key_id);

CREATE UNIQUE INDEX index_group_deploy_keys_on_fingerprint ON group_deploy_keys USING btree (fingerprint);

CREATE INDEX index_group_deploy_keys_on_fingerprint_sha256 ON group_deploy_keys USING btree (fingerprint_sha256);

CREATE INDEX index_group_deploy_keys_on_user_id ON group_deploy_keys USING btree (user_id);

CREATE INDEX index_group_deploy_tokens_on_deploy_token_id ON group_deploy_tokens USING btree (deploy_token_id);

CREATE UNIQUE INDEX index_group_deploy_tokens_on_group_and_deploy_token_ids ON group_deploy_tokens USING btree (group_id, deploy_token_id);

CREATE UNIQUE INDEX index_group_group_links_on_shared_group_and_shared_with_group ON group_group_links USING btree (shared_group_id, shared_with_group_id);

CREATE INDEX index_group_group_links_on_shared_with_group_id ON group_group_links USING btree (shared_with_group_id);

CREATE INDEX index_group_import_states_on_group_id ON group_import_states USING btree (group_id);

CREATE INDEX index_group_import_states_on_user_id ON group_import_states USING btree (user_id) WHERE (user_id IS NOT NULL);

CREATE UNIQUE INDEX index_group_stages_on_group_id_group_value_stream_id_and_name ON analytics_cycle_analytics_group_stages USING btree (group_id, group_value_stream_id, name);

CREATE UNIQUE INDEX index_group_wiki_repositories_on_disk_path ON group_wiki_repositories USING btree (disk_path);

CREATE INDEX index_group_wiki_repositories_on_shard_id ON group_wiki_repositories USING btree (shard_id);

CREATE UNIQUE INDEX index_http_integrations_on_active_and_project_and_endpoint ON alert_management_http_integrations USING btree (active, project_id, endpoint_identifier) WHERE active;

CREATE INDEX index_identities_on_saml_provider_id ON identities USING btree (saml_provider_id) WHERE (saml_provider_id IS NOT NULL);

CREATE INDEX index_identities_on_user_id ON identities USING btree (user_id);

CREATE UNIQUE INDEX index_import_export_uploads_on_group_id ON import_export_uploads USING btree (group_id) WHERE (group_id IS NOT NULL);

CREATE INDEX index_import_export_uploads_on_project_id ON import_export_uploads USING btree (project_id);

CREATE INDEX index_import_export_uploads_on_updated_at ON import_export_uploads USING btree (updated_at);

CREATE INDEX index_import_failures_on_correlation_id_value ON import_failures USING btree (correlation_id_value);

CREATE INDEX index_import_failures_on_group_id_not_null ON import_failures USING btree (group_id) WHERE (group_id IS NOT NULL);

CREATE INDEX index_import_failures_on_project_id_and_correlation_id_value ON import_failures USING btree (project_id, correlation_id_value) WHERE (retry_count = 0);

CREATE INDEX index_import_failures_on_project_id_not_null ON import_failures USING btree (project_id) WHERE (project_id IS NOT NULL);

CREATE INDEX index_imported_projects_on_import_type_creator_id_created_at ON projects USING btree (import_type, creator_id, created_at) WHERE (import_type IS NOT NULL);

CREATE UNIQUE INDEX index_index_statuses_on_project_id ON index_statuses USING btree (project_id);

CREATE INDEX index_insights_on_namespace_id ON insights USING btree (namespace_id);

CREATE INDEX index_insights_on_project_id ON insights USING btree (project_id);

CREATE INDEX index_internal_ids_on_namespace_id ON internal_ids USING btree (namespace_id);

CREATE INDEX index_internal_ids_on_project_id ON internal_ids USING btree (project_id);

CREATE UNIQUE INDEX index_internal_ids_on_usage_and_namespace_id ON internal_ids USING btree (usage, namespace_id) WHERE (namespace_id IS NOT NULL);

CREATE UNIQUE INDEX index_internal_ids_on_usage_and_project_id ON internal_ids USING btree (usage, project_id) WHERE (project_id IS NOT NULL);

CREATE INDEX index_ip_restrictions_on_group_id ON ip_restrictions USING btree (group_id);

CREATE UNIQUE INDEX index_issuable_severities_on_issue_id ON issuable_severities USING btree (issue_id);

CREATE UNIQUE INDEX index_issuable_slas_on_issue_id ON issuable_slas USING btree (issue_id);

CREATE INDEX index_issue_assignees_on_user_id ON issue_assignees USING btree (user_id);

CREATE UNIQUE INDEX index_issue_email_participants_on_issue_id_and_email ON issue_email_participants USING btree (issue_id, email);

CREATE INDEX index_issue_links_on_source_id ON issue_links USING btree (source_id);

CREATE UNIQUE INDEX index_issue_links_on_source_id_and_target_id ON issue_links USING btree (source_id, target_id);

CREATE INDEX index_issue_links_on_target_id ON issue_links USING btree (target_id);

CREATE INDEX index_issue_metrics ON issue_metrics USING btree (issue_id);

CREATE INDEX index_issue_metrics_on_issue_id_and_timestamps ON issue_metrics USING btree (issue_id, first_mentioned_in_commit_at, first_associated_with_milestone_at, first_added_to_board_at);

CREATE INDEX index_issue_on_project_id_state_id_and_blocking_issues_count ON issues USING btree (project_id, state_id, blocking_issues_count);

CREATE INDEX index_issue_tracker_data_on_service_id ON issue_tracker_data USING btree (service_id);

CREATE UNIQUE INDEX index_issue_user_mentions_on_note_id ON issue_user_mentions USING btree (note_id) WHERE (note_id IS NOT NULL);

CREATE INDEX index_issues_on_author_id ON issues USING btree (author_id);

CREATE INDEX index_issues_on_author_id_and_id_and_created_at ON issues USING btree (author_id, id, created_at);

CREATE INDEX index_issues_on_closed_by_id ON issues USING btree (closed_by_id);

CREATE INDEX index_issues_on_confidential ON issues USING btree (confidential);

CREATE INDEX index_issues_on_description_trigram ON issues USING gin (description gin_trgm_ops);

CREATE INDEX index_issues_on_duplicated_to_id ON issues USING btree (duplicated_to_id) WHERE (duplicated_to_id IS NOT NULL);

CREATE INDEX index_issues_on_incident_issue_type ON issues USING btree (issue_type) WHERE (issue_type = 1);

CREATE INDEX index_issues_on_last_edited_by_id ON issues USING btree (last_edited_by_id);

CREATE INDEX index_issues_on_milestone_id ON issues USING btree (milestone_id);

CREATE INDEX index_issues_on_moved_to_id ON issues USING btree (moved_to_id) WHERE (moved_to_id IS NOT NULL);

CREATE UNIQUE INDEX index_issues_on_project_id_and_external_key ON issues USING btree (project_id, external_key) WHERE (external_key IS NOT NULL);

CREATE UNIQUE INDEX index_issues_on_project_id_and_iid ON issues USING btree (project_id, iid);

CREATE INDEX index_issues_on_promoted_to_epic_id ON issues USING btree (promoted_to_epic_id) WHERE (promoted_to_epic_id IS NOT NULL);

CREATE INDEX index_issues_on_sprint_id ON issues USING btree (sprint_id);

CREATE INDEX index_issues_on_title_trigram ON issues USING gin (title gin_trgm_ops);

CREATE INDEX index_issues_on_updated_at ON issues USING btree (updated_at);

CREATE INDEX index_issues_on_updated_by_id ON issues USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);

CREATE INDEX index_issues_project_id_issue_type_incident ON issues USING btree (project_id) WHERE (issue_type = 1);

CREATE UNIQUE INDEX index_jira_connect_installations_on_client_key ON jira_connect_installations USING btree (client_key);

CREATE INDEX index_jira_connect_subscriptions_on_namespace_id ON jira_connect_subscriptions USING btree (namespace_id);

CREATE INDEX index_jira_imports_on_label_id ON jira_imports USING btree (label_id);

CREATE INDEX index_jira_imports_on_project_id_and_jira_project_key ON jira_imports USING btree (project_id, jira_project_key);

CREATE INDEX index_jira_imports_on_user_id ON jira_imports USING btree (user_id);

CREATE INDEX index_jira_tracker_data_on_service_id ON jira_tracker_data USING btree (service_id);

CREATE UNIQUE INDEX index_keys_on_fingerprint ON keys USING btree (fingerprint);

CREATE INDEX index_keys_on_fingerprint_sha256 ON keys USING btree (fingerprint_sha256);

CREATE INDEX index_keys_on_id_and_ldap_key_type ON keys USING btree (id) WHERE ((type)::text = 'LDAPKey'::text);

CREATE INDEX index_keys_on_last_used_at ON keys USING btree (last_used_at DESC NULLS LAST);

CREATE INDEX index_keys_on_user_id ON keys USING btree (user_id);

CREATE UNIQUE INDEX index_kubernetes_namespaces_on_cluster_project_environment_id ON clusters_kubernetes_namespaces USING btree (cluster_id, project_id, environment_id);

CREATE INDEX index_label_links_on_label_id_and_target_type ON label_links USING btree (label_id, target_type);

CREATE INDEX index_label_links_on_target_id_and_target_type ON label_links USING btree (target_id, target_type);

CREATE INDEX index_label_priorities_on_label_id ON label_priorities USING btree (label_id);

CREATE INDEX index_label_priorities_on_priority ON label_priorities USING btree (priority);

CREATE UNIQUE INDEX index_label_priorities_on_project_id_and_label_id ON label_priorities USING btree (project_id, label_id);

CREATE UNIQUE INDEX index_labels_on_group_id_and_project_id_and_title ON labels USING btree (group_id, project_id, title);

CREATE INDEX index_labels_on_group_id_and_title ON labels USING btree (group_id, title) WHERE (project_id = NULL::integer);

CREATE INDEX index_labels_on_project_id ON labels USING btree (project_id);

CREATE UNIQUE INDEX index_labels_on_project_id_and_title_unique ON labels USING btree (project_id, title) WHERE (group_id IS NULL);

CREATE INDEX index_labels_on_template ON labels USING btree (template) WHERE template;

CREATE INDEX index_labels_on_title ON labels USING btree (title);

CREATE INDEX index_labels_on_type_and_project_id ON labels USING btree (type, project_id);

CREATE UNIQUE INDEX index_lfs_file_locks_on_project_id_and_path ON lfs_file_locks USING btree (project_id, path);

CREATE INDEX index_lfs_file_locks_on_user_id ON lfs_file_locks USING btree (user_id);

CREATE INDEX index_lfs_objects_on_file_store ON lfs_objects USING btree (file_store);

CREATE UNIQUE INDEX index_lfs_objects_on_oid ON lfs_objects USING btree (oid);

CREATE INDEX index_lfs_objects_projects_on_lfs_object_id ON lfs_objects_projects USING btree (lfs_object_id);

CREATE INDEX index_lfs_objects_projects_on_project_id_and_lfs_object_id ON lfs_objects_projects USING btree (project_id, lfs_object_id);

CREATE INDEX index_list_user_preferences_on_list_id ON list_user_preferences USING btree (list_id);

CREATE INDEX index_list_user_preferences_on_user_id ON list_user_preferences USING btree (user_id);

CREATE UNIQUE INDEX index_list_user_preferences_on_user_id_and_list_id ON list_user_preferences USING btree (user_id, list_id);

CREATE UNIQUE INDEX index_lists_on_board_id_and_label_id ON lists USING btree (board_id, label_id);

CREATE INDEX index_lists_on_label_id ON lists USING btree (label_id);

CREATE INDEX index_lists_on_list_type ON lists USING btree (list_type);

CREATE INDEX index_lists_on_milestone_id ON lists USING btree (milestone_id);

CREATE INDEX index_lists_on_user_id ON lists USING btree (user_id);

CREATE INDEX index_members_on_access_level ON members USING btree (access_level);

CREATE INDEX index_members_on_expires_at ON members USING btree (expires_at);

CREATE INDEX index_members_on_invite_email ON members USING btree (invite_email);

CREATE UNIQUE INDEX index_members_on_invite_token ON members USING btree (invite_token);

CREATE INDEX index_members_on_requested_at ON members USING btree (requested_at);

CREATE INDEX index_members_on_source_id_and_source_type ON members USING btree (source_id, source_type);

CREATE INDEX index_members_on_user_id ON members USING btree (user_id);

CREATE INDEX index_members_on_user_id_created_at ON members USING btree (user_id, created_at) WHERE ((ldap = true) AND ((type)::text = 'GroupMember'::text) AND ((source_type)::text = 'Namespace'::text));

CREATE INDEX index_merge_request_assignees_on_merge_request_id ON merge_request_assignees USING btree (merge_request_id);

CREATE UNIQUE INDEX index_merge_request_assignees_on_merge_request_id_and_user_id ON merge_request_assignees USING btree (merge_request_id, user_id);

CREATE INDEX index_merge_request_assignees_on_user_id ON merge_request_assignees USING btree (user_id);

CREATE INDEX index_merge_request_blocks_on_blocked_merge_request_id ON merge_request_blocks USING btree (blocked_merge_request_id);

CREATE INDEX index_merge_request_diff_commits_on_sha ON merge_request_diff_commits USING btree (sha);

CREATE INDEX index_merge_request_diff_details_on_merge_request_diff_id ON merge_request_diff_details USING btree (merge_request_diff_id);

CREATE INDEX index_merge_request_diffs_by_id_partial ON merge_request_diffs USING btree (id) WHERE ((files_count > 0) AND ((NOT stored_externally) OR (stored_externally IS NULL)));

CREATE INDEX index_merge_request_diffs_on_external_diff_store ON merge_request_diffs USING btree (external_diff_store);

CREATE INDEX index_merge_request_diffs_on_merge_request_id_and_id ON merge_request_diffs USING btree (merge_request_id, id);

CREATE INDEX index_merge_request_metrics_on_first_deployed_to_production_at ON merge_request_metrics USING btree (first_deployed_to_production_at);

CREATE INDEX index_merge_request_metrics_on_latest_closed_at ON merge_request_metrics USING btree (latest_closed_at) WHERE (latest_closed_at IS NOT NULL);

CREATE INDEX index_merge_request_metrics_on_latest_closed_by_id ON merge_request_metrics USING btree (latest_closed_by_id);

CREATE INDEX index_merge_request_metrics_on_merge_request_id_and_merged_at ON merge_request_metrics USING btree (merge_request_id, merged_at) WHERE (merged_at IS NOT NULL);

CREATE INDEX index_merge_request_metrics_on_merged_at ON merge_request_metrics USING btree (merged_at);

CREATE INDEX index_merge_request_metrics_on_merged_by_id ON merge_request_metrics USING btree (merged_by_id);

CREATE INDEX index_merge_request_metrics_on_pipeline_id ON merge_request_metrics USING btree (pipeline_id);

CREATE INDEX index_merge_request_metrics_on_target_project_id ON merge_request_metrics USING btree (target_project_id);

CREATE INDEX index_merge_request_metrics_on_target_project_id_merged_at ON merge_request_metrics USING btree (target_project_id, merged_at);

CREATE UNIQUE INDEX index_merge_request_reviewers_on_merge_request_id_and_user_id ON merge_request_reviewers USING btree (merge_request_id, user_id);

CREATE INDEX index_merge_request_reviewers_on_user_id ON merge_request_reviewers USING btree (user_id);

CREATE UNIQUE INDEX index_merge_request_user_mentions_on_note_id ON merge_request_user_mentions USING btree (note_id) WHERE (note_id IS NOT NULL);

CREATE INDEX index_merge_requests_closing_issues_on_issue_id ON merge_requests_closing_issues USING btree (issue_id);

CREATE INDEX index_merge_requests_closing_issues_on_merge_request_id ON merge_requests_closing_issues USING btree (merge_request_id);

CREATE INDEX index_merge_requests_on_assignee_id ON merge_requests USING btree (assignee_id);

CREATE INDEX index_merge_requests_on_author_id ON merge_requests USING btree (author_id);

CREATE INDEX index_merge_requests_on_created_at ON merge_requests USING btree (created_at);

CREATE INDEX index_merge_requests_on_description_trigram ON merge_requests USING gin (description gin_trgm_ops);

CREATE INDEX index_merge_requests_on_head_pipeline_id ON merge_requests USING btree (head_pipeline_id);

CREATE INDEX index_merge_requests_on_latest_merge_request_diff_id ON merge_requests USING btree (latest_merge_request_diff_id);

CREATE INDEX index_merge_requests_on_merge_user_id ON merge_requests USING btree (merge_user_id) WHERE (merge_user_id IS NOT NULL);

CREATE INDEX index_merge_requests_on_milestone_id ON merge_requests USING btree (milestone_id);

CREATE INDEX index_merge_requests_on_source_branch ON merge_requests USING btree (source_branch);

CREATE INDEX index_merge_requests_on_source_project_id_and_source_branch ON merge_requests USING btree (source_project_id, source_branch);

CREATE INDEX index_merge_requests_on_sprint_id ON merge_requests USING btree (sprint_id);

CREATE INDEX index_merge_requests_on_target_branch ON merge_requests USING btree (target_branch);

CREATE INDEX index_merge_requests_on_target_project_id_and_created_at_and_id ON merge_requests USING btree (target_project_id, created_at, id);

CREATE UNIQUE INDEX index_merge_requests_on_target_project_id_and_iid ON merge_requests USING btree (target_project_id, iid);

CREATE INDEX index_merge_requests_on_target_project_id_and_iid_and_state_id ON merge_requests USING btree (target_project_id, iid, state_id);

CREATE INDEX index_merge_requests_on_target_project_id_and_target_branch ON merge_requests USING btree (target_project_id, target_branch) WHERE ((state_id = 1) AND (merge_when_pipeline_succeeds = true));

CREATE INDEX index_merge_requests_on_title ON merge_requests USING btree (title);

CREATE INDEX index_merge_requests_on_title_trigram ON merge_requests USING gin (title gin_trgm_ops);

CREATE INDEX index_merge_requests_on_tp_id_and_merge_commit_sha_and_id ON merge_requests USING btree (target_project_id, merge_commit_sha, id);

CREATE INDEX index_merge_requests_on_updated_by_id ON merge_requests USING btree (updated_by_id) WHERE (updated_by_id IS NOT NULL);

CREATE UNIQUE INDEX index_merge_trains_on_merge_request_id ON merge_trains USING btree (merge_request_id);

CREATE INDEX index_merge_trains_on_pipeline_id ON merge_trains USING btree (pipeline_id);

CREATE INDEX index_merge_trains_on_user_id ON merge_trains USING btree (user_id);

CREATE INDEX index_metrics_dashboard_annotations_on_cluster_id_and_3_columns ON metrics_dashboard_annotations USING btree (cluster_id, dashboard_path, starting_at, ending_at) WHERE (cluster_id IS NOT NULL);

CREATE INDEX index_metrics_dashboard_annotations_on_environment_id_and_3_col ON metrics_dashboard_annotations USING btree (environment_id, dashboard_path, starting_at, ending_at) WHERE (environment_id IS NOT NULL);

CREATE INDEX index_metrics_dashboard_annotations_on_timespan_end ON metrics_dashboard_annotations USING btree (COALESCE(ending_at, starting_at));

CREATE INDEX index_metrics_users_starred_dashboards_on_project_id ON metrics_users_starred_dashboards USING btree (project_id);

CREATE INDEX index_milestone_releases_on_release_id ON milestone_releases USING btree (release_id);

CREATE INDEX index_milestones_on_description_trigram ON milestones USING gin (description gin_trgm_ops);

CREATE INDEX index_milestones_on_due_date ON milestones USING btree (due_date);

CREATE INDEX index_milestones_on_group_id ON milestones USING btree (group_id);

CREATE UNIQUE INDEX index_milestones_on_project_id_and_iid ON milestones USING btree (project_id, iid);

CREATE INDEX index_milestones_on_title ON milestones USING btree (title);

CREATE INDEX index_milestones_on_title_trigram ON milestones USING gin (title gin_trgm_ops);

CREATE INDEX index_mirror_data_on_next_execution_and_retry_count ON project_mirror_data USING btree (next_execution_timestamp, retry_count);

CREATE UNIQUE INDEX index_mr_blocks_on_blocking_and_blocked_mr_ids ON merge_request_blocks USING btree (blocking_merge_request_id, blocked_merge_request_id);

CREATE UNIQUE INDEX index_mr_context_commits_on_merge_request_id_and_sha ON merge_request_context_commits USING btree (merge_request_id, sha);

CREATE UNIQUE INDEX index_namespace_aggregation_schedules_on_namespace_id ON namespace_aggregation_schedules USING btree (namespace_id);

CREATE UNIQUE INDEX index_namespace_root_storage_statistics_on_namespace_id ON namespace_root_storage_statistics USING btree (namespace_id);

CREATE UNIQUE INDEX index_namespace_statistics_on_namespace_id ON namespace_statistics USING btree (namespace_id);

CREATE INDEX index_namespaces_on_created_at ON namespaces USING btree (created_at);

CREATE INDEX index_namespaces_on_custom_project_templates_group_id_and_type ON namespaces USING btree (custom_project_templates_group_id, type) WHERE (custom_project_templates_group_id IS NOT NULL);

CREATE INDEX index_namespaces_on_file_template_project_id ON namespaces USING btree (file_template_project_id);

CREATE INDEX index_namespaces_on_ldap_sync_last_successful_update_at ON namespaces USING btree (ldap_sync_last_successful_update_at);

CREATE INDEX index_namespaces_on_ldap_sync_last_update_at ON namespaces USING btree (ldap_sync_last_update_at);

CREATE UNIQUE INDEX index_namespaces_on_name_and_parent_id ON namespaces USING btree (name, parent_id);

CREATE INDEX index_namespaces_on_name_trigram ON namespaces USING gin (name gin_trgm_ops);

CREATE INDEX index_namespaces_on_owner_id ON namespaces USING btree (owner_id);

CREATE UNIQUE INDEX index_namespaces_on_parent_id_and_id ON namespaces USING btree (parent_id, id);

CREATE INDEX index_namespaces_on_path ON namespaces USING btree (path);

CREATE INDEX index_namespaces_on_path_trigram ON namespaces USING gin (path gin_trgm_ops);

CREATE UNIQUE INDEX index_namespaces_on_push_rule_id ON namespaces USING btree (push_rule_id);

CREATE INDEX index_namespaces_on_require_two_factor_authentication ON namespaces USING btree (require_two_factor_authentication);

CREATE UNIQUE INDEX index_namespaces_on_runners_token ON namespaces USING btree (runners_token);

CREATE UNIQUE INDEX index_namespaces_on_runners_token_encrypted ON namespaces USING btree (runners_token_encrypted);

CREATE INDEX index_namespaces_on_shared_and_extra_runners_minutes_limit ON namespaces USING btree (shared_runners_minutes_limit, extra_shared_runners_minutes_limit);

CREATE INDEX index_namespaces_on_type_and_id_partial ON namespaces USING btree (type, id) WHERE (type IS NOT NULL);

CREATE INDEX index_non_requested_project_members_on_source_id_and_type ON members USING btree (source_id, source_type) WHERE ((requested_at IS NULL) AND ((type)::text = 'ProjectMember'::text));

CREATE UNIQUE INDEX index_note_diff_files_on_diff_note_id ON note_diff_files USING btree (diff_note_id);

CREATE INDEX index_notes_on_author_id_and_created_at_and_id ON notes USING btree (author_id, created_at, id);

CREATE INDEX index_notes_on_commit_id ON notes USING btree (commit_id);

CREATE INDEX index_notes_on_created_at ON notes USING btree (created_at);

CREATE INDEX index_notes_on_discussion_id ON notes USING btree (discussion_id);

CREATE INDEX index_notes_on_line_code ON notes USING btree (line_code);

CREATE INDEX index_notes_on_note_trigram ON notes USING gin (note gin_trgm_ops);

CREATE INDEX index_notes_on_noteable_id_and_noteable_type ON notes USING btree (noteable_id, noteable_type);

CREATE INDEX index_notes_on_project_id_and_id_and_system_false ON notes USING btree (project_id, id) WHERE (NOT system);

CREATE INDEX index_notes_on_project_id_and_noteable_type ON notes USING btree (project_id, noteable_type);

CREATE INDEX index_notes_on_review_id ON notes USING btree (review_id);

CREATE INDEX index_notification_settings_on_source_id_and_source_type ON notification_settings USING btree (source_id, source_type);

CREATE INDEX index_notification_settings_on_user_id ON notification_settings USING btree (user_id);

CREATE UNIQUE INDEX index_notifications_on_user_id_and_source_id_and_source_type ON notification_settings USING btree (user_id, source_id, source_type);

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);

CREATE INDEX index_oauth_access_tokens_on_application_id ON oauth_access_tokens USING btree (application_id);

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON oauth_applications USING btree (owner_id, owner_type);

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);

CREATE INDEX index_oauth_openid_requests_on_access_grant_id ON oauth_openid_requests USING btree (access_grant_id);

CREATE UNIQUE INDEX index_on_deploy_keys_id_and_type_and_public ON keys USING btree (id, type) WHERE (public = true);

CREATE INDEX index_on_id_partial_with_legacy_storage ON projects USING btree (id) WHERE ((storage_version < 2) OR (storage_version IS NULL));

CREATE INDEX index_on_identities_lower_extern_uid_and_provider ON identities USING btree (lower((extern_uid)::text), provider);

CREATE UNIQUE INDEX index_on_instance_statistics_recorded_at_and_identifier ON analytics_instance_statistics_measurements USING btree (identifier, recorded_at);

CREATE INDEX index_on_label_links_all_columns ON label_links USING btree (target_id, label_id, target_type);

CREATE INDEX index_on_users_name_lower ON users USING btree (lower((name)::text));

CREATE INDEX index_open_project_tracker_data_on_service_id ON open_project_tracker_data USING btree (service_id);

CREATE INDEX index_operations_feature_flags_issues_on_issue_id ON operations_feature_flags_issues USING btree (issue_id);

CREATE UNIQUE INDEX index_operations_feature_flags_on_project_id_and_iid ON operations_feature_flags USING btree (project_id, iid);

CREATE UNIQUE INDEX index_operations_feature_flags_on_project_id_and_name ON operations_feature_flags USING btree (project_id, name);

CREATE UNIQUE INDEX index_operations_scopes_on_strategy_id_and_environment_scope ON operations_scopes USING btree (strategy_id, environment_scope);

CREATE INDEX index_operations_strategies_on_feature_flag_id ON operations_strategies USING btree (feature_flag_id);

CREATE INDEX index_operations_strategies_user_lists_on_user_list_id ON operations_strategies_user_lists USING btree (user_list_id);

CREATE UNIQUE INDEX index_operations_user_lists_on_project_id_and_iid ON operations_user_lists USING btree (project_id, iid);

CREATE UNIQUE INDEX index_operations_user_lists_on_project_id_and_name ON operations_user_lists USING btree (project_id, name);

CREATE UNIQUE INDEX index_ops_feature_flags_issues_on_feature_flag_id_and_issue_id ON operations_feature_flags_issues USING btree (feature_flag_id, issue_id);

CREATE UNIQUE INDEX index_ops_strategies_user_lists_on_strategy_id_and_user_list_id ON operations_strategies_user_lists USING btree (strategy_id, user_list_id);

CREATE UNIQUE INDEX index_packages_build_infos_on_package_id ON packages_build_infos USING btree (package_id);

CREATE INDEX index_packages_build_infos_on_pipeline_id ON packages_build_infos USING btree (pipeline_id);

CREATE UNIQUE INDEX index_packages_composer_metadata_on_package_id_and_target_sha ON packages_composer_metadata USING btree (package_id, target_sha);

CREATE UNIQUE INDEX index_packages_conan_file_metadata_on_package_file_id ON packages_conan_file_metadata USING btree (package_file_id);

CREATE UNIQUE INDEX index_packages_conan_metadata_on_package_id_username_channel ON packages_conan_metadata USING btree (package_id, package_username, package_channel);

CREATE UNIQUE INDEX index_packages_dependencies_on_name_and_version_pattern ON packages_dependencies USING btree (name, version_pattern);

CREATE INDEX index_packages_dependency_links_on_dependency_id ON packages_dependency_links USING btree (dependency_id);

CREATE INDEX index_packages_events_on_package_id ON packages_events USING btree (package_id);

CREATE INDEX index_packages_maven_metadata_on_package_id_and_path ON packages_maven_metadata USING btree (package_id, path);

CREATE INDEX index_packages_nuget_dl_metadata_on_dependency_link_id ON packages_nuget_dependency_link_metadata USING btree (dependency_link_id);

CREATE UNIQUE INDEX index_packages_on_project_id_name_version_unique_when_generic ON packages_packages USING btree (project_id, name, version) WHERE (package_type = 7);

CREATE INDEX index_packages_package_files_on_file_store ON packages_package_files USING btree (file_store);

CREATE INDEX index_packages_package_files_on_package_id_and_file_name ON packages_package_files USING btree (package_id, file_name);

CREATE INDEX index_packages_packages_on_creator_id ON packages_packages USING btree (creator_id);

CREATE INDEX index_packages_packages_on_id_and_created_at ON packages_packages USING btree (id, created_at);

CREATE INDEX index_packages_packages_on_name_trigram ON packages_packages USING gin (name gin_trgm_ops);

CREATE INDEX index_packages_packages_on_project_id_and_created_at ON packages_packages USING btree (project_id, created_at);

CREATE INDEX index_packages_packages_on_project_id_and_package_type ON packages_packages USING btree (project_id, package_type);

CREATE INDEX index_packages_packages_on_project_id_and_version ON packages_packages USING btree (project_id, version);

CREATE INDEX index_packages_project_id_name_partial_for_nuget ON packages_packages USING btree (project_id, name) WHERE (((name)::text <> 'NuGet.Temporary.Package'::text) AND (version IS NOT NULL) AND (package_type = 4));

CREATE INDEX index_packages_tags_on_package_id ON packages_tags USING btree (package_id);

CREATE INDEX index_packages_tags_on_package_id_and_updated_at ON packages_tags USING btree (package_id, updated_at DESC);

CREATE INDEX index_pages_deployments_on_ci_build_id ON pages_deployments USING btree (ci_build_id);

CREATE INDEX index_pages_deployments_on_project_id ON pages_deployments USING btree (project_id);

CREATE INDEX index_pages_domain_acme_orders_on_challenge_token ON pages_domain_acme_orders USING btree (challenge_token);

CREATE INDEX index_pages_domain_acme_orders_on_pages_domain_id ON pages_domain_acme_orders USING btree (pages_domain_id);

CREATE INDEX index_pages_domains_need_auto_ssl_renewal_user_provided ON pages_domains USING btree (id) WHERE ((auto_ssl_enabled = true) AND (auto_ssl_failed = false) AND (certificate_source = 0));

CREATE INDEX index_pages_domains_need_auto_ssl_renewal_valid_not_after ON pages_domains USING btree (certificate_valid_not_after) WHERE ((auto_ssl_enabled = true) AND (auto_ssl_failed = false));

CREATE UNIQUE INDEX index_pages_domains_on_domain_and_wildcard ON pages_domains USING btree (domain, wildcard);

CREATE INDEX index_pages_domains_on_domain_lowercase ON pages_domains USING btree (lower((domain)::text));

CREATE INDEX index_pages_domains_on_project_id ON pages_domains USING btree (project_id);

CREATE INDEX index_pages_domains_on_project_id_and_enabled_until ON pages_domains USING btree (project_id, enabled_until);

CREATE INDEX index_pages_domains_on_remove_at ON pages_domains USING btree (remove_at);

CREATE INDEX index_pages_domains_on_scope ON pages_domains USING btree (scope);

CREATE INDEX index_pages_domains_on_usage ON pages_domains USING btree (usage);

CREATE INDEX index_pages_domains_on_verified_at ON pages_domains USING btree (verified_at);

CREATE INDEX index_pages_domains_on_verified_at_and_enabled_until ON pages_domains USING btree (verified_at, enabled_until);

CREATE INDEX index_pages_domains_on_wildcard ON pages_domains USING btree (wildcard);

CREATE UNIQUE INDEX index_partial_am_alerts_on_project_id_and_fingerprint ON alert_management_alerts USING btree (project_id, fingerprint) WHERE (status <> 2);

CREATE INDEX index_partial_ci_builds_on_user_id_name_parser_features ON ci_builds USING btree (user_id, name) WHERE (((type)::text = 'Ci::Build'::text) AND ((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('license_scanning'::character varying)::text, ('sast'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('secret_detection'::character varying)::text])));

CREATE UNIQUE INDEX index_partitioned_foreign_keys_unique_index ON partitioned_foreign_keys USING btree (to_table, from_table, from_column);

CREATE INDEX index_pat_on_user_id_and_expires_at ON personal_access_tokens USING btree (user_id, expires_at);

CREATE INDEX index_path_locks_on_path ON path_locks USING btree (path);

CREATE INDEX index_path_locks_on_project_id ON path_locks USING btree (project_id);

CREATE INDEX index_path_locks_on_user_id ON path_locks USING btree (user_id);

CREATE UNIQUE INDEX index_personal_access_tokens_on_token_digest ON personal_access_tokens USING btree (token_digest);

CREATE INDEX index_personal_access_tokens_on_user_id ON personal_access_tokens USING btree (user_id);

CREATE UNIQUE INDEX index_plan_limits_on_plan_id ON plan_limits USING btree (plan_id);

CREATE UNIQUE INDEX index_plans_on_name ON plans USING btree (name);

CREATE UNIQUE INDEX index_pool_repositories_on_disk_path ON pool_repositories USING btree (disk_path);

CREATE INDEX index_pool_repositories_on_shard_id ON pool_repositories USING btree (shard_id);

CREATE UNIQUE INDEX index_pool_repositories_on_source_project_id_and_shard_id ON pool_repositories USING btree (source_project_id, shard_id);

CREATE INDEX index_postgres_reindex_actions_on_index_identifier ON postgres_reindex_actions USING btree (index_identifier);

CREATE UNIQUE INDEX index_programming_languages_on_name ON programming_languages USING btree (name);

CREATE INDEX index_project_access_tokens_on_project_id ON project_access_tokens USING btree (project_id);

CREATE UNIQUE INDEX index_project_aliases_on_name ON project_aliases USING btree (name);

CREATE INDEX index_project_aliases_on_project_id ON project_aliases USING btree (project_id);

CREATE INDEX index_project_authorizations_on_project_id ON project_authorizations USING btree (project_id);

CREATE UNIQUE INDEX index_project_auto_devops_on_project_id ON project_auto_devops USING btree (project_id);

CREATE UNIQUE INDEX index_project_ci_cd_settings_on_project_id ON project_ci_cd_settings USING btree (project_id);

CREATE INDEX index_project_compliance_framework_settings_on_framework_id ON project_compliance_framework_settings USING btree (framework_id);

CREATE INDEX index_project_compliance_framework_settings_on_project_id ON project_compliance_framework_settings USING btree (project_id);

CREATE INDEX index_project_custom_attributes_on_key_and_value ON project_custom_attributes USING btree (key, value);

CREATE UNIQUE INDEX index_project_custom_attributes_on_project_id_and_key ON project_custom_attributes USING btree (project_id, key);

CREATE UNIQUE INDEX index_project_daily_statistics_on_project_id_and_date ON project_daily_statistics USING btree (project_id, date DESC);

CREATE INDEX index_project_deploy_tokens_on_deploy_token_id ON project_deploy_tokens USING btree (deploy_token_id);

CREATE UNIQUE INDEX index_project_deploy_tokens_on_project_id_and_deploy_token_id ON project_deploy_tokens USING btree (project_id, deploy_token_id);

CREATE UNIQUE INDEX index_project_export_jobs_on_jid ON project_export_jobs USING btree (jid);

CREATE INDEX index_project_export_jobs_on_project_id_and_jid ON project_export_jobs USING btree (project_id, jid);

CREATE INDEX index_project_export_jobs_on_project_id_and_status ON project_export_jobs USING btree (project_id, status);

CREATE INDEX index_project_export_jobs_on_status ON project_export_jobs USING btree (status);

CREATE INDEX index_project_feature_usages_on_project_id ON project_feature_usages USING btree (project_id);

CREATE UNIQUE INDEX index_project_features_on_project_id ON project_features USING btree (project_id);

CREATE INDEX index_project_features_on_project_id_bal_20 ON project_features USING btree (project_id) WHERE (builds_access_level = 20);

CREATE INDEX index_project_features_on_project_id_ral_20 ON project_features USING btree (project_id) WHERE (repository_access_level = 20);

CREATE INDEX index_project_group_links_on_group_id ON project_group_links USING btree (group_id);

CREATE INDEX index_project_group_links_on_project_id ON project_group_links USING btree (project_id);

CREATE INDEX index_project_import_data_on_project_id ON project_import_data USING btree (project_id);

CREATE INDEX index_project_mirror_data_on_last_successful_update_at ON project_mirror_data USING btree (last_successful_update_at);

CREATE INDEX index_project_mirror_data_on_last_update_at_and_retry_count ON project_mirror_data USING btree (last_update_at, retry_count);

CREATE UNIQUE INDEX index_project_mirror_data_on_project_id ON project_mirror_data USING btree (project_id);

CREATE INDEX index_project_mirror_data_on_status ON project_mirror_data USING btree (status);

CREATE INDEX index_project_pages_metadata_on_artifacts_archive_id ON project_pages_metadata USING btree (artifacts_archive_id);

CREATE INDEX index_project_pages_metadata_on_pages_deployment_id ON project_pages_metadata USING btree (pages_deployment_id);

CREATE INDEX index_project_pages_metadata_on_project_id_and_deployed_is_true ON project_pages_metadata USING btree (project_id) WHERE (deployed = true);

CREATE UNIQUE INDEX index_project_repositories_on_disk_path ON project_repositories USING btree (disk_path);

CREATE UNIQUE INDEX index_project_repositories_on_project_id ON project_repositories USING btree (project_id);

CREATE INDEX index_project_repositories_on_shard_id ON project_repositories USING btree (shard_id);

CREATE UNIQUE INDEX index_project_repository_states_on_project_id ON project_repository_states USING btree (project_id);

CREATE INDEX index_project_repository_storage_moves_on_project_id ON project_repository_storage_moves USING btree (project_id);

CREATE UNIQUE INDEX index_project_settings_on_push_rule_id ON project_settings USING btree (push_rule_id);

CREATE INDEX index_project_statistics_on_namespace_id ON project_statistics USING btree (namespace_id);

CREATE UNIQUE INDEX index_project_statistics_on_project_id ON project_statistics USING btree (project_id);

CREATE INDEX index_project_statistics_on_repository_size_and_project_id ON project_statistics USING btree (repository_size, project_id);

CREATE INDEX index_project_statistics_on_storage_size_and_project_id ON project_statistics USING btree (storage_size, project_id);

CREATE INDEX index_project_statistics_on_wiki_size_and_project_id ON project_statistics USING btree (wiki_size, project_id);

CREATE UNIQUE INDEX index_project_tracing_settings_on_project_id ON project_tracing_settings USING btree (project_id);

CREATE INDEX index_projects_aimed_for_deletion ON projects USING btree (marked_for_deletion_at) WHERE ((marked_for_deletion_at IS NOT NULL) AND (pending_delete = false));

CREATE INDEX index_projects_api_created_at_id_desc ON projects USING btree (created_at, id DESC);

CREATE INDEX index_projects_api_created_at_id_for_archived ON projects USING btree (created_at, id) WHERE ((archived = true) AND (pending_delete = false));

CREATE INDEX index_projects_api_created_at_id_for_archived_vis20 ON projects USING btree (created_at, id) WHERE ((archived = true) AND (visibility_level = 20) AND (pending_delete = false));

CREATE INDEX index_projects_api_created_at_id_for_vis10 ON projects USING btree (created_at, id) WHERE ((visibility_level = 10) AND (pending_delete = false));

CREATE INDEX index_projects_api_last_activity_at_id_desc ON projects USING btree (last_activity_at, id DESC);

CREATE INDEX index_projects_api_name_id_desc ON projects USING btree (name, id DESC);

CREATE INDEX index_projects_api_path_id_desc ON projects USING btree (path, id DESC);

CREATE INDEX index_projects_api_updated_at_id_desc ON projects USING btree (updated_at, id DESC);

CREATE INDEX index_projects_api_vis20_created_at ON projects USING btree (created_at, id) WHERE (visibility_level = 20);

CREATE INDEX index_projects_api_vis20_last_activity_at ON projects USING btree (last_activity_at, id) WHERE (visibility_level = 20);

CREATE INDEX index_projects_api_vis20_name ON projects USING btree (name, id) WHERE (visibility_level = 20);

CREATE INDEX index_projects_api_vis20_path ON projects USING btree (path, id) WHERE (visibility_level = 20);

CREATE INDEX index_projects_api_vis20_updated_at ON projects USING btree (updated_at, id) WHERE (visibility_level = 20);

CREATE INDEX index_projects_on_created_at_and_id ON projects USING btree (created_at, id);

CREATE INDEX index_projects_on_creator_id_and_created_at_and_id ON projects USING btree (creator_id, created_at, id);

CREATE INDEX index_projects_on_creator_id_and_id ON projects USING btree (creator_id, id);

CREATE INDEX index_projects_on_description_trigram ON projects USING gin (description gin_trgm_ops);

CREATE INDEX index_projects_on_id_and_archived_and_pending_delete ON projects USING btree (id) WHERE ((archived = false) AND (pending_delete = false));

CREATE UNIQUE INDEX index_projects_on_id_partial_for_visibility ON projects USING btree (id) WHERE (visibility_level = ANY (ARRAY[10, 20]));

CREATE INDEX index_projects_on_id_service_desk_enabled ON projects USING btree (id) WHERE (service_desk_enabled = true);

CREATE INDEX index_projects_on_last_activity_at_and_id ON projects USING btree (last_activity_at, id);

CREATE INDEX index_projects_on_last_repository_check_at ON projects USING btree (last_repository_check_at) WHERE (last_repository_check_at IS NOT NULL);

CREATE INDEX index_projects_on_last_repository_check_failed ON projects USING btree (last_repository_check_failed);

CREATE INDEX index_projects_on_last_repository_updated_at ON projects USING btree (last_repository_updated_at);

CREATE INDEX index_projects_on_lower_name ON projects USING btree (lower((name)::text));

CREATE INDEX index_projects_on_marked_for_deletion_by_user_id ON projects USING btree (marked_for_deletion_by_user_id) WHERE (marked_for_deletion_by_user_id IS NOT NULL);

CREATE INDEX index_projects_on_mirror_creator_id_created_at ON projects USING btree (creator_id, created_at) WHERE ((mirror = true) AND (mirror_trigger_builds = true));

CREATE INDEX index_projects_on_mirror_id_where_mirror_and_trigger_builds ON projects USING btree (id) WHERE ((mirror = true) AND (mirror_trigger_builds = true));

CREATE INDEX index_projects_on_mirror_last_successful_update_at ON projects USING btree (mirror_last_successful_update_at);

CREATE INDEX index_projects_on_mirror_user_id ON projects USING btree (mirror_user_id);

CREATE INDEX index_projects_on_name_and_id ON projects USING btree (name, id);

CREATE INDEX index_projects_on_name_trigram ON projects USING gin (name gin_trgm_ops);

CREATE INDEX index_projects_on_namespace_id_and_id ON projects USING btree (namespace_id, id);

CREATE INDEX index_projects_on_path_and_id ON projects USING btree (path, id);

CREATE INDEX index_projects_on_path_trigram ON projects USING gin (path gin_trgm_ops);

CREATE INDEX index_projects_on_pending_delete ON projects USING btree (pending_delete);

CREATE INDEX index_projects_on_pool_repository_id ON projects USING btree (pool_repository_id) WHERE (pool_repository_id IS NOT NULL);

CREATE INDEX index_projects_on_repository_storage ON projects USING btree (repository_storage);

CREATE INDEX index_projects_on_runners_token ON projects USING btree (runners_token);

CREATE INDEX index_projects_on_runners_token_encrypted ON projects USING btree (runners_token_encrypted);

CREATE INDEX index_projects_on_star_count ON projects USING btree (star_count);

CREATE INDEX index_projects_on_updated_at_and_id ON projects USING btree (updated_at, id);

CREATE UNIQUE INDEX index_prometheus_alert_event_scoped_payload_key ON prometheus_alert_events USING btree (prometheus_alert_id, payload_key);

CREATE INDEX index_prometheus_alert_events_on_project_id_and_status ON prometheus_alert_events USING btree (project_id, status);

CREATE UNIQUE INDEX index_prometheus_alerts_metric_environment ON prometheus_alerts USING btree (project_id, prometheus_metric_id, environment_id);

CREATE INDEX index_prometheus_alerts_on_environment_id ON prometheus_alerts USING btree (environment_id);

CREATE INDEX index_prometheus_alerts_on_prometheus_metric_id ON prometheus_alerts USING btree (prometheus_metric_id);

CREATE INDEX index_prometheus_metrics_on_common ON prometheus_metrics USING btree (common);

CREATE INDEX index_prometheus_metrics_on_group ON prometheus_metrics USING btree ("group");

CREATE UNIQUE INDEX index_prometheus_metrics_on_identifier_and_null_project ON prometheus_metrics USING btree (identifier) WHERE (project_id IS NULL);

CREATE UNIQUE INDEX index_prometheus_metrics_on_identifier_and_project_id ON prometheus_metrics USING btree (identifier, project_id);

CREATE INDEX index_prometheus_metrics_on_project_id ON prometheus_metrics USING btree (project_id);

CREATE INDEX index_protected_branch_merge_access ON protected_branch_merge_access_levels USING btree (protected_branch_id);

CREATE INDEX index_protected_branch_merge_access_levels_on_group_id ON protected_branch_merge_access_levels USING btree (group_id);

CREATE INDEX index_protected_branch_merge_access_levels_on_user_id ON protected_branch_merge_access_levels USING btree (user_id);

CREATE INDEX index_protected_branch_push_access ON protected_branch_push_access_levels USING btree (protected_branch_id);

CREATE INDEX index_protected_branch_push_access_levels_on_group_id ON protected_branch_push_access_levels USING btree (group_id);

CREATE INDEX index_protected_branch_push_access_levels_on_user_id ON protected_branch_push_access_levels USING btree (user_id);

CREATE INDEX index_protected_branch_unprotect_access ON protected_branch_unprotect_access_levels USING btree (protected_branch_id);

CREATE INDEX index_protected_branch_unprotect_access_levels_on_group_id ON protected_branch_unprotect_access_levels USING btree (group_id);

CREATE INDEX index_protected_branch_unprotect_access_levels_on_user_id ON protected_branch_unprotect_access_levels USING btree (user_id);

CREATE INDEX index_protected_branches_on_project_id ON protected_branches USING btree (project_id);

CREATE INDEX index_protected_environment_deploy_access ON protected_environment_deploy_access_levels USING btree (protected_environment_id);

CREATE INDEX index_protected_environment_deploy_access_levels_on_group_id ON protected_environment_deploy_access_levels USING btree (group_id);

CREATE INDEX index_protected_environment_deploy_access_levels_on_user_id ON protected_environment_deploy_access_levels USING btree (user_id);

CREATE INDEX index_protected_environments_on_project_id ON protected_environments USING btree (project_id);

CREATE UNIQUE INDEX index_protected_environments_on_project_id_and_name ON protected_environments USING btree (project_id, name);

CREATE INDEX index_protected_tag_create_access ON protected_tag_create_access_levels USING btree (protected_tag_id);

CREATE INDEX index_protected_tag_create_access_levels_on_group_id ON protected_tag_create_access_levels USING btree (group_id);

CREATE INDEX index_protected_tag_create_access_levels_on_user_id ON protected_tag_create_access_levels USING btree (user_id);

CREATE INDEX index_protected_tags_on_project_id ON protected_tags USING btree (project_id);

CREATE UNIQUE INDEX index_protected_tags_on_project_id_and_name ON protected_tags USING btree (project_id, name);

CREATE INDEX index_push_rules_on_is_sample ON push_rules USING btree (is_sample) WHERE is_sample;

CREATE INDEX index_push_rules_on_project_id ON push_rules USING btree (project_id);

CREATE UNIQUE INDEX index_raw_usage_data_on_recorded_at ON raw_usage_data USING btree (recorded_at);

CREATE UNIQUE INDEX index_redirect_routes_on_path ON redirect_routes USING btree (path);

CREATE UNIQUE INDEX index_redirect_routes_on_path_unique_text_pattern_ops ON redirect_routes USING btree (lower((path)::text) varchar_pattern_ops);

CREATE INDEX index_redirect_routes_on_source_type_and_source_id ON redirect_routes USING btree (source_type, source_id);

CREATE UNIQUE INDEX index_release_links_on_release_id_and_name ON release_links USING btree (release_id, name);

CREATE UNIQUE INDEX index_release_links_on_release_id_and_url ON release_links USING btree (release_id, url);

CREATE INDEX index_releases_on_author_id ON releases USING btree (author_id);

CREATE INDEX index_releases_on_project_id_and_tag ON releases USING btree (project_id, tag);

CREATE INDEX index_remote_mirrors_on_last_successful_update_at ON remote_mirrors USING btree (last_successful_update_at);

CREATE INDEX index_remote_mirrors_on_project_id ON remote_mirrors USING btree (project_id);

CREATE INDEX index_required_code_owners_sections_on_protected_branch_id ON required_code_owners_sections USING btree (protected_branch_id);

CREATE INDEX index_requirements_management_test_reports_on_author_id ON requirements_management_test_reports USING btree (author_id);

CREATE INDEX index_requirements_management_test_reports_on_build_id ON requirements_management_test_reports USING btree (build_id);

CREATE INDEX index_requirements_management_test_reports_on_requirement_id ON requirements_management_test_reports USING btree (requirement_id);

CREATE INDEX index_requirements_on_author_id ON requirements USING btree (author_id);

CREATE INDEX index_requirements_on_created_at ON requirements USING btree (created_at);

CREATE INDEX index_requirements_on_project_id ON requirements USING btree (project_id);

CREATE UNIQUE INDEX index_requirements_on_project_id_and_iid ON requirements USING btree (project_id, iid) WHERE (project_id IS NOT NULL);

CREATE INDEX index_requirements_on_state ON requirements USING btree (state);

CREATE INDEX index_requirements_on_title_trigram ON requirements USING gin (title gin_trgm_ops);

CREATE INDEX index_requirements_on_updated_at ON requirements USING btree (updated_at);

CREATE INDEX index_resource_iteration_events_on_issue_id ON resource_iteration_events USING btree (issue_id);

CREATE INDEX index_resource_iteration_events_on_iteration_id ON resource_iteration_events USING btree (iteration_id);

CREATE INDEX index_resource_iteration_events_on_iteration_id_and_add_action ON resource_iteration_events USING btree (iteration_id) WHERE (action = 1);

CREATE INDEX index_resource_iteration_events_on_merge_request_id ON resource_iteration_events USING btree (merge_request_id);

CREATE INDEX index_resource_iteration_events_on_user_id ON resource_iteration_events USING btree (user_id);

CREATE INDEX index_resource_label_events_issue_id_label_id_action ON resource_label_events USING btree (issue_id, label_id, action);

CREATE INDEX index_resource_label_events_on_epic_id ON resource_label_events USING btree (epic_id);

CREATE INDEX index_resource_label_events_on_label_id_and_action ON resource_label_events USING btree (label_id, action);

CREATE INDEX index_resource_label_events_on_merge_request_id_label_id_action ON resource_label_events USING btree (merge_request_id, label_id, action);

CREATE INDEX index_resource_label_events_on_user_id ON resource_label_events USING btree (user_id);

CREATE INDEX index_resource_milestone_events_created_at ON resource_milestone_events USING btree (created_at);

CREATE INDEX index_resource_milestone_events_on_issue_id ON resource_milestone_events USING btree (issue_id);

CREATE INDEX index_resource_milestone_events_on_merge_request_id ON resource_milestone_events USING btree (merge_request_id);

CREATE INDEX index_resource_milestone_events_on_milestone_id ON resource_milestone_events USING btree (milestone_id);

CREATE INDEX index_resource_milestone_events_on_milestone_id_and_add_action ON resource_milestone_events USING btree (milestone_id) WHERE (action = 1);

CREATE INDEX index_resource_milestone_events_on_user_id ON resource_milestone_events USING btree (user_id);

CREATE INDEX index_resource_state_events_on_epic_id ON resource_state_events USING btree (epic_id);

CREATE INDEX index_resource_state_events_on_issue_id_and_created_at ON resource_state_events USING btree (issue_id, created_at);

CREATE INDEX index_resource_state_events_on_merge_request_id ON resource_state_events USING btree (merge_request_id);

CREATE INDEX index_resource_state_events_on_source_merge_request_id ON resource_state_events USING btree (source_merge_request_id);

CREATE INDEX index_resource_state_events_on_user_id ON resource_state_events USING btree (user_id);

CREATE INDEX index_resource_weight_events_on_issue_id_and_created_at ON resource_weight_events USING btree (issue_id, created_at);

CREATE INDEX index_resource_weight_events_on_issue_id_and_weight ON resource_weight_events USING btree (issue_id, weight);

CREATE INDEX index_resource_weight_events_on_user_id ON resource_weight_events USING btree (user_id);

CREATE INDEX index_reviews_on_author_id ON reviews USING btree (author_id);

CREATE INDEX index_reviews_on_merge_request_id ON reviews USING btree (merge_request_id);

CREATE INDEX index_reviews_on_project_id ON reviews USING btree (project_id);

CREATE UNIQUE INDEX index_routes_on_path ON routes USING btree (path);

CREATE INDEX index_routes_on_path_text_pattern_ops ON routes USING btree (path varchar_pattern_ops);

CREATE INDEX index_routes_on_path_trigram ON routes USING gin (path gin_trgm_ops);

CREATE UNIQUE INDEX index_routes_on_source_type_and_source_id ON routes USING btree (source_type, source_id);

CREATE UNIQUE INDEX index_saml_group_links_on_group_id_and_saml_group_name ON saml_group_links USING btree (group_id, saml_group_name);

CREATE INDEX index_saml_providers_on_group_id ON saml_providers USING btree (group_id);

CREATE INDEX index_scim_identities_on_group_id ON scim_identities USING btree (group_id);

CREATE UNIQUE INDEX index_scim_identities_on_lower_extern_uid_and_group_id ON scim_identities USING btree (lower((extern_uid)::text), group_id);

CREATE UNIQUE INDEX index_scim_identities_on_user_id_and_group_id ON scim_identities USING btree (user_id, group_id);

CREATE UNIQUE INDEX index_scim_oauth_access_tokens_on_group_id_and_token_encrypted ON scim_oauth_access_tokens USING btree (group_id, token_encrypted);

CREATE INDEX index_secure_ci_builds_on_user_id_created_at_parser_features ON ci_builds USING btree (user_id, created_at) WHERE (((type)::text = 'Ci::Build'::text) AND ((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('license_scanning'::character varying)::text, ('sast'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('secret_detection'::character varying)::text])));

CREATE INDEX index_security_ci_builds_on_name_and_id_parser_features ON ci_builds USING btree (name, id) WHERE (((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('sast'::character varying)::text, ('secret_detection'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('license_scanning'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text));

CREATE INDEX index_security_findings_on_confidence ON security_findings USING btree (confidence);

CREATE INDEX index_security_findings_on_project_fingerprint ON security_findings USING btree (project_fingerprint);

CREATE INDEX index_security_findings_on_scan_id_and_deduplicated ON security_findings USING btree (scan_id, deduplicated);

CREATE UNIQUE INDEX index_security_findings_on_scan_id_and_position ON security_findings USING btree (scan_id, "position");

CREATE INDEX index_security_findings_on_scanner_id ON security_findings USING btree (scanner_id);

CREATE INDEX index_security_findings_on_severity ON security_findings USING btree (severity);

CREATE INDEX index_self_managed_prometheus_alert_events_on_environment_id ON self_managed_prometheus_alert_events USING btree (environment_id);

CREATE INDEX index_sent_notifications_on_noteable_type_noteable_id ON sent_notifications USING btree (noteable_id) WHERE ((noteable_type)::text = 'Issue'::text);

CREATE UNIQUE INDEX index_sent_notifications_on_reply_key ON sent_notifications USING btree (reply_key);

CREATE UNIQUE INDEX index_sentry_issues_on_issue_id ON sentry_issues USING btree (issue_id);

CREATE INDEX index_sentry_issues_on_sentry_issue_identifier ON sentry_issues USING btree (sentry_issue_identifier);

CREATE INDEX index_serverless_domain_cluster_on_creator_id ON serverless_domain_cluster USING btree (creator_id);

CREATE INDEX index_serverless_domain_cluster_on_pages_domain_id ON serverless_domain_cluster USING btree (pages_domain_id);

CREATE INDEX index_service_desk_enabled_projects_on_id_creator_id_created_at ON projects USING btree (id, creator_id, created_at) WHERE (service_desk_enabled = true);

CREATE INDEX index_services_on_inherit_from_id ON services USING btree (inherit_from_id);

CREATE INDEX index_services_on_project_id_and_type ON services USING btree (project_id, type);

CREATE INDEX index_services_on_template ON services USING btree (template);

CREATE INDEX index_services_on_type ON services USING btree (type);

CREATE UNIQUE INDEX index_services_on_type_and_instance_partial ON services USING btree (type, instance) WHERE (instance = true);

CREATE UNIQUE INDEX index_services_on_type_and_template_partial ON services USING btree (type, template) WHERE (template = true);

CREATE INDEX index_services_on_type_id_when_active_and_project_id_not_null ON services USING btree (type, id) WHERE ((active = true) AND (project_id IS NOT NULL));

CREATE UNIQUE INDEX index_services_on_unique_group_id_and_type ON services USING btree (group_id, type);

CREATE UNIQUE INDEX index_shards_on_name ON shards USING btree (name);

CREATE INDEX index_slack_integrations_on_service_id ON slack_integrations USING btree (service_id);

CREATE UNIQUE INDEX index_slack_integrations_on_team_id_and_alias ON slack_integrations USING btree (team_id, alias);

CREATE UNIQUE INDEX index_smartcard_identities_on_subject_and_issuer ON smartcard_identities USING btree (subject, issuer);

CREATE INDEX index_smartcard_identities_on_user_id ON smartcard_identities USING btree (user_id);

CREATE UNIQUE INDEX index_snippet_repositories_on_disk_path ON snippet_repositories USING btree (disk_path);

CREATE INDEX index_snippet_repositories_on_shard_id ON snippet_repositories USING btree (shard_id);

CREATE UNIQUE INDEX index_snippet_user_mentions_on_note_id ON snippet_user_mentions USING btree (note_id) WHERE (note_id IS NOT NULL);

CREATE INDEX index_snippets_on_author_id ON snippets USING btree (author_id);

CREATE INDEX index_snippets_on_content_trigram ON snippets USING gin (content gin_trgm_ops);

CREATE INDEX index_snippets_on_created_at ON snippets USING btree (created_at);

CREATE INDEX index_snippets_on_description_trigram ON snippets USING gin (description gin_trgm_ops);

CREATE INDEX index_snippets_on_file_name_trigram ON snippets USING gin (file_name gin_trgm_ops);

CREATE INDEX index_snippets_on_id_and_created_at ON snippets USING btree (id, created_at);

CREATE INDEX index_snippets_on_id_and_type ON snippets USING btree (id, type);

CREATE INDEX index_snippets_on_project_id_and_visibility_level ON snippets USING btree (project_id, visibility_level);

CREATE INDEX index_snippets_on_title_trigram ON snippets USING gin (title gin_trgm_ops);

CREATE INDEX index_snippets_on_updated_at ON snippets USING btree (updated_at);

CREATE INDEX index_snippets_on_visibility_level_and_secret ON snippets USING btree (visibility_level, secret);

CREATE INDEX index_software_license_policies_on_software_license_id ON software_license_policies USING btree (software_license_id);

CREATE UNIQUE INDEX index_software_license_policies_unique_per_project ON software_license_policies USING btree (project_id, software_license_id);

CREATE INDEX index_software_licenses_on_spdx_identifier ON software_licenses USING btree (spdx_identifier);

CREATE UNIQUE INDEX index_software_licenses_on_unique_name ON software_licenses USING btree (name);

CREATE INDEX index_sprints_on_description_trigram ON sprints USING gin (description gin_trgm_ops);

CREATE INDEX index_sprints_on_due_date ON sprints USING btree (due_date);

CREATE INDEX index_sprints_on_group_id ON sprints USING btree (group_id);

CREATE UNIQUE INDEX index_sprints_on_group_id_and_title ON sprints USING btree (group_id, title) WHERE (group_id IS NOT NULL);

CREATE UNIQUE INDEX index_sprints_on_project_id_and_iid ON sprints USING btree (project_id, iid);

CREATE UNIQUE INDEX index_sprints_on_project_id_and_title ON sprints USING btree (project_id, title) WHERE (project_id IS NOT NULL);

CREATE INDEX index_sprints_on_title ON sprints USING btree (title);

CREATE INDEX index_sprints_on_title_trigram ON sprints USING gin (title gin_trgm_ops);

CREATE UNIQUE INDEX index_status_page_published_incidents_on_issue_id ON status_page_published_incidents USING btree (issue_id);

CREATE INDEX index_status_page_settings_on_project_id ON status_page_settings USING btree (project_id);

CREATE INDEX index_subscriptions_on_project_id ON subscriptions USING btree (project_id);

CREATE UNIQUE INDEX index_subscriptions_on_subscribable_and_user_id_and_project_id ON subscriptions USING btree (subscribable_id, subscribable_type, user_id, project_id);

CREATE INDEX index_successful_deployments_on_cluster_id_and_environment_id ON deployments USING btree (cluster_id, environment_id) WHERE (status = 2);

CREATE UNIQUE INDEX index_suggestions_on_note_id_and_relative_order ON suggestions USING btree (note_id, relative_order);

CREATE UNIQUE INDEX index_system_note_metadata_on_description_version_id ON system_note_metadata USING btree (description_version_id) WHERE (description_version_id IS NOT NULL);

CREATE UNIQUE INDEX index_system_note_metadata_on_note_id ON system_note_metadata USING btree (note_id);

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type ON taggings USING btree (taggable_id, taggable_type);

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);

CREATE INDEX index_tags_on_name_trigram ON tags USING gin (name gin_trgm_ops);

CREATE INDEX index_term_agreements_on_term_id ON term_agreements USING btree (term_id);

CREATE INDEX index_term_agreements_on_user_id ON term_agreements USING btree (user_id);

CREATE INDEX index_terraform_state_versions_on_created_by_user_id ON terraform_state_versions USING btree (created_by_user_id);

CREATE UNIQUE INDEX index_terraform_state_versions_on_state_id_and_version ON terraform_state_versions USING btree (terraform_state_id, version);

CREATE INDEX index_terraform_states_on_file_store ON terraform_states USING btree (file_store);

CREATE INDEX index_terraform_states_on_locked_by_user_id ON terraform_states USING btree (locked_by_user_id);

CREATE UNIQUE INDEX index_terraform_states_on_project_id_and_name ON terraform_states USING btree (project_id, name);

CREATE UNIQUE INDEX index_terraform_states_on_uuid ON terraform_states USING btree (uuid);

CREATE INDEX index_timelogs_on_issue_id ON timelogs USING btree (issue_id);

CREATE INDEX index_timelogs_on_merge_request_id ON timelogs USING btree (merge_request_id);

CREATE INDEX index_timelogs_on_note_id ON timelogs USING btree (note_id);

CREATE INDEX index_timelogs_on_spent_at ON timelogs USING btree (spent_at) WHERE (spent_at IS NOT NULL);

CREATE INDEX index_timelogs_on_user_id ON timelogs USING btree (user_id);

CREATE INDEX index_todos_on_author_id ON todos USING btree (author_id);

CREATE INDEX index_todos_on_author_id_and_created_at ON todos USING btree (author_id, created_at);

CREATE INDEX index_todos_on_commit_id ON todos USING btree (commit_id);

CREATE INDEX index_todos_on_group_id ON todos USING btree (group_id);

CREATE INDEX index_todos_on_note_id ON todos USING btree (note_id);

CREATE INDEX index_todos_on_project_id ON todos USING btree (project_id);

CREATE INDEX index_todos_on_target_type_and_target_id ON todos USING btree (target_type, target_id);

CREATE INDEX index_todos_on_user_id ON todos USING btree (user_id);

CREATE INDEX index_todos_on_user_id_and_id_done ON todos USING btree (user_id, id) WHERE ((state)::text = 'done'::text);

CREATE INDEX index_todos_on_user_id_and_id_pending ON todos USING btree (user_id, id) WHERE ((state)::text = 'pending'::text);

CREATE UNIQUE INDEX index_trending_projects_on_project_id ON trending_projects USING btree (project_id);

CREATE INDEX index_u2f_registrations_on_key_handle ON u2f_registrations USING btree (key_handle);

CREATE INDEX index_u2f_registrations_on_user_id ON u2f_registrations USING btree (user_id);

CREATE INDEX index_uploads_on_checksum ON uploads USING btree (checksum);

CREATE INDEX index_uploads_on_model_id_and_model_type ON uploads USING btree (model_id, model_type);

CREATE INDEX index_uploads_on_store ON uploads USING btree (store);

CREATE INDEX index_uploads_on_uploader_and_path ON uploads USING btree (uploader, path);

CREATE INDEX index_user_agent_details_on_subject_id_and_subject_type ON user_agent_details USING btree (subject_id, subject_type);

CREATE INDEX index_user_callouts_on_user_id ON user_callouts USING btree (user_id);

CREATE UNIQUE INDEX index_user_callouts_on_user_id_and_feature_name ON user_callouts USING btree (user_id, feature_name);

CREATE INDEX index_user_canonical_emails_on_canonical_email ON user_canonical_emails USING btree (canonical_email);

CREATE UNIQUE INDEX index_user_canonical_emails_on_user_id ON user_canonical_emails USING btree (user_id);

CREATE UNIQUE INDEX index_user_canonical_emails_on_user_id_and_canonical_email ON user_canonical_emails USING btree (user_id, canonical_email);

CREATE INDEX index_user_custom_attributes_on_key_and_value ON user_custom_attributes USING btree (key, value);

CREATE UNIQUE INDEX index_user_custom_attributes_on_user_id_and_key ON user_custom_attributes USING btree (user_id, key);

CREATE UNIQUE INDEX index_user_details_on_user_id ON user_details USING btree (user_id);

CREATE INDEX index_user_highest_roles_on_user_id_and_highest_access_level ON user_highest_roles USING btree (user_id, highest_access_level);

CREATE INDEX index_user_interacted_projects_on_user_id ON user_interacted_projects USING btree (user_id);

CREATE INDEX index_user_preferences_on_gitpod_enabled ON user_preferences USING btree (gitpod_enabled);

CREATE UNIQUE INDEX index_user_preferences_on_user_id ON user_preferences USING btree (user_id);

CREATE INDEX index_user_statuses_on_user_id ON user_statuses USING btree (user_id);

CREATE UNIQUE INDEX index_user_synced_attributes_metadata_on_user_id ON user_synced_attributes_metadata USING btree (user_id);

CREATE INDEX index_users_on_accepted_term_id ON users USING btree (accepted_term_id);

CREATE INDEX index_users_on_admin ON users USING btree (admin);

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);

CREATE INDEX index_users_on_created_at ON users USING btree (created_at);

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);

CREATE INDEX index_users_on_email_trigram ON users USING gin (email gin_trgm_ops);

CREATE INDEX index_users_on_feed_token ON users USING btree (feed_token);

CREATE INDEX index_users_on_group_view ON users USING btree (group_view);

CREATE INDEX index_users_on_incoming_email_token ON users USING btree (incoming_email_token);

CREATE INDEX index_users_on_managing_group_id ON users USING btree (managing_group_id);

CREATE INDEX index_users_on_name ON users USING btree (name);

CREATE INDEX index_users_on_name_trigram ON users USING gin (name gin_trgm_ops);

CREATE INDEX index_users_on_public_email ON users USING btree (public_email) WHERE ((public_email)::text <> ''::text);

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);

CREATE INDEX index_users_on_state ON users USING btree (state);

CREATE INDEX index_users_on_state_and_user_type ON users USING btree (state, user_type);

CREATE UNIQUE INDEX index_users_on_static_object_token ON users USING btree (static_object_token);

CREATE INDEX index_users_on_unconfirmed_email ON users USING btree (unconfirmed_email) WHERE (unconfirmed_email IS NOT NULL);

CREATE UNIQUE INDEX index_users_on_unlock_token ON users USING btree (unlock_token);

CREATE INDEX index_users_on_user_type ON users USING btree (user_type);

CREATE INDEX index_users_on_username ON users USING btree (username);

CREATE INDEX index_users_on_username_trigram ON users USING gin (username gin_trgm_ops);

CREATE INDEX index_users_ops_dashboard_projects_on_project_id ON users_ops_dashboard_projects USING btree (project_id);

CREATE UNIQUE INDEX index_users_ops_dashboard_projects_on_user_id_and_project_id ON users_ops_dashboard_projects USING btree (user_id, project_id);

CREATE INDEX index_users_security_dashboard_projects_on_user_id ON users_security_dashboard_projects USING btree (user_id);

CREATE INDEX index_users_star_projects_on_project_id ON users_star_projects USING btree (project_id);

CREATE UNIQUE INDEX index_users_star_projects_on_user_id_and_project_id ON users_star_projects USING btree (user_id, project_id);

CREATE UNIQUE INDEX index_vuln_historical_statistics_on_project_id_and_date ON vulnerability_historical_statistics USING btree (project_id, date);

CREATE INDEX index_vulnerabilities_on_author_id ON vulnerabilities USING btree (author_id);

CREATE INDEX index_vulnerabilities_on_confirmed_by_id ON vulnerabilities USING btree (confirmed_by_id);

CREATE INDEX index_vulnerabilities_on_dismissed_by_id ON vulnerabilities USING btree (dismissed_by_id);

CREATE INDEX index_vulnerabilities_on_due_date_sourcing_milestone_id ON vulnerabilities USING btree (due_date_sourcing_milestone_id);

CREATE INDEX index_vulnerabilities_on_epic_id ON vulnerabilities USING btree (epic_id);

CREATE INDEX index_vulnerabilities_on_last_edited_by_id ON vulnerabilities USING btree (last_edited_by_id);

CREATE INDEX index_vulnerabilities_on_milestone_id ON vulnerabilities USING btree (milestone_id);

CREATE INDEX index_vulnerabilities_on_project_id ON vulnerabilities USING btree (project_id);

CREATE INDEX index_vulnerabilities_on_resolved_by_id ON vulnerabilities USING btree (resolved_by_id);

CREATE INDEX index_vulnerabilities_on_start_date_sourcing_milestone_id ON vulnerabilities USING btree (start_date_sourcing_milestone_id);

CREATE INDEX index_vulnerabilities_on_state_case_id ON vulnerabilities USING btree (array_position(ARRAY[(1)::smallint, (4)::smallint, (3)::smallint, (2)::smallint], state), id DESC);

CREATE INDEX index_vulnerabilities_on_state_case_id_desc ON vulnerabilities USING btree (array_position(ARRAY[(1)::smallint, (4)::smallint, (3)::smallint, (2)::smallint], state) DESC, id DESC);

CREATE INDEX index_vulnerabilities_on_updated_by_id ON vulnerabilities USING btree (updated_by_id);

CREATE INDEX index_vulnerability_exports_on_author_id ON vulnerability_exports USING btree (author_id);

CREATE INDEX index_vulnerability_exports_on_file_store ON vulnerability_exports USING btree (file_store);

CREATE INDEX index_vulnerability_exports_on_group_id_not_null ON vulnerability_exports USING btree (group_id) WHERE (group_id IS NOT NULL);

CREATE INDEX index_vulnerability_exports_on_project_id_not_null ON vulnerability_exports USING btree (project_id) WHERE (project_id IS NOT NULL);

CREATE INDEX index_vulnerability_feedback_on_author_id ON vulnerability_feedback USING btree (author_id);

CREATE INDEX index_vulnerability_feedback_on_comment_author_id ON vulnerability_feedback USING btree (comment_author_id);

CREATE INDEX index_vulnerability_feedback_on_issue_id ON vulnerability_feedback USING btree (issue_id);

CREATE INDEX index_vulnerability_feedback_on_issue_id_not_null ON vulnerability_feedback USING btree (id) WHERE (issue_id IS NOT NULL);

CREATE INDEX index_vulnerability_feedback_on_merge_request_id ON vulnerability_feedback USING btree (merge_request_id);

CREATE INDEX index_vulnerability_feedback_on_pipeline_id ON vulnerability_feedback USING btree (pipeline_id);

CREATE INDEX index_vulnerability_historical_statistics_on_date_and_id ON vulnerability_historical_statistics USING btree (date, id);

CREATE UNIQUE INDEX index_vulnerability_identifiers_on_project_id_and_fingerprint ON vulnerability_identifiers USING btree (project_id, fingerprint);

CREATE INDEX index_vulnerability_issue_links_on_issue_id ON vulnerability_issue_links USING btree (issue_id);

CREATE INDEX index_vulnerability_occurrence_identifiers_on_identifier_id ON vulnerability_occurrence_identifiers USING btree (identifier_id);

CREATE UNIQUE INDEX index_vulnerability_occurrence_identifiers_on_unique_keys ON vulnerability_occurrence_identifiers USING btree (occurrence_id, identifier_id);

CREATE INDEX index_vulnerability_occurrence_pipelines_on_pipeline_id ON vulnerability_occurrence_pipelines USING btree (pipeline_id);

CREATE INDEX index_vulnerability_occurrences_for_issue_links_migration ON vulnerability_occurrences USING btree (project_id, report_type, encode(project_fingerprint, 'hex'::text));

CREATE INDEX index_vulnerability_occurrences_on_primary_identifier_id ON vulnerability_occurrences USING btree (primary_identifier_id);

CREATE INDEX index_vulnerability_occurrences_on_scanner_id ON vulnerability_occurrences USING btree (scanner_id);

CREATE UNIQUE INDEX index_vulnerability_occurrences_on_unique_keys ON vulnerability_occurrences USING btree (project_id, primary_identifier_id, location_fingerprint, scanner_id);

CREATE UNIQUE INDEX index_vulnerability_occurrences_on_uuid ON vulnerability_occurrences USING btree (uuid);

CREATE INDEX index_vulnerability_occurrences_on_vulnerability_id ON vulnerability_occurrences USING btree (vulnerability_id);

CREATE UNIQUE INDEX index_vulnerability_scanners_on_project_id_and_external_id ON vulnerability_scanners USING btree (project_id, external_id);

CREATE INDEX index_vulnerability_statistics_on_letter_grade ON vulnerability_statistics USING btree (letter_grade);

CREATE UNIQUE INDEX index_vulnerability_statistics_on_unique_project_id ON vulnerability_statistics USING btree (project_id);

CREATE UNIQUE INDEX index_vulnerability_user_mentions_on_note_id ON vulnerability_user_mentions USING btree (note_id) WHERE (note_id IS NOT NULL);

CREATE UNIQUE INDEX index_vulns_user_mentions_on_vulnerability_id ON vulnerability_user_mentions USING btree (vulnerability_id) WHERE (note_id IS NULL);

CREATE UNIQUE INDEX index_vulns_user_mentions_on_vulnerability_id_and_note_id ON vulnerability_user_mentions USING btree (vulnerability_id, note_id);

CREATE INDEX index_web_hook_logs_on_created_at_and_web_hook_id ON web_hook_logs USING btree (created_at, web_hook_id);

CREATE INDEX index_web_hook_logs_on_web_hook_id ON web_hook_logs USING btree (web_hook_id);

CREATE INDEX index_web_hooks_on_group_id ON web_hooks USING btree (group_id) WHERE ((type)::text = 'GroupHook'::text);

CREATE INDEX index_web_hooks_on_project_id ON web_hooks USING btree (project_id);

CREATE INDEX index_web_hooks_on_type ON web_hooks USING btree (type);

CREATE UNIQUE INDEX index_webauthn_registrations_on_credential_xid ON webauthn_registrations USING btree (credential_xid);

CREATE INDEX index_webauthn_registrations_on_u2f_registration_id ON webauthn_registrations USING btree (u2f_registration_id) WHERE (u2f_registration_id IS NOT NULL);

CREATE INDEX index_webauthn_registrations_on_user_id ON webauthn_registrations USING btree (user_id);

CREATE INDEX index_wiki_page_meta_on_project_id ON wiki_page_meta USING btree (project_id);

CREATE UNIQUE INDEX index_wiki_page_slugs_on_slug_and_wiki_page_meta_id ON wiki_page_slugs USING btree (slug, wiki_page_meta_id);

CREATE INDEX index_wiki_page_slugs_on_wiki_page_meta_id ON wiki_page_slugs USING btree (wiki_page_meta_id);

CREATE INDEX index_x509_certificates_on_subject_key_identifier ON x509_certificates USING btree (subject_key_identifier);

CREATE INDEX index_x509_certificates_on_x509_issuer_id ON x509_certificates USING btree (x509_issuer_id);

CREATE INDEX index_x509_commit_signatures_on_commit_sha ON x509_commit_signatures USING btree (commit_sha);

CREATE INDEX index_x509_commit_signatures_on_project_id ON x509_commit_signatures USING btree (project_id);

CREATE INDEX index_x509_commit_signatures_on_x509_certificate_id ON x509_commit_signatures USING btree (x509_certificate_id);

CREATE INDEX index_x509_issuers_on_subject_key_identifier ON x509_issuers USING btree (subject_key_identifier);

CREATE INDEX index_zoom_meetings_on_issue_id ON zoom_meetings USING btree (issue_id);

CREATE UNIQUE INDEX index_zoom_meetings_on_issue_id_and_issue_status ON zoom_meetings USING btree (issue_id, issue_status) WHERE (issue_status = 1);

CREATE INDEX index_zoom_meetings_on_issue_status ON zoom_meetings USING btree (issue_status);

CREATE INDEX index_zoom_meetings_on_project_id ON zoom_meetings USING btree (project_id);

CREATE INDEX issue_id_issues_prometheus_alert_events_index ON issues_prometheus_alert_events USING btree (prometheus_alert_event_id);

CREATE INDEX issue_id_issues_self_managed_rometheus_alert_events_index ON issues_self_managed_prometheus_alert_events USING btree (self_managed_prometheus_alert_event_id);

CREATE UNIQUE INDEX issue_user_mentions_on_issue_id_and_note_id_index ON issue_user_mentions USING btree (issue_id, note_id);

CREATE UNIQUE INDEX issue_user_mentions_on_issue_id_index ON issue_user_mentions USING btree (issue_id) WHERE (note_id IS NULL);

CREATE UNIQUE INDEX kubernetes_namespaces_cluster_and_namespace ON clusters_kubernetes_namespaces USING btree (cluster_id, namespace);

CREATE INDEX merge_request_mentions_temp_index ON merge_requests USING btree (id) WHERE ((description ~~ '%@%'::text) OR ((title)::text ~~ '%@%'::text));

CREATE UNIQUE INDEX merge_request_user_mentions_on_mr_id_and_note_id_index ON merge_request_user_mentions USING btree (merge_request_id, note_id);

CREATE UNIQUE INDEX merge_request_user_mentions_on_mr_id_index ON merge_request_user_mentions USING btree (merge_request_id) WHERE (note_id IS NULL);

CREATE INDEX note_mentions_temp_index ON notes USING btree (id, noteable_type) WHERE (note ~~ '%@%'::text);

CREATE UNIQUE INDEX one_canonical_wiki_page_slug_per_metadata ON wiki_page_slugs USING btree (wiki_page_meta_id) WHERE (canonical = true);

CREATE INDEX package_name_index ON packages_packages USING btree (name);

CREATE INDEX packages_packages_verification_checksum_partial ON packages_package_files USING btree (verification_checksum) WHERE (verification_checksum IS NOT NULL);

CREATE INDEX packages_packages_verification_failure_partial ON packages_package_files USING btree (verification_failure) WHERE (verification_failure IS NOT NULL);

CREATE INDEX partial_index_ci_builds_on_scheduled_at_with_scheduled_jobs ON ci_builds USING btree (scheduled_at) WHERE ((scheduled_at IS NOT NULL) AND ((type)::text = 'Ci::Build'::text) AND ((status)::text = 'scheduled'::text));

CREATE INDEX partial_index_deployments_for_legacy_successful_deployments ON deployments USING btree (id) WHERE ((finished_at IS NULL) AND (status = 2));

CREATE INDEX partial_index_deployments_for_project_id_and_tag ON deployments USING btree (project_id) WHERE (tag IS TRUE);

CREATE INDEX snippet_repositories_verification_checksum_partial ON snippet_repositories USING btree (verification_checksum) WHERE (verification_checksum IS NOT NULL);

CREATE INDEX snippet_repositories_verification_failure_partial ON snippet_repositories USING btree (verification_failure) WHERE (verification_failure IS NOT NULL);

CREATE UNIQUE INDEX snippet_user_mentions_on_snippet_id_and_note_id_index ON snippet_user_mentions USING btree (snippet_id, note_id);

CREATE UNIQUE INDEX snippet_user_mentions_on_snippet_id_index ON snippet_user_mentions USING btree (snippet_id) WHERE (note_id IS NULL);

CREATE UNIQUE INDEX taggings_idx ON taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);

CREATE UNIQUE INDEX term_agreements_unique_index ON term_agreements USING btree (user_id, term_id);

CREATE INDEX terraform_state_versions_verification_checksum_partial ON terraform_state_versions USING btree (verification_checksum) WHERE (verification_checksum IS NOT NULL);

CREATE INDEX terraform_state_versions_verification_failure_partial ON terraform_state_versions USING btree (verification_failure) WHERE (verification_failure IS NOT NULL);

CREATE INDEX tmp_build_stage_position_index ON ci_builds USING btree (stage_id, stage_idx) WHERE (stage_idx IS NOT NULL);

CREATE INDEX tmp_idx_blocked_by_type_links ON issue_links USING btree (target_id) WHERE (link_type = 2);

CREATE INDEX tmp_idx_blocking_type_links ON issue_links USING btree (source_id) WHERE (link_type = 1);

CREATE INDEX tmp_idx_index_issues_with_outdate_blocking_count ON issues USING btree (id) WHERE ((state_id = 1) AND (blocking_issues_count = 0));

CREATE INDEX tmp_index_for_email_unconfirmation_migration ON emails USING btree (id) WHERE (confirmed_at IS NOT NULL);

CREATE UNIQUE INDEX unique_merge_request_metrics_by_merge_request_id ON merge_request_metrics USING btree (merge_request_id);

CREATE UNIQUE INDEX vulnerability_feedback_unique_idx ON vulnerability_feedback USING btree (project_id, category, feedback_type, project_fingerprint);

CREATE UNIQUE INDEX vulnerability_occurrence_pipelines_on_unique_keys ON vulnerability_occurrence_pipelines USING btree (occurrence_id, pipeline_id);

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx10;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx11;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx12;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx13;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx14;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx15;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx16;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx17;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx18;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx19;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx20;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx21;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx22;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx23;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx24;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx25;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx26;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx27;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx28;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx29;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx30;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx31;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx32;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx33;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx34;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx35;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx36;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx37;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx38;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx39;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx40;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx41;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx42;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx43;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx44;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx45;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx46;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx47;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx48;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx49;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx50;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx51;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx52;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx53;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx54;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx55;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx56;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx57;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx58;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx59;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx60;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx61;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx62;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_expe_project_id_collector_tstamp_idx63;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx1;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx2;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx3;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx4;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx5;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx6;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx7;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx8;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_exper_project_id_collector_tstamp_idx9;

ALTER INDEX index_product_analytics_events_experimental_project_and_time ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experi_project_id_collector_tstamp_idx;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_00_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_01_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_02_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_03_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_04_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_05_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_06_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_07_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_08_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_09_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_10_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_11_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_12_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_13_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_14_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_15_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_16_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_17_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_18_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_19_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_20_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_21_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_22_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_23_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_24_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_25_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_26_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_27_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_28_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_29_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_30_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_31_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_32_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_33_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_34_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_35_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_36_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_37_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_38_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_39_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_40_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_41_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_42_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_43_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_44_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_45_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_46_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_47_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_48_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_49_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_50_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_51_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_52_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_53_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_54_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_55_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_56_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_57_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_58_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_59_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_60_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_61_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_62_pkey;

ALTER INDEX product_analytics_events_experimental_pkey ATTACH PARTITION gitlab_partitions_static.product_analytics_events_experimental_63_pkey;

CREATE TRIGGER table_sync_trigger_ee39a25f9d AFTER INSERT OR DELETE OR UPDATE ON audit_events FOR EACH ROW EXECUTE PROCEDURE table_sync_function_2be879775d();

ALTER TABLE ONLY chat_names
    ADD CONSTRAINT fk_00797a2bf9 FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_013c9f36ca FOREIGN KEY (due_date_sourcing_epic_id) REFERENCES epics(id) ON DELETE SET NULL;

ALTER TABLE ONLY clusters_applications_runners
    ADD CONSTRAINT fk_02de2ded36 FOREIGN KEY (runner_id) REFERENCES ci_runners(id) ON DELETE SET NULL;

ALTER TABLE ONLY design_management_designs_versions
    ADD CONSTRAINT fk_03c671965c FOREIGN KEY (design_id) REFERENCES design_management_designs(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_05f1e72feb FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_06067f5644 FOREIGN KEY (latest_merge_request_diff_id) REFERENCES merge_request_diffs(id) ON DELETE SET NULL;

ALTER TABLE ONLY user_interacted_projects
    ADD CONSTRAINT fk_0894651f08 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY dast_sites
    ADD CONSTRAINT fk_0a57f2271b FOREIGN KEY (dast_site_validation_id) REFERENCES dast_site_validations(id) ON DELETE SET NULL;

ALTER TABLE ONLY web_hooks
    ADD CONSTRAINT fk_0c8ca6d9d1 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY notification_settings
    ADD CONSTRAINT fk_0c95e91db7 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY lists
    ADD CONSTRAINT fk_0d3f677137 FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_pages_metadata
    ADD CONSTRAINT fk_0fd5b22688 FOREIGN KEY (pages_deployment_id) REFERENCES pages_deployments(id) ON DELETE SET NULL;

ALTER TABLE ONLY group_deletion_schedules
    ADD CONSTRAINT fk_11e3ebfcdd FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_1302949740 FOREIGN KEY (last_edited_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_131d289c65 FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

ALTER TABLE ONLY webauthn_registrations
    ADD CONSTRAINT fk_13e04d719a FOREIGN KEY (u2f_registration_id) REFERENCES u2f_registrations(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_branch_push_access_levels
    ADD CONSTRAINT fk_15d2a7a4ae FOREIGN KEY (deploy_key_id) REFERENCES keys(id) ON DELETE CASCADE;

ALTER TABLE ONLY internal_ids
    ADD CONSTRAINT fk_162941d509 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_176d3fbb5d FOREIGN KEY (job_artifact_deleted_event_id) REFERENCES geo_job_artifact_deleted_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_features
    ADD CONSTRAINT fk_18513d9b92 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipelines
    ADD CONSTRAINT fk_190998ef09 FOREIGN KEY (external_pull_request_id) REFERENCES external_pull_requests(id) ON DELETE SET NULL;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_1d37cddf91 FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_sources_pipelines
    ADD CONSTRAINT fk_1e53c97c0a FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY boards
    ADD CONSTRAINT fk_1e9a074a35 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_1fbed67632 FOREIGN KEY (start_date_sourcing_milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

ALTER TABLE ONLY geo_container_repository_updated_events
    ADD CONSTRAINT fk_212c89c706 FOREIGN KEY (container_repository_id) REFERENCES container_repositories(id) ON DELETE CASCADE;

ALTER TABLE ONLY users_star_projects
    ADD CONSTRAINT fk_22cd27ddfc FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY alert_management_alerts
    ADD CONSTRAINT fk_2358b75436 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_stages
    ADD CONSTRAINT fk_2360681d1d FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY import_failures
    ADD CONSTRAINT fk_24b824da43 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_ci_cd_settings
    ADD CONSTRAINT fk_24c15d2f2e FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_25b99c1be3 FOREIGN KEY (parent_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_25d8780d11 FOREIGN KEY (marked_for_deletion_by_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_pipelines
    ADD CONSTRAINT fk_262d4c2d19 FOREIGN KEY (auto_canceled_by_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_build_trace_sections
    ADD CONSTRAINT fk_264e112c66 FOREIGN KEY (section_name_id) REFERENCES ci_build_trace_section_names(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_27548c6db3 FOREIGN KEY (hashed_storage_migrated_event_id) REFERENCES geo_hashed_storage_migrated_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY deployments
    ADD CONSTRAINT fk_289bba3222 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE SET NULL;

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_2e82291620 FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE SET NULL;

ALTER TABLE ONLY members
    ADD CONSTRAINT fk_2e88fb7ce9 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY approvals
    ADD CONSTRAINT fk_310d714958 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY namespaces
    ADD CONSTRAINT fk_319256d87a FOREIGN KEY (file_template_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_3308fe130c FOREIGN KEY (source_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_group_variables
    ADD CONSTRAINT fk_33ae4d58d8 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY namespaces
    ADD CONSTRAINT fk_3448c97865 FOREIGN KEY (push_rule_id) REFERENCES push_rules(id) ON DELETE SET NULL;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_3654b61b03 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY push_event_payloads
    ADD CONSTRAINT fk_36c74129da FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_builds
    ADD CONSTRAINT fk_3a9eaa254d FOREIGN KEY (stage_id) REFERENCES ci_stages(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_3b8c72ea56 FOREIGN KEY (sprint_id) REFERENCES sprints(id) ON DELETE CASCADE;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_3c1fd1cccc FOREIGN KEY (due_date_sourcing_milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_pipelines
    ADD CONSTRAINT fk_3d34ab2e06 FOREIGN KEY (pipeline_schedule_id) REFERENCES ci_pipeline_schedules(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_pipeline_schedule_variables
    ADD CONSTRAINT fk_41c35fda51 FOREIGN KEY (pipeline_schedule_id) REFERENCES ci_pipeline_schedules(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_42c3b54bed FOREIGN KEY (cache_invalidation_event_id) REFERENCES geo_cache_invalidation_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY remote_mirrors
    ADD CONSTRAINT fk_43a9aa4ca8 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_runner_projects
    ADD CONSTRAINT fk_4478a6f1e4 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY todos
    ADD CONSTRAINT fk_45054f9c45 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY releases
    ADD CONSTRAINT fk_47fe2a0596 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_4a99ebfd60 FOREIGN KEY (repositories_changed_event_id) REFERENCES geo_repositories_changed_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_trace_sections
    ADD CONSTRAINT fk_4ebe41f502 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY alert_management_alerts
    ADD CONSTRAINT fk_51ab4b6089 FOREIGN KEY (prometheus_alert_id) REFERENCES prometheus_alerts(id) ON DELETE CASCADE;

ALTER TABLE ONLY path_locks
    ADD CONSTRAINT fk_5265c98f24 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_prometheus
    ADD CONSTRAINT fk_557e773639 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_metrics
    ADD CONSTRAINT fk_56067dcb44 FOREIGN KEY (target_project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_feedback
    ADD CONSTRAINT fk_563ff1912e FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE SET NULL;

ALTER TABLE ONLY deploy_keys_projects
    ADD CONSTRAINT fk_58a901ca7e FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY issue_assignees
    ADD CONSTRAINT fk_5e0c8d9154 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY csv_issue_imports
    ADD CONSTRAINT fk_5e1572387c FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_access_tokens
    ADD CONSTRAINT fk_5f7e8450e1 FOREIGN KEY (personal_access_token_id) REFERENCES personal_access_tokens(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_6149611a04 FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_61fbf6ca48 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_641731faff FOREIGN KEY (updated_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_builds
    ADD CONSTRAINT fk_6661f4f0e8 FOREIGN KEY (resource_group_id) REFERENCES ci_resource_groups(id) ON DELETE SET NULL;

ALTER TABLE ONLY project_pages_metadata
    ADD CONSTRAINT fk_69366a119e FOREIGN KEY (artifacts_archive_id) REFERENCES ci_job_artifacts(id) ON DELETE SET NULL;

ALTER TABLE ONLY application_settings
    ADD CONSTRAINT fk_693b8795e4 FOREIGN KEY (push_rule_id) REFERENCES push_rules(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_6a5165a692 FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_6ada82d42a FOREIGN KEY (container_repository_updated_event_id) REFERENCES geo_container_repository_updated_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_6e5c14658a FOREIGN KEY (pool_repository_id) REFERENCES pool_repositories(id) ON DELETE SET NULL;

ALTER TABLE ONLY terraform_state_versions
    ADD CONSTRAINT fk_6e81384d7f FOREIGN KEY (created_by_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY protected_branch_push_access_levels
    ADD CONSTRAINT fk_7111b68cdb FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY services
    ADD CONSTRAINT fk_71cce407f9 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_interacted_projects
    ADD CONSTRAINT fk_722ceba4f7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_725465b774 FOREIGN KEY (dismissed_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY index_statuses
    ADD CONSTRAINT fk_74b2492545 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_76bc5f5455 FOREIGN KEY (resolved_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY oauth_openid_requests
    ADD CONSTRAINT fk_77114b3b09 FOREIGN KEY (access_grant_id) REFERENCES oauth_access_grants(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_resource_groups
    ADD CONSTRAINT fk_774722d144 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_789cd90b35 FOREIGN KEY (accepted_term_id) REFERENCES application_setting_terms(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_78a6492f68 FOREIGN KEY (repository_updated_event_id) REFERENCES geo_repository_updated_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY lists
    ADD CONSTRAINT fk_7a5553d60f FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_branches
    ADD CONSTRAINT fk_7a9c6d93e7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_7ac31eacb9 FOREIGN KEY (updated_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_7c5bb22a22 FOREIGN KEY (due_date_sourcing_milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

ALTER TABLE ONLY labels
    ADD CONSTRAINT fk_7de4989a69 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY backup_labels
    ADD CONSTRAINT fk_7de4989a69 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_7e85395a64 FOREIGN KEY (sprint_id) REFERENCES sprints(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_metrics
    ADD CONSTRAINT fk_7f28d925f3 FOREIGN KEY (merged_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY group_import_states
    ADD CONSTRAINT fk_8053b3ebd6 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY sprints
    ADD CONSTRAINT fk_80aa8a1f95 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY import_export_uploads
    ADD CONSTRAINT fk_83319d9721 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY push_rules
    ADD CONSTRAINT fk_83b29894de FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_diffs
    ADD CONSTRAINT fk_8483f3258f FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipelines
    ADD CONSTRAINT fk_86635dbd80 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY services
    ADD CONSTRAINT fk_868a8e7ad6 FOREIGN KEY (inherit_from_id) REFERENCES services(id) ON DELETE SET NULL;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_86c84214ec FOREIGN KEY (repository_renamed_event_id) REFERENCES geo_repository_renamed_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_package_files
    ADD CONSTRAINT fk_86f0f182f8 FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_builds
    ADD CONSTRAINT fk_87f4cefcda FOREIGN KEY (upstream_pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_88b4d546ef FOREIGN KEY (start_date_sourcing_milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

ALTER TABLE ONLY bulk_import_entities
    ADD CONSTRAINT fk_88c725229f FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_899c8f3231 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_branch_merge_access_levels
    ADD CONSTRAINT fk_8a3072ccb3 FOREIGN KEY (protected_branch_id) REFERENCES protected_branches(id) ON DELETE CASCADE;

ALTER TABLE ONLY timelogs
    ADD CONSTRAINT fk_8d058cd571 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY releases
    ADD CONSTRAINT fk_8e4456f90f FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY protected_tags
    ADD CONSTRAINT fk_8e4af87648 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipeline_schedules
    ADD CONSTRAINT fk_8ead60fcc4 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY todos
    ADD CONSTRAINT fk_91d1f47b13 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_feedback
    ADD CONSTRAINT fk_94f7c8a81e FOREIGN KEY (comment_author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY milestones
    ADD CONSTRAINT fk_95650a40d4 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_959d40ad0a FOREIGN KEY (confirmed_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY application_settings
    ADD CONSTRAINT fk_964370041d FOREIGN KEY (usage_stats_set_by_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_96b1dd429c FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE SET NULL;

ALTER TABLE ONLY vulnerability_occurrences
    ADD CONSTRAINT fk_97ffe77653 FOREIGN KEY (vulnerability_id) REFERENCES vulnerabilities(id) ON DELETE SET NULL;

ALTER TABLE ONLY protected_branch_merge_access_levels
    ADD CONSTRAINT fk_98f3d044fe FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_99e097b079 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_9b9afb1916 FOREIGN KEY (repository_created_event_id) REFERENCES geo_repository_created_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY milestones
    ADD CONSTRAINT fk_9bd0a0c791 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_9c4516d665 FOREIGN KEY (duplicated_to_id) REFERENCES issues(id) ON DELETE SET NULL;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_9d480c64b2 FOREIGN KEY (start_date_sourcing_epic_id) REFERENCES epics(id) ON DELETE SET NULL;

ALTER TABLE ONLY alert_management_alerts
    ADD CONSTRAINT fk_9e49e5c2b7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipeline_schedules
    ADD CONSTRAINT fk_9ea99f58d2 FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY protected_branch_push_access_levels
    ADD CONSTRAINT fk_9ffc86a3d9 FOREIGN KEY (protected_branch_id) REFERENCES protected_branches(id) ON DELETE CASCADE;

ALTER TABLE ONLY deployment_merge_requests
    ADD CONSTRAINT fk_a064ff4453 FOREIGN KEY (environment_id) REFERENCES environments(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_a194299be1 FOREIGN KEY (moved_to_id) REFERENCES issues(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_builds
    ADD CONSTRAINT fk_a2141b1522 FOREIGN KEY (auto_canceled_by_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_pipelines
    ADD CONSTRAINT fk_a23be95014 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY bulk_import_entities
    ADD CONSTRAINT fk_a44ff95be5 FOREIGN KEY (parent_id) REFERENCES bulk_import_entities(id) ON DELETE CASCADE;

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_a4b8fefe3e FOREIGN KEY (managing_group_id) REFERENCES namespaces(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_a6963e8447 FOREIGN KEY (target_project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_aa5798e761 FOREIGN KEY (closed_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY alert_management_alerts
    ADD CONSTRAINT fk_aad61aedca FOREIGN KEY (environment_id) REFERENCES environments(id) ON DELETE SET NULL;

ALTER TABLE ONLY identities
    ADD CONSTRAINT fk_aade90f0fc FOREIGN KEY (saml_provider_id) REFERENCES saml_providers(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_sources_pipelines
    ADD CONSTRAINT fk_acd9737679 FOREIGN KEY (source_project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_ad525e1f87 FOREIGN KEY (merge_user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_variables
    ADD CONSTRAINT fk_ada5eb64b3 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_metrics
    ADD CONSTRAINT fk_ae440388cc FOREIGN KEY (latest_closed_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY analytics_cycle_analytics_group_stages
    ADD CONSTRAINT fk_analytics_cycle_analytics_group_stages_group_value_stream_id FOREIGN KEY (group_value_stream_id) REFERENCES analytics_cycle_analytics_group_value_streams(id) ON DELETE CASCADE;

ALTER TABLE ONLY fork_network_members
    ADD CONSTRAINT fk_b01280dae4 FOREIGN KEY (forked_from_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_b1de915a15 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY project_access_tokens
    ADD CONSTRAINT fk_b27801bfbf FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_tag_create_access_levels
    ADD CONSTRAINT fk_b4eb82fe3c FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY bulk_import_entities
    ADD CONSTRAINT fk_b69fa2b2df FOREIGN KEY (bulk_import_id) REFERENCES bulk_imports(id) ON DELETE CASCADE;

ALTER TABLE ONLY compliance_management_frameworks
    ADD CONSTRAINT fk_b74c45b71f FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY issue_assignees
    ADD CONSTRAINT fk_b7d881734a FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_trigger_requests
    ADD CONSTRAINT fk_b8ec8b7245 FOREIGN KEY (trigger_id) REFERENCES ci_triggers(id) ON DELETE CASCADE;

ALTER TABLE ONLY deployments
    ADD CONSTRAINT fk_b9a3851b82 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY gitlab_subscriptions
    ADD CONSTRAINT fk_bd0c4019c3 FOREIGN KEY (hosted_plan_id) REFERENCES plans(id) ON DELETE CASCADE;

ALTER TABLE ONLY metrics_users_starred_dashboards
    ADD CONSTRAINT fk_bd6ae32fac FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_compliance_framework_settings
    ADD CONSTRAINT fk_be413374a9 FOREIGN KEY (framework_id) REFERENCES compliance_management_frameworks(id) ON DELETE CASCADE;

ALTER TABLE ONLY snippets
    ADD CONSTRAINT fk_be41fd4bb7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_sources_pipelines
    ADD CONSTRAINT fk_be5624bf37 FOREIGN KEY (source_job_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_maven_metadata
    ADD CONSTRAINT fk_be88aed360 FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_builds
    ADD CONSTRAINT fk_befce0568a FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY design_management_versions
    ADD CONSTRAINT fk_c1440b4896 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY packages_packages
    ADD CONSTRAINT fk_c188f0dba4 FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_c1f241c70d FOREIGN KEY (upload_deleted_event_id) REFERENCES geo_upload_deleted_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_exports
    ADD CONSTRAINT fk_c3d3cb5d0f FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_c4b1c1f66e FOREIGN KEY (repository_deleted_event_id) REFERENCES geo_repository_deleted_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_c63cbf6c25 FOREIGN KEY (closed_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY issue_links
    ADD CONSTRAINT fk_c900194ff2 FOREIGN KEY (source_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY todos
    ADD CONSTRAINT fk_ccf0373936 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_cff7185ad2 FOREIGN KEY (reset_checksum_event_id) REFERENCES geo_reset_checksum_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY bulk_import_entities
    ADD CONSTRAINT fk_d06d023c30 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_mirror_data
    ADD CONSTRAINT fk_d1aad367d7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY environments
    ADD CONSTRAINT fk_d1c8c1da6a FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_builds
    ADD CONSTRAINT fk_d3130c9a7f FOREIGN KEY (commit_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_sources_pipelines
    ADD CONSTRAINT fk_d4e29af7d7 FOREIGN KEY (source_pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_d5af95fcd9 FOREIGN KEY (lfs_object_deleted_event_id) REFERENCES geo_lfs_object_deleted_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY lists
    ADD CONSTRAINT fk_d6cf4279f7 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY metrics_users_starred_dashboards
    ADD CONSTRAINT fk_d76a2b9a8c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipelines
    ADD CONSTRAINT fk_d80e161c54 FOREIGN KEY (ci_ref_id) REFERENCES ci_refs(id) ON DELETE SET NULL;

ALTER TABLE ONLY system_note_metadata
    ADD CONSTRAINT fk_d83a918cb1 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY todos
    ADD CONSTRAINT fk_d94154aa95 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY label_links
    ADD CONSTRAINT fk_d97dd08678 FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_group_links
    ADD CONSTRAINT fk_daa8cee94c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_dccd3f98fc FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_df75a7c8b8 FOREIGN KEY (promoted_to_epic_id) REFERENCES epics(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_resources
    ADD CONSTRAINT fk_e169a8e3d5 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_sources_pipelines
    ADD CONSTRAINT fk_e1bad85861 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY gitlab_subscriptions
    ADD CONSTRAINT fk_e2595d00a1 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_triggers
    ADD CONSTRAINT fk_e3e63f966e FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_e719a85f8a FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY issue_links
    ADD CONSTRAINT fk_e71bb44f1f FOREIGN KEY (target_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY csv_issue_imports
    ADD CONSTRAINT fk_e71c0ae362 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY namespaces
    ADD CONSTRAINT fk_e7a0b20a6b FOREIGN KEY (custom_project_templates_group_id) REFERENCES namespaces(id) ON DELETE SET NULL;

ALTER TABLE ONLY fork_networks
    ADD CONSTRAINT fk_e7b436b2b5 FOREIGN KEY (root_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY sprints
    ADD CONSTRAINT fk_e8206c9686 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY application_settings
    ADD CONSTRAINT fk_e8a145f3a7 FOREIGN KEY (instance_administrators_group_id) REFERENCES namespaces(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_triggers
    ADD CONSTRAINT fk_e8e10d1964 FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY services
    ADD CONSTRAINT fk_e8fe908a34 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY pages_domains
    ADD CONSTRAINT fk_ea2f6dfc6f FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY application_settings
    ADD CONSTRAINT fk_ec757bd087 FOREIGN KEY (file_template_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_edfd187b6f FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerabilities
    ADD CONSTRAINT fk_efb96ab1e2 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY emails
    ADD CONSTRAINT fk_emails_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters
    ADD CONSTRAINT fk_f05c5e5a42 FOREIGN KEY (management_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY epics
    ADD CONSTRAINT fk_f081aa4489 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY boards
    ADD CONSTRAINT fk_f15266b5f9 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipeline_variables
    ADD CONSTRAINT fk_f29c5f4380 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY design_management_designs_versions
    ADD CONSTRAINT fk_f4d25ba00c FOREIGN KEY (version_id) REFERENCES design_management_versions(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_tag_create_access_levels
    ADD CONSTRAINT fk_f7dfda8c51 FOREIGN KEY (protected_tag_id) REFERENCES protected_tags(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_stages
    ADD CONSTRAINT fk_fb57e6cc56 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY system_note_metadata
    ADD CONSTRAINT fk_fbd87415c9 FOREIGN KEY (description_version_id) REFERENCES description_versions(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_requests
    ADD CONSTRAINT fk_fd82eae0b9 FOREIGN KEY (head_pipeline_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;

ALTER TABLE ONLY project_import_data
    ADD CONSTRAINT fk_ffb9ee3a10 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues
    ADD CONSTRAINT fk_ffed080f01 FOREIGN KEY (updated_by_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY geo_event_log
    ADD CONSTRAINT fk_geo_event_log_on_geo_event_id FOREIGN KEY (geo_event_id) REFERENCES geo_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY path_locks
    ADD CONSTRAINT fk_path_locks_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY personal_access_tokens
    ADD CONSTRAINT fk_personal_access_tokens_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_settings
    ADD CONSTRAINT fk_project_settings_push_rule_id FOREIGN KEY (push_rule_id) REFERENCES push_rules(id) ON DELETE SET NULL;

ALTER TABLE ONLY projects
    ADD CONSTRAINT fk_projects_namespace_id FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE RESTRICT;

ALTER TABLE ONLY protected_branch_merge_access_levels
    ADD CONSTRAINT fk_protected_branch_merge_access_levels_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_branch_push_access_levels
    ADD CONSTRAINT fk_protected_branch_push_access_levels_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_tag_create_access_levels
    ADD CONSTRAINT fk_protected_tag_create_access_levels_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rules
    ADD CONSTRAINT fk_rails_004ce82224 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY namespace_statistics
    ADD CONSTRAINT fk_rails_0062050394 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_elastic_stacks
    ADD CONSTRAINT fk_rails_026f219f46 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_rails_0434b48643 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ip_restrictions
    ADD CONSTRAINT fk_rails_04a93778d5 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY terraform_state_versions
    ADD CONSTRAINT fk_rails_04f176e239 FOREIGN KEY (terraform_state_id) REFERENCES terraform_states(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_report_results
    ADD CONSTRAINT fk_rails_056d298d48 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_daily_build_group_report_results
    ADD CONSTRAINT fk_rails_0667f7608c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_subscriptions_projects
    ADD CONSTRAINT fk_rails_0818751483 FOREIGN KEY (downstream_project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY trending_projects
    ADD CONSTRAINT fk_rails_09feecd872 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_deploy_tokens
    ADD CONSTRAINT fk_rails_0aca134388 FOREIGN KEY (deploy_token_id) REFERENCES deploy_tokens(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_conan_file_metadata
    ADD CONSTRAINT fk_rails_0afabd9328 FOREIGN KEY (package_file_id) REFERENCES packages_package_files(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_pending_states
    ADD CONSTRAINT fk_rails_0bbbfeaf9d FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_user_lists
    ADD CONSTRAINT fk_rails_0c716e079b FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_node_statuses
    ADD CONSTRAINT fk_rails_0ecc699c2a FOREIGN KEY (geo_node_id) REFERENCES geo_nodes(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_repository_states
    ADD CONSTRAINT fk_rails_0f2298ca8a FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_synced_attributes_metadata
    ADD CONSTRAINT fk_rails_0f4aa0981f FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_authorizations
    ADD CONSTRAINT fk_rails_0f84bb11f3 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY issue_email_participants
    ADD CONSTRAINT fk_rails_0fdfd8b811 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_context_commits
    ADD CONSTRAINT fk_rails_0fe0039f60 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_trace_chunks
    ADD CONSTRAINT fk_rails_1013b761f2 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_exports
    ADD CONSTRAINT fk_rails_1019162882 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY prometheus_alert_events
    ADD CONSTRAINT fk_rails_106f901176 FOREIGN KEY (prometheus_alert_id) REFERENCES prometheus_alerts(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_sources_projects
    ADD CONSTRAINT fk_rails_10a1eb379a FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY zoom_meetings
    ADD CONSTRAINT fk_rails_1190f0e0fa FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY gpg_signatures
    ADD CONSTRAINT fk_rails_11ae8cb9a7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_authorizations
    ADD CONSTRAINT fk_rails_11e7aa3ed9 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY description_versions
    ADD CONSTRAINT fk_rails_12b144011c FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_statistics
    ADD CONSTRAINT fk_rails_12c471002f FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_details
    ADD CONSTRAINT fk_rails_12e0b3043d FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY bulk_imports
    ADD CONSTRAINT fk_rails_130a09357d FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY diff_note_positions
    ADD CONSTRAINT fk_rails_13c7212859 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY users_security_dashboard_projects
    ADD CONSTRAINT fk_rails_150cd5682c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_report_results
    ADD CONSTRAINT fk_rails_16cb1ff064 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_deploy_tokens
    ADD CONSTRAINT fk_rails_170e03cbaf FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_cycle_analytics_project_stages
    ADD CONSTRAINT fk_rails_1722574860 FOREIGN KEY (start_event_label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_build_infos
    ADD CONSTRAINT fk_rails_17a9a0dffc FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;

ALTER TABLE ONLY clusters_applications_jupyter
    ADD CONSTRAINT fk_rails_17df21c98c FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_providers_aws
    ADD CONSTRAINT fk_rails_18983d9ea4 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY grafana_integrations
    ADD CONSTRAINT fk_rails_18d0e2b564 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_wiki_repositories
    ADD CONSTRAINT fk_rails_19755e374b FOREIGN KEY (shard_id) REFERENCES shards(id) ON DELETE RESTRICT;

ALTER TABLE ONLY open_project_tracker_data
    ADD CONSTRAINT fk_rails_1987546e48 FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

ALTER TABLE ONLY gpg_signatures
    ADD CONSTRAINT fk_rails_19d4f1c6f9 FOREIGN KEY (gpg_key_subkey_id) REFERENCES gpg_key_subkeys(id) ON DELETE SET NULL;

ALTER TABLE ONLY vulnerability_user_mentions
    ADD CONSTRAINT fk_rails_1a41c485cd FOREIGN KEY (vulnerability_id) REFERENCES vulnerabilities(id) ON DELETE CASCADE;

ALTER TABLE ONLY issuable_slas
    ADD CONSTRAINT fk_rails_1b8768cd63 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_assignees
    ADD CONSTRAINT fk_rails_1c0ff59e82 FOREIGN KEY (assignee_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY epic_user_mentions
    ADD CONSTRAINT fk_rails_1c65976a49 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY approver_groups
    ADD CONSTRAINT fk_rails_1cdcbd7723 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_tags
    ADD CONSTRAINT fk_rails_1dfc868911 FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_repository_created_events
    ADD CONSTRAINT fk_rails_1f49e46a61 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rules_groups
    ADD CONSTRAINT fk_rails_2020a7124a FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_feedback
    ADD CONSTRAINT fk_rails_20976e6fd9 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;

ALTER TABLE ONLY user_statuses
    ADD CONSTRAINT fk_rails_2178592333 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY users_ops_dashboard_projects
    ADD CONSTRAINT fk_rails_220a0562db FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_runners
    ADD CONSTRAINT fk_rails_22388594e9 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY service_desk_settings
    ADD CONSTRAINT fk_rails_223a296a85 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY saml_group_links
    ADD CONSTRAINT fk_rails_22e312c530 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_custom_attributes
    ADD CONSTRAINT fk_rails_246e0db83a FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_agents
    ADD CONSTRAINT fk_rails_25e9fc2d5d FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY boards_epic_user_preferences
    ADD CONSTRAINT fk_rails_268c57d62d FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_wiki_repositories
    ADD CONSTRAINT fk_rails_26f867598c FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY lfs_file_locks
    ADD CONSTRAINT fk_rails_27a1d98fa8 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_alerting_settings
    ADD CONSTRAINT fk_rails_27a84b407d FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY dast_site_validations
    ADD CONSTRAINT fk_rails_285c617324 FOREIGN KEY (dast_site_token_id) REFERENCES dast_site_tokens(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_state_events
    ADD CONSTRAINT fk_rails_29af06892a FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY reviews
    ADD CONSTRAINT fk_rails_29e6f859c4 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY draft_notes
    ADD CONSTRAINT fk_rails_2a8dac9901 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_group_links
    ADD CONSTRAINT fk_rails_2b2353ca49 FOREIGN KEY (shared_with_group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_repository_updated_events
    ADD CONSTRAINT fk_rails_2b70854c08 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_branch_unprotect_access_levels
    ADD CONSTRAINT fk_rails_2d2aba21ef FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_freeze_periods
    ADD CONSTRAINT fk_rails_2e02bbd1a6 FOREIGN KEY (project_id) REFERENCES projects(id);

ALTER TABLE ONLY issuable_severities
    ADD CONSTRAINT fk_rails_2fbb74ad6d FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY saml_providers
    ADD CONSTRAINT fk_rails_306d459be7 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_state_events
    ADD CONSTRAINT fk_rails_3112bba7dc FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_diff_commits
    ADD CONSTRAINT fk_rails_316aaceda3 FOREIGN KEY (merge_request_diff_id) REFERENCES merge_request_diffs(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_import_states
    ADD CONSTRAINT fk_rails_31c3e0503a FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY zoom_meetings
    ADD CONSTRAINT fk_rails_3263f29616 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY container_repositories
    ADD CONSTRAINT fk_rails_32f7bf5aad FOREIGN KEY (project_id) REFERENCES projects(id);

ALTER TABLE ONLY clusters_applications_jupyter
    ADD CONSTRAINT fk_rails_331f0aff78 FOREIGN KEY (oauth_application_id) REFERENCES oauth_applications(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_request_metrics
    ADD CONSTRAINT fk_rails_33ae169d48 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY suggestions
    ADD CONSTRAINT fk_rails_33b03a535c FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY requirements
    ADD CONSTRAINT fk_rails_33fed8aa4e FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY metrics_dashboard_annotations
    ADD CONSTRAINT fk_rails_345ab51043 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY wiki_page_slugs
    ADD CONSTRAINT fk_rails_358b46be14 FOREIGN KEY (wiki_page_meta_id) REFERENCES wiki_page_meta(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_labels
    ADD CONSTRAINT fk_rails_362b0600a3 FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_blocks
    ADD CONSTRAINT fk_rails_364d4bea8b FOREIGN KEY (blocked_merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_reviewers
    ADD CONSTRAINT fk_rails_3704a66140 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_cycle_analytics_project_stages
    ADD CONSTRAINT fk_rails_3829e49b66 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY issue_user_mentions
    ADD CONSTRAINT fk_rails_3861d9fefa FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY namespace_settings
    ADD CONSTRAINT fk_rails_3896d4fae5 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY self_managed_prometheus_alert_events
    ADD CONSTRAINT fk_rails_3936dadc62 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_project_rules_groups
    ADD CONSTRAINT fk_rails_396841e79e FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY self_managed_prometheus_alert_events
    ADD CONSTRAINT fk_rails_39d83d1b65 FOREIGN KEY (environment_id) REFERENCES environments(id) ON DELETE CASCADE;

ALTER TABLE ONLY chat_teams
    ADD CONSTRAINT fk_rails_3b543909cb FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_needs
    ADD CONSTRAINT fk_rails_3cf221d4ed FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_groups
    ADD CONSTRAINT fk_rails_3d28377556 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY note_diff_files
    ADD CONSTRAINT fk_rails_3d66047aeb FOREIGN KEY (diff_note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY snippet_user_mentions
    ADD CONSTRAINT fk_rails_3e00189191 FOREIGN KEY (snippet_id) REFERENCES snippets(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_helm
    ADD CONSTRAINT fk_rails_3e2b1c06bc FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY epic_user_mentions
    ADD CONSTRAINT fk_rails_3eaf4d88cc FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_cycle_analytics_project_stages
    ADD CONSTRAINT fk_rails_3ec9fd7912 FOREIGN KEY (end_event_label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_assignees
    ADD CONSTRAINT fk_rails_3f6f926bd5 FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE;

ALTER TABLE ONLY description_versions
    ADD CONSTRAINT fk_rails_3ff658220b FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_kubernetes_namespaces
    ADD CONSTRAINT fk_rails_40cc7ccbc3 FOREIGN KEY (cluster_project_id) REFERENCES cluster_projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY geo_node_namespace_links
    ADD CONSTRAINT fk_rails_41ff5fb854 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY epic_issues
    ADD CONSTRAINT fk_rails_4209981af6 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_refs
    ADD CONSTRAINT fk_rails_4249db8cc3 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_resources
    ADD CONSTRAINT fk_rails_430336af2d FOREIGN KEY (resource_group_id) REFERENCES ci_resource_groups(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_fluentd
    ADD CONSTRAINT fk_rails_4319b1dcd2 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_strategies_user_lists
    ADD CONSTRAINT fk_rails_43241e8d29 FOREIGN KEY (strategy_id) REFERENCES operations_strategies(id) ON DELETE CASCADE;

ALTER TABLE ONLY lfs_file_locks
    ADD CONSTRAINT fk_rails_43df7a0412 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_assignees
    ADD CONSTRAINT fk_rails_443443ce6f FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_dependency_links
    ADD CONSTRAINT fk_rails_4437bf4070 FOREIGN KEY (dependency_id) REFERENCES packages_dependencies(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_auto_devops
    ADD CONSTRAINT fk_rails_45436b12b2 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_requests_closing_issues
    ADD CONSTRAINT fk_rails_458eda8667 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_environment_deploy_access_levels
    ADD CONSTRAINT fk_rails_45cc02a931 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY prometheus_alert_events
    ADD CONSTRAINT fk_rails_4675865839 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY smartcard_identities
    ADD CONSTRAINT fk_rails_4689f889a9 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_feedback
    ADD CONSTRAINT fk_rails_472f69b043 FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_custom_attributes
    ADD CONSTRAINT fk_rails_47b91868a8 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipeline_artifacts
    ADD CONSTRAINT fk_rails_4a70390ca6 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_deletion_schedules
    ADD CONSTRAINT fk_rails_4b8c694a6c FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY design_management_designs
    ADD CONSTRAINT fk_rails_4bb1073360 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY issue_metrics
    ADD CONSTRAINT fk_rails_4bb543d85d FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_metrics_settings
    ADD CONSTRAINT fk_rails_4c6037ee4f FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY prometheus_metrics
    ADD CONSTRAINT fk_rails_4c8957a707 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY scim_identities
    ADD CONSTRAINT fk_rails_4d2056ebd9 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY snippet_user_mentions
    ADD CONSTRAINT fk_rails_4d3f96b2cb FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY deployment_clusters
    ADD CONSTRAINT fk_rails_4e6243e120 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_repository_renamed_events
    ADD CONSTRAINT fk_rails_4e6524febb FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY aws_roles
    ADD CONSTRAINT fk_rails_4ed56f4720 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY security_scans
    ADD CONSTRAINT fk_rails_4ef1e6b4c6 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_diff_files
    ADD CONSTRAINT fk_rails_501aa0a391 FOREIGN KEY (merge_request_diff_id) REFERENCES merge_request_diffs(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_iteration_events
    ADD CONSTRAINT fk_rails_501fa15d69 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY status_page_settings
    ADD CONSTRAINT fk_rails_506e5ba391 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_repository_storage_moves
    ADD CONSTRAINT fk_rails_5106dbd44a FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY bulk_import_configurations
    ADD CONSTRAINT fk_rails_536b96bff1 FOREIGN KEY (bulk_import_id) REFERENCES bulk_imports(id) ON DELETE CASCADE;

ALTER TABLE ONLY x509_commit_signatures
    ADD CONSTRAINT fk_rails_53fe41188f FOREIGN KEY (x509_certificate_id) REFERENCES x509_certificates(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_cycle_analytics_group_value_streams
    ADD CONSTRAINT fk_rails_540627381a FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_node_namespace_links
    ADD CONSTRAINT fk_rails_546bf08d3e FOREIGN KEY (geo_node_id) REFERENCES geo_nodes(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_knative
    ADD CONSTRAINT fk_rails_54fc91e0a0 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY terraform_states
    ADD CONSTRAINT fk_rails_558901b030 FOREIGN KEY (locked_by_user_id) REFERENCES users(id);

ALTER TABLE ONLY group_deploy_keys
    ADD CONSTRAINT fk_rails_5682fc07f8 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT;

ALTER TABLE ONLY experiment_users
    ADD CONSTRAINT fk_rails_56d4708b4a FOREIGN KEY (experiment_id) REFERENCES experiments(id) ON DELETE CASCADE;

ALTER TABLE ONLY issue_user_mentions
    ADD CONSTRAINT fk_rails_57581fda73 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_assignees
    ADD CONSTRAINT fk_rails_579d375628 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_cilium
    ADD CONSTRAINT fk_rails_59dc12eea6 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_cycle_analytics_group_stages
    ADD CONSTRAINT fk_rails_5a22f40223 FOREIGN KEY (start_event_label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY badges
    ADD CONSTRAINT fk_rails_5a7c055bdc FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_label_events
    ADD CONSTRAINT fk_rails_5ac1d2fc24 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rules_groups
    ADD CONSTRAINT fk_rails_5b2ecf6139 FOREIGN KEY (approval_merge_request_rule_id) REFERENCES approval_merge_request_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY namespace_limits
    ADD CONSTRAINT fk_rails_5b3f2bc334 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_environment_deploy_access_levels
    ADD CONSTRAINT fk_rails_5b9f6970fe FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_branch_unprotect_access_levels
    ADD CONSTRAINT fk_rails_5be1abfc25 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_providers_gcp
    ADD CONSTRAINT fk_rails_5c2c3bc814 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY insights
    ADD CONSTRAINT fk_rails_5c4391f60a FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_scanners
    ADD CONSTRAINT fk_rails_5c9d42a221 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY reviews
    ADD CONSTRAINT fk_rails_5ca11d8c31 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY epic_issues
    ADD CONSTRAINT fk_rails_5d942936b4 FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_weight_events
    ADD CONSTRAINT fk_rails_5eb5cb92a1 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_project_rules
    ADD CONSTRAINT fk_rails_5fb4dd100b FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_highest_roles
    ADD CONSTRAINT fk_rails_60f6c325a6 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY dependency_proxy_group_settings
    ADD CONSTRAINT fk_rails_616ddd680a FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_deploy_tokens
    ADD CONSTRAINT fk_rails_61a572b41a FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY status_page_published_incidents
    ADD CONSTRAINT fk_rails_61e5493940 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY deployment_clusters
    ADD CONSTRAINT fk_rails_6359a164df FOREIGN KEY (deployment_id) REFERENCES deployments(id) ON DELETE CASCADE;

ALTER TABLE ONLY evidences
    ADD CONSTRAINT fk_rails_6388b435a6 FOREIGN KEY (release_id) REFERENCES releases(id) ON DELETE CASCADE;

ALTER TABLE ONLY jira_imports
    ADD CONSTRAINT fk_rails_63cbe52ada FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_occurrence_pipelines
    ADD CONSTRAINT fk_rails_6421e35d7d FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_deploy_tokens
    ADD CONSTRAINT fk_rails_6477b01f6b FOREIGN KEY (deploy_token_id) REFERENCES deploy_tokens(id) ON DELETE CASCADE;

ALTER TABLE ONLY reviews
    ADD CONSTRAINT fk_rails_64798be025 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_feature_flags
    ADD CONSTRAINT fk_rails_648e241be7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_sources_projects
    ADD CONSTRAINT fk_rails_64b6855cbc FOREIGN KEY (source_project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_group_recent_visits
    ADD CONSTRAINT fk_rails_64bfc19bc5 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rule_sources
    ADD CONSTRAINT fk_rails_64e8ed3c7e FOREIGN KEY (approval_project_rule_id) REFERENCES approval_project_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipeline_chat_data
    ADD CONSTRAINT fk_rails_64ebfab6b3 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_project_rules_protected_branches
    ADD CONSTRAINT fk_rails_65203aa786 FOREIGN KEY (approval_project_rule_id) REFERENCES approval_project_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY design_management_versions
    ADD CONSTRAINT fk_rails_6574200d99 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rules_approved_approvers
    ADD CONSTRAINT fk_rails_6577725edb FOREIGN KEY (approval_merge_request_rule_id) REFERENCES approval_merge_request_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_feature_flags_clients
    ADD CONSTRAINT fk_rails_6650ed902c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY web_hook_logs
    ADD CONSTRAINT fk_rails_666826e111 FOREIGN KEY (web_hook_id) REFERENCES web_hooks(id) ON DELETE CASCADE;

ALTER TABLE ONLY jira_imports
    ADD CONSTRAINT fk_rails_675d38c03b FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE SET NULL;

ALTER TABLE ONLY resource_iteration_events
    ADD CONSTRAINT fk_rails_6830c13ac1 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_hashed_storage_migrated_events
    ADD CONSTRAINT fk_rails_687ed7d7c5 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY plan_limits
    ADD CONSTRAINT fk_rails_69f8b6184f FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_feature_flags_issues
    ADD CONSTRAINT fk_rails_6a8856ca4f FOREIGN KEY (feature_flag_id) REFERENCES operations_feature_flags(id) ON DELETE CASCADE;

ALTER TABLE ONLY prometheus_alerts
    ADD CONSTRAINT fk_rails_6d9b283465 FOREIGN KEY (environment_id) REFERENCES environments(id) ON DELETE CASCADE;

ALTER TABLE ONLY term_agreements
    ADD CONSTRAINT fk_rails_6ea6520e4a FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_compliance_framework_settings
    ADD CONSTRAINT fk_rails_6f5294f16c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY users_security_dashboard_projects
    ADD CONSTRAINT fk_rails_6f6cf8e66e FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY dast_sites
    ADD CONSTRAINT fk_rails_6febb6ea9c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_builds_runner_session
    ADD CONSTRAINT fk_rails_70707857d3 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY list_user_preferences
    ADD CONSTRAINT fk_rails_70b2ef5ce2 FOREIGN KEY (list_id) REFERENCES lists(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_custom_attributes
    ADD CONSTRAINT fk_rails_719c3dccc5 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY security_findings
    ADD CONSTRAINT fk_rails_729b763a54 FOREIGN KEY (scanner_id) REFERENCES vulnerability_scanners(id) ON DELETE CASCADE;

ALTER TABLE ONLY dast_scanner_profiles
    ADD CONSTRAINT fk_rails_72a8ba7141 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_historical_statistics
    ADD CONSTRAINT fk_rails_72b73ed023 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY slack_integrations
    ADD CONSTRAINT fk_rails_73db19721a FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

ALTER TABLE ONLY custom_emoji
    ADD CONSTRAINT fk_rails_745925b412 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY dast_site_profiles
    ADD CONSTRAINT fk_rails_747dc64abc FOREIGN KEY (dast_site_id) REFERENCES dast_sites(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_context_commit_diff_files
    ADD CONSTRAINT fk_rails_74a00a1787 FOREIGN KEY (merge_request_context_commit_id) REFERENCES merge_request_context_commits(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_ingress
    ADD CONSTRAINT fk_rails_753a7b41c1 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY release_links
    ADD CONSTRAINT fk_rails_753be7ae29 FOREIGN KEY (release_id) REFERENCES releases(id) ON DELETE CASCADE;

ALTER TABLE ONLY milestone_releases
    ADD CONSTRAINT fk_rails_754f27dbfa FOREIGN KEY (release_id) REFERENCES releases(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_repositories_changed_events
    ADD CONSTRAINT fk_rails_75ec0fefcc FOREIGN KEY (geo_node_id) REFERENCES geo_nodes(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_label_events
    ADD CONSTRAINT fk_rails_75efb0a653 FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY x509_certificates
    ADD CONSTRAINT fk_rails_76479fb5b4 FOREIGN KEY (x509_issuer_id) REFERENCES x509_issuers(id) ON DELETE CASCADE;

ALTER TABLE ONLY pages_domain_acme_orders
    ADD CONSTRAINT fk_rails_76581b1c16 FOREIGN KEY (pages_domain_id) REFERENCES pages_domains(id) ON DELETE CASCADE;

ALTER TABLE ONLY boards_epic_user_preferences
    ADD CONSTRAINT fk_rails_76c4e9732d FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_subscriptions_projects
    ADD CONSTRAINT fk_rails_7871f9a97b FOREIGN KEY (upstream_project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY terraform_states
    ADD CONSTRAINT fk_rails_78f54ca485 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY software_license_policies
    ADD CONSTRAINT fk_rails_7a7a2a92de FOREIGN KEY (software_license_id) REFERENCES software_licenses(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_repositories
    ADD CONSTRAINT fk_rails_7a810d4121 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_scopes
    ADD CONSTRAINT fk_rails_7a9358853b FOREIGN KEY (strategy_id) REFERENCES operations_strategies(id) ON DELETE CASCADE;

ALTER TABLE ONLY milestone_releases
    ADD CONSTRAINT fk_rails_7ae0756a2d FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_state_events
    ADD CONSTRAINT fk_rails_7ddc5f7457 FOREIGN KEY (source_merge_request_id) REFERENCES merge_requests(id) ON DELETE SET NULL;

ALTER TABLE ONLY application_settings
    ADD CONSTRAINT fk_rails_7e112a9599 FOREIGN KEY (instance_administration_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY clusters_kubernetes_namespaces
    ADD CONSTRAINT fk_rails_7e7688ecaf FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rules_users
    ADD CONSTRAINT fk_rails_80e6801803 FOREIGN KEY (approval_merge_request_rule_id) REFERENCES approval_merge_request_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY required_code_owners_sections
    ADD CONSTRAINT fk_rails_817708cf2d FOREIGN KEY (protected_branch_id) REFERENCES protected_branches(id) ON DELETE CASCADE;

ALTER TABLE ONLY dast_site_profiles
    ADD CONSTRAINT fk_rails_83e309d69e FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY boards_epic_user_preferences
    ADD CONSTRAINT fk_rails_851fe1510a FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY deployment_merge_requests
    ADD CONSTRAINT fk_rails_86a6d8bf12 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_language_trend_repository_languages
    ADD CONSTRAINT fk_rails_86cc9aef5f FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_diff_details
    ADD CONSTRAINT fk_rails_86f4d24ecd FOREIGN KEY (merge_request_diff_id) REFERENCES merge_request_diffs(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_crossplane
    ADD CONSTRAINT fk_rails_87186702df FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_runner_namespaces
    ADD CONSTRAINT fk_rails_8767676b7a FOREIGN KEY (runner_id) REFERENCES ci_runners(id) ON DELETE CASCADE;

ALTER TABLE ONLY software_license_policies
    ADD CONSTRAINT fk_rails_87b2247ce5 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_environment_deploy_access_levels
    ADD CONSTRAINT fk_rails_898a13b650 FOREIGN KEY (protected_environment_id) REFERENCES protected_environments(id) ON DELETE CASCADE;

ALTER TABLE ONLY snippet_repositories
    ADD CONSTRAINT fk_rails_8afd7e2f71 FOREIGN KEY (snippet_id) REFERENCES snippets(id) ON DELETE CASCADE;

ALTER TABLE ONLY gpg_key_subkeys
    ADD CONSTRAINT fk_rails_8b2c90b046 FOREIGN KEY (gpg_key_id) REFERENCES gpg_keys(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_user_preferences
    ADD CONSTRAINT fk_rails_8b3b23ce82 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY allowed_email_domains
    ADD CONSTRAINT fk_rails_8b5da859f9 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_projects
    ADD CONSTRAINT fk_rails_8b8c5caf07 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_pages_metadata
    ADD CONSTRAINT fk_rails_8c28a61485 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_conan_metadata
    ADD CONSTRAINT fk_rails_8c68cfec8b FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_feedback
    ADD CONSTRAINT fk_rails_8c77e5891a FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_pipeline_messages
    ADD CONSTRAINT fk_rails_8d3b04e3e1 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rules_approved_approvers
    ADD CONSTRAINT fk_rails_8dc94cff4d FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY design_user_mentions
    ADD CONSTRAINT fk_rails_8de8c6d632 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_kubernetes_namespaces
    ADD CONSTRAINT fk_rails_8df789f3ab FOREIGN KEY (environment_id) REFERENCES environments(id) ON DELETE SET NULL;

ALTER TABLE ONLY alert_management_alert_user_mentions
    ADD CONSTRAINT fk_rails_8e48eca0fe FOREIGN KEY (alert_management_alert_id) REFERENCES alert_management_alerts(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_daily_statistics
    ADD CONSTRAINT fk_rails_8e549b272d FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_pipelines_config
    ADD CONSTRAINT fk_rails_906c9a2533 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_project_rules_groups
    ADD CONSTRAINT fk_rails_9071e863d1 FOREIGN KEY (approval_project_rule_id) REFERENCES approval_project_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_occurrences
    ADD CONSTRAINT fk_rails_90fed4faba FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_reset_checksum_events
    ADD CONSTRAINT fk_rails_910a06f12b FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_error_tracking_settings
    ADD CONSTRAINT fk_rails_910a2b8bd9 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY list_user_preferences
    ADD CONSTRAINT fk_rails_916d72cafd FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_labels
    ADD CONSTRAINT fk_rails_9374a16edd FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE;

ALTER TABLE ONLY alert_management_alert_assignees
    ADD CONSTRAINT fk_rails_93c0f6703b FOREIGN KEY (alert_id) REFERENCES alert_management_alerts(id) ON DELETE CASCADE;

ALTER TABLE ONLY scim_identities
    ADD CONSTRAINT fk_rails_9421a0bffb FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_pypi_metadata
    ADD CONSTRAINT fk_rails_9698717cdd FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_dependency_links
    ADD CONSTRAINT fk_rails_96ef1c00d3 FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_label_events
    ADD CONSTRAINT fk_rails_9851a00031 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_job_artifacts
    ADD CONSTRAINT fk_rails_9862d392f9 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_project_recent_visits
    ADD CONSTRAINT fk_rails_98f8843922 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_kubernetes_namespaces
    ADD CONSTRAINT fk_rails_98fe21e486 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY pages_deployments
    ADD CONSTRAINT fk_rails_993b88f59a FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_exports
    ADD CONSTRAINT fk_rails_9aff2c3b45 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY users_ops_dashboard_projects
    ADD CONSTRAINT fk_rails_9b4ebf005b FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_incident_management_settings
    ADD CONSTRAINT fk_rails_9c2ea1b7dd FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY gpg_keys
    ADD CONSTRAINT fk_rails_9d1f5d8719 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_language_trend_repository_languages
    ADD CONSTRAINT fk_rails_9d851d566c FOREIGN KEY (programming_language_id) REFERENCES programming_languages(id) ON DELETE CASCADE;

ALTER TABLE ONLY badges
    ADD CONSTRAINT fk_rails_9df4a56538 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters_applications_cert_managers
    ADD CONSTRAINT fk_rails_9e4f2cb4b2 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_milestone_events
    ADD CONSTRAINT fk_rails_a006df5590 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY namespace_root_storage_statistics
    ADD CONSTRAINT fk_rails_a0702c430b FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_aliases
    ADD CONSTRAINT fk_rails_a1804f74a7 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_user_mentions
    ADD CONSTRAINT fk_rails_a18600f210 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY todos
    ADD CONSTRAINT fk_rails_a27c483435 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY jira_tracker_data
    ADD CONSTRAINT fk_rails_a299066916 FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_environments
    ADD CONSTRAINT fk_rails_a354313d11 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY jira_connect_subscriptions
    ADD CONSTRAINT fk_rails_a3c10bcf7d FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY fork_network_members
    ADD CONSTRAINT fk_rails_a40860a1ca FOREIGN KEY (fork_network_id) REFERENCES fork_networks(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_feature_flag_scopes
    ADD CONSTRAINT fk_rails_a50a04d0a4 FOREIGN KEY (feature_flag_id) REFERENCES operations_feature_flags(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_projects
    ADD CONSTRAINT fk_rails_a5a958bca1 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY commit_user_mentions
    ADD CONSTRAINT fk_rails_a6760813e0 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_identifiers
    ADD CONSTRAINT fk_rails_a67a16c885 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_preferences
    ADD CONSTRAINT fk_rails_a69bfcfd81 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY sentry_issues
    ADD CONSTRAINT fk_rails_a6a9612965 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY repository_languages
    ADD CONSTRAINT fk_rails_a750ec87a8 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_milestone_events
    ADD CONSTRAINT fk_rails_a788026e85 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY term_agreements
    ADD CONSTRAINT fk_rails_a88721bcdf FOREIGN KEY (term_id) REFERENCES application_setting_terms(id);

ALTER TABLE ONLY ci_pipeline_artifacts
    ADD CONSTRAINT fk_rails_a9e811a466 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_user_mentions
    ADD CONSTRAINT fk_rails_aa1b2961b1 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY x509_commit_signatures
    ADD CONSTRAINT fk_rails_ab07452314 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_trace_sections
    ADD CONSTRAINT fk_rails_ab7c104e26 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_iteration_events
    ADD CONSTRAINT fk_rails_abf5d4affa FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY clusters
    ADD CONSTRAINT fk_rails_ac3a663d79 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY packages_composer_metadata
    ADD CONSTRAINT fk_rails_ad48c2e5bb FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_cycle_analytics_group_stages
    ADD CONSTRAINT fk_rails_ae5da3409b FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY metrics_dashboard_annotations
    ADD CONSTRAINT fk_rails_aeb11a7643 FOREIGN KEY (environment_id) REFERENCES environments(id) ON DELETE CASCADE;

ALTER TABLE ONLY pool_repositories
    ADD CONSTRAINT fk_rails_af3f8c5d62 FOREIGN KEY (shard_id) REFERENCES shards(id) ON DELETE RESTRICT;

ALTER TABLE ONLY vulnerability_statistics
    ADD CONSTRAINT fk_rails_af61a7df4c FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_label_events
    ADD CONSTRAINT fk_rails_b126799f57 FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE SET NULL;

ALTER TABLE ONLY webauthn_registrations
    ADD CONSTRAINT fk_rails_b15c016782 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_build_infos
    ADD CONSTRAINT fk_rails_b18868292d FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY authentication_events
    ADD CONSTRAINT fk_rails_b204656a54 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_trains
    ADD CONSTRAINT fk_rails_b29261ce31 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_project_recent_visits
    ADD CONSTRAINT fk_rails_b315dd0c80 FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues_prometheus_alert_events
    ADD CONSTRAINT fk_rails_b32edb790f FOREIGN KEY (prometheus_alert_event_id) REFERENCES prometheus_alert_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_trains
    ADD CONSTRAINT fk_rails_b374b5225d FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY application_settings
    ADD CONSTRAINT fk_rails_b53e481273 FOREIGN KEY (custom_project_templates_group_id) REFERENCES namespaces(id) ON DELETE SET NULL;

ALTER TABLE ONLY namespace_aggregation_schedules
    ADD CONSTRAINT fk_rails_b565c8d16c FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_project_rules_protected_branches
    ADD CONSTRAINT fk_rails_b7567b031b FOREIGN KEY (protected_branch_id) REFERENCES protected_branches(id) ON DELETE CASCADE;

ALTER TABLE ONLY alerts_service_data
    ADD CONSTRAINT fk_rails_b93215a42c FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_trains
    ADD CONSTRAINT fk_rails_b9d67af01d FOREIGN KEY (target_project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_project_rules_users
    ADD CONSTRAINT fk_rails_b9e9394efb FOREIGN KEY (approval_project_rule_id) REFERENCES approval_project_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY lists
    ADD CONSTRAINT fk_rails_baed5f39b7 FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE CASCADE;

ALTER TABLE ONLY security_findings
    ADD CONSTRAINT fk_rails_bb63863cf1 FOREIGN KEY (scan_id) REFERENCES security_scans(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rules_users
    ADD CONSTRAINT fk_rails_bc8972fa55 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY external_pull_requests
    ADD CONSTRAINT fk_rails_bcae9b5c7b FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY elasticsearch_indexed_projects
    ADD CONSTRAINT fk_rails_bd13bbdc3d FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY elasticsearch_indexed_namespaces
    ADD CONSTRAINT fk_rails_bdcf044f37 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_occurrence_identifiers
    ADD CONSTRAINT fk_rails_be2e49e1d0 FOREIGN KEY (identifier_id) REFERENCES vulnerability_identifiers(id) ON DELETE CASCADE;

ALTER TABLE ONLY alert_management_http_integrations
    ADD CONSTRAINT fk_rails_bec49f52cc FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_occurrences
    ADD CONSTRAINT fk_rails_bf5b788ca7 FOREIGN KEY (scanner_id) REFERENCES vulnerability_scanners(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_weight_events
    ADD CONSTRAINT fk_rails_bfc406b47c FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY design_management_designs
    ADD CONSTRAINT fk_rails_bfe283ec3c FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY atlassian_identities
    ADD CONSTRAINT fk_rails_c02928bc18 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY serverless_domain_cluster
    ADD CONSTRAINT fk_rails_c09009dee1 FOREIGN KEY (pages_domain_id) REFERENCES pages_domains(id) ON DELETE CASCADE;

ALTER TABLE ONLY labels
    ADD CONSTRAINT fk_rails_c1ac5161d8 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY backup_labels
    ADD CONSTRAINT fk_rails_c1ac5161d8 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_feature_usages
    ADD CONSTRAINT fk_rails_c22a50024b FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_canonical_emails
    ADD CONSTRAINT fk_rails_c2bd828b51 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_repositories
    ADD CONSTRAINT fk_rails_c3258dc63b FOREIGN KEY (shard_id) REFERENCES shards(id) ON DELETE RESTRICT;

ALTER TABLE ONLY packages_nuget_dependency_link_metadata
    ADD CONSTRAINT fk_rails_c3313ee2e4 FOREIGN KEY (dependency_link_id) REFERENCES packages_dependency_links(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_deploy_keys_groups
    ADD CONSTRAINT fk_rails_c3854f19f5 FOREIGN KEY (group_deploy_key_id) REFERENCES group_deploy_keys(id) ON DELETE CASCADE;

ALTER TABLE ONLY pages_deployments
    ADD CONSTRAINT fk_rails_c3a90cf29b FOREIGN KEY (ci_build_id) REFERENCES ci_builds(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_request_user_mentions
    ADD CONSTRAINT fk_rails_c440b9ea31 FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_job_artifacts
    ADD CONSTRAINT fk_rails_c5137cb2c1 FOREIGN KEY (job_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_events
    ADD CONSTRAINT fk_rails_c6c20d0094 FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE SET NULL;

ALTER TABLE ONLY project_settings
    ADD CONSTRAINT fk_rails_c6df6e6328 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY container_expiration_policies
    ADD CONSTRAINT fk_rails_c7360f09ad FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY wiki_page_meta
    ADD CONSTRAINT fk_rails_c7a0c59cf1 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY scim_oauth_access_tokens
    ADD CONSTRAINT fk_rails_c84404fb6c FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_occurrences
    ADD CONSTRAINT fk_rails_c8661a61eb FOREIGN KEY (primary_identifier_id) REFERENCES vulnerability_identifiers(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_export_jobs
    ADD CONSTRAINT fk_rails_c88d8db2e1 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_state_events
    ADD CONSTRAINT fk_rails_c913c64977 FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_milestone_events
    ADD CONSTRAINT fk_rails_c940fb9fc5 FOREIGN KEY (milestone_id) REFERENCES milestones(id) ON DELETE CASCADE;

ALTER TABLE ONLY gpg_signatures
    ADD CONSTRAINT fk_rails_c97176f5f7 FOREIGN KEY (gpg_key_id) REFERENCES gpg_keys(id) ON DELETE SET NULL;

ALTER TABLE ONLY board_group_recent_visits
    ADD CONSTRAINT fk_rails_ca04c38720 FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues_self_managed_prometheus_alert_events
    ADD CONSTRAINT fk_rails_cc5d88bbb0 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_strategies_user_lists
    ADD CONSTRAINT fk_rails_ccb7e4bc0b FOREIGN KEY (user_list_id) REFERENCES operations_user_lists(id) ON DELETE CASCADE;

ALTER TABLE ONLY issue_tracker_data
    ADD CONSTRAINT fk_rails_ccc0840427 FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_milestone_events
    ADD CONSTRAINT fk_rails_cedf8cce4d FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY resource_iteration_events
    ADD CONSTRAINT fk_rails_cee126f66c FOREIGN KEY (iteration_id) REFERENCES sprints(id) ON DELETE CASCADE;

ALTER TABLE ONLY epic_metrics
    ADD CONSTRAINT fk_rails_d071904753 FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT fk_rails_d0c8bda804 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_strategies
    ADD CONSTRAINT fk_rails_d183b6e6dd FOREIGN KEY (feature_flag_id) REFERENCES operations_feature_flags(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_agent_tokens
    ADD CONSTRAINT fk_rails_d1d26abc25 FOREIGN KEY (agent_id) REFERENCES cluster_agents(id) ON DELETE CASCADE;

ALTER TABLE ONLY requirements_management_test_reports
    ADD CONSTRAINT fk_rails_d1e8b498bf FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY pool_repositories
    ADD CONSTRAINT fk_rails_d2711daad4 FOREIGN KEY (source_project_id) REFERENCES projects(id) ON DELETE SET NULL;

ALTER TABLE ONLY group_group_links
    ADD CONSTRAINT fk_rails_d3a0488427 FOREIGN KEY (shared_group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_issue_links
    ADD CONSTRAINT fk_rails_d459c19036 FOREIGN KEY (vulnerability_id) REFERENCES vulnerabilities(id) ON DELETE CASCADE;

ALTER TABLE ONLY alert_management_alert_assignees
    ADD CONSTRAINT fk_rails_d47570ac62 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY geo_hashed_storage_attachments_events
    ADD CONSTRAINT fk_rails_d496b088e9 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_reviewers
    ADD CONSTRAINT fk_rails_d9fec24b9d FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY jira_imports
    ADD CONSTRAINT fk_rails_da617096ce FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY dependency_proxy_blobs
    ADD CONSTRAINT fk_rails_db58bbc5d7 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues_prometheus_alert_events
    ADD CONSTRAINT fk_rails_db5b756534 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_user_preferences
    ADD CONSTRAINT fk_rails_dbebdaa8fe FOREIGN KEY (board_id) REFERENCES boards(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_occurrence_pipelines
    ADD CONSTRAINT fk_rails_dc3ae04693 FOREIGN KEY (occurrence_id) REFERENCES vulnerability_occurrences(id) ON DELETE CASCADE;

ALTER TABLE ONLY deployment_merge_requests
    ADD CONSTRAINT fk_rails_dcbce9f4df FOREIGN KEY (deployment_id) REFERENCES deployments(id) ON DELETE CASCADE;

ALTER TABLE ONLY user_callouts
    ADD CONSTRAINT fk_rails_ddfdd80f3d FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_feedback
    ADD CONSTRAINT fk_rails_debd54e456 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY analytics_cycle_analytics_group_stages
    ADD CONSTRAINT fk_rails_dfb37c880d FOREIGN KEY (end_event_label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY label_priorities
    ADD CONSTRAINT fk_rails_e161058b0f FOREIGN KEY (label_id) REFERENCES labels(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_packages
    ADD CONSTRAINT fk_rails_e1ac527425 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_platforms_kubernetes
    ADD CONSTRAINT fk_rails_e1e2cf841a FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_builds_metadata
    ADD CONSTRAINT fk_rails_e20479742e FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_occurrence_identifiers
    ADD CONSTRAINT fk_rails_e4ef6d027c FOREIGN KEY (occurrence_id) REFERENCES vulnerability_occurrences(id) ON DELETE CASCADE;

ALTER TABLE ONLY serverless_domain_cluster
    ADD CONSTRAINT fk_rails_e59e868733 FOREIGN KEY (clusters_applications_knative_id) REFERENCES clusters_applications_knative(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_merge_request_rule_sources
    ADD CONSTRAINT fk_rails_e605a04f76 FOREIGN KEY (approval_merge_request_rule_id) REFERENCES approval_merge_request_rules(id) ON DELETE CASCADE;

ALTER TABLE ONLY prometheus_alerts
    ADD CONSTRAINT fk_rails_e6351447ec FOREIGN KEY (prometheus_metric_id) REFERENCES prometheus_metrics(id) ON DELETE CASCADE;

ALTER TABLE ONLY requirements_management_test_reports
    ADD CONSTRAINT fk_rails_e67d085910 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE SET NULL;

ALTER TABLE ONLY merge_request_metrics
    ADD CONSTRAINT fk_rails_e6d7c24d1b FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY draft_notes
    ADD CONSTRAINT fk_rails_e753681674 FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY dast_site_tokens
    ADD CONSTRAINT fk_rails_e84f721a8e FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY group_deploy_keys_groups
    ADD CONSTRAINT fk_rails_e87145115d FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY description_versions
    ADD CONSTRAINT fk_rails_e8f4caf9c7 FOREIGN KEY (epic_id) REFERENCES epics(id) ON DELETE CASCADE;

ALTER TABLE ONLY vulnerability_issue_links
    ADD CONSTRAINT fk_rails_e9180d534b FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_request_blocks
    ADD CONSTRAINT fk_rails_e9387863bc FOREIGN KEY (blocking_merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY protected_branch_unprotect_access_levels
    ADD CONSTRAINT fk_rails_e9eb8dc025 FOREIGN KEY (protected_branch_id) REFERENCES protected_branches(id) ON DELETE CASCADE;

ALTER TABLE ONLY alert_management_alert_user_mentions
    ADD CONSTRAINT fk_rails_eb2de0cdef FOREIGN KEY (note_id) REFERENCES notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY snippet_statistics
    ADD CONSTRAINT fk_rails_ebc283ccf1 FOREIGN KEY (snippet_id) REFERENCES snippets(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_security_settings
    ADD CONSTRAINT fk_rails_ed4abe1338 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_daily_build_group_report_results
    ADD CONSTRAINT fk_rails_ee072d13b3 FOREIGN KEY (last_pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;

ALTER TABLE ONLY label_priorities
    ADD CONSTRAINT fk_rails_ef916d14fa FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY fork_network_members
    ADD CONSTRAINT fk_rails_efccadc4ec FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY prometheus_alerts
    ADD CONSTRAINT fk_rails_f0e8db86aa FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY import_export_uploads
    ADD CONSTRAINT fk_rails_f129140f9e FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY jira_connect_subscriptions
    ADD CONSTRAINT fk_rails_f1d617343f FOREIGN KEY (jira_connect_installation_id) REFERENCES jira_connect_installations(id) ON DELETE CASCADE;

ALTER TABLE ONLY requirements
    ADD CONSTRAINT fk_rails_f212e67e63 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY snippet_repositories
    ADD CONSTRAINT fk_rails_f21f899728 FOREIGN KEY (shard_id) REFERENCES shards(id) ON DELETE RESTRICT;

ALTER TABLE ONLY ci_pipeline_chat_data
    ADD CONSTRAINT fk_rails_f300456b63 FOREIGN KEY (chat_name_id) REFERENCES chat_names(id) ON DELETE CASCADE;

ALTER TABLE ONLY approval_project_rules_users
    ADD CONSTRAINT fk_rails_f365da8250 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY insights
    ADD CONSTRAINT fk_rails_f36fda3932 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_group_recent_visits
    ADD CONSTRAINT fk_rails_f410736518 FOREIGN KEY (group_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_state_events
    ADD CONSTRAINT fk_rails_f5827a7ccd FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY design_user_mentions
    ADD CONSTRAINT fk_rails_f7075a53c1 FOREIGN KEY (design_id) REFERENCES design_management_designs(id) ON DELETE CASCADE;

ALTER TABLE ONLY internal_ids
    ADD CONSTRAINT fk_rails_f7d46b66c6 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY issues_self_managed_prometheus_alert_events
    ADD CONSTRAINT fk_rails_f7db2d72eb FOREIGN KEY (self_managed_prometheus_alert_event_id) REFERENCES self_managed_prometheus_alert_events(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_requests_closing_issues
    ADD CONSTRAINT fk_rails_f8540692be FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY ci_build_trace_section_names
    ADD CONSTRAINT fk_rails_f8cd72cd26 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY merge_trains
    ADD CONSTRAINT fk_rails_f90820cb08 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_runner_namespaces
    ADD CONSTRAINT fk_rails_f9d9ed3308 FOREIGN KEY (namespace_id) REFERENCES namespaces(id) ON DELETE CASCADE;

ALTER TABLE ONLY requirements_management_test_reports
    ADD CONSTRAINT fk_rails_fb3308ad55 FOREIGN KEY (requirement_id) REFERENCES requirements(id) ON DELETE CASCADE;

ALTER TABLE ONLY operations_feature_flags_issues
    ADD CONSTRAINT fk_rails_fb4d2a7cb1 FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY board_project_recent_visits
    ADD CONSTRAINT fk_rails_fb6fc419cb FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY serverless_domain_cluster
    ADD CONSTRAINT fk_rails_fbdba67eb1 FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_job_variables
    ADD CONSTRAINT fk_rails_fbf3b34792 FOREIGN KEY (job_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

ALTER TABLE ONLY packages_nuget_metadata
    ADD CONSTRAINT fk_rails_fc0c19f5b4 FOREIGN KEY (package_id) REFERENCES packages_packages(id) ON DELETE CASCADE;

ALTER TABLE ONLY experiment_users
    ADD CONSTRAINT fk_rails_fd805f771a FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE ONLY cluster_groups
    ADD CONSTRAINT fk_rails_fdb8648a96 FOREIGN KEY (cluster_id) REFERENCES clusters(id) ON DELETE CASCADE;

ALTER TABLE ONLY project_tracing_settings
    ADD CONSTRAINT fk_rails_fe56f57fc6 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY resource_label_events
    ADD CONSTRAINT fk_rails_fe91ece594 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE ONLY ci_builds_metadata
    ADD CONSTRAINT fk_rails_ffcf702a02 FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;

ALTER TABLE ONLY timelogs
    ADD CONSTRAINT fk_timelogs_issues_issue_id FOREIGN KEY (issue_id) REFERENCES issues(id) ON DELETE CASCADE;

ALTER TABLE ONLY timelogs
    ADD CONSTRAINT fk_timelogs_merge_requests_merge_request_id FOREIGN KEY (merge_request_id) REFERENCES merge_requests(id) ON DELETE CASCADE;

ALTER TABLE ONLY u2f_registrations
    ADD CONSTRAINT fk_u2f_registrations_user_id FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE product_analytics_events_experimental
    ADD CONSTRAINT product_analytics_events_experimental_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE;-- schema_migrations.version information is no longer stored in this file,
-- but instead tracked in the db/schema_migrations directory
-- see https://gitlab.com/gitlab-org/gitlab/-/issues/218590 for details
