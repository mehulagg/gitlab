# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddProductAnalyticsTable < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  # When a migration requires downtime you **must** uncomment the following
  # constant and define a short and easy to understand explanation as to why the
  # migration requires downtime.
  # DOWNTIME_REASON = ''

  # When using the methods "add_concurrent_index", "remove_concurrent_index" or
  # "add_column_with_default" you must disable the use of transactions
  # as these methods can not run in an existing transaction.
  # When using "add_concurrent_index" or "remove_concurrent_index" methods make sure
  # that either of them is the _only_ method called in the migration,
  # any other changes should go in a separate migration.
  # This ensures that upon failure _only_ the index creation or removing fails
  # and can be retried or reverted easily.
  #
  # To disable transactions uncomment the following line and remove these
  # comments:
  # disable_ddl_transaction!

  # Table is based on https://github.com/snowplow/snowplow/blob/master/4-storage/postgres-storage/sql/atomic-def.sql 6e07b1c
  def up
    execute 'CREATE TABLE "product_analytics_events" (
      -- App
      "app_id" varchar(255),
      "platform" varchar(255),
      -- Date/time
      "etl_tstamp" timestamp,
      "collector_tstamp" timestamp NOT NULL,
      "dvce_created_tstamp" timestamp,
      -- Date/time
      "event" varchar(128),
      "event_id" char(36) NOT NULL,
      "txn_id" integer,
      -- Versioning
      "name_tracker" varchar(128),
      "v_tracker" varchar(100),
      "v_collector" varchar(100) NOT NULL,
      "v_etl" varchar(100) NOT NULL,
      -- User and visit
      "user_id" varchar(255),
      "user_ipaddress" varchar(45),
      "user_fingerprint" varchar(50),
      "domain_userid" varchar(36),
      "domain_sessionidx" smallint,
      "network_userid" varchar(38),
      -- Location
      "geo_country" char(2),
      "geo_region" char(3),
      "geo_city" varchar(75),
      "geo_zipcode" varchar(15),
      "geo_latitude" double precision,
      "geo_longitude" double precision,
      "geo_region_name" varchar(100),
      -- IP lookups
      "ip_isp" varchar(100),
      "ip_organization" varchar(100),
      "ip_domain" varchar(100),
      "ip_netspeed" varchar(100),
      -- Page
      "page_url" text,
      "page_title" varchar(2000),
      "page_referrer" text,
      -- Page URL components
      "page_urlscheme" varchar(16),
      "page_urlhost" varchar(255),
      "page_urlport" integer,
      "page_urlpath" varchar(3000),
      "page_urlquery" varchar(6000),
      "page_urlfragment" varchar(3000),
      -- Referrer URL components
      "refr_urlscheme" varchar(16),
      "refr_urlhost" varchar(255),
      "refr_urlport" integer,
      "refr_urlpath" varchar(6000),
      "refr_urlquery" varchar(6000),
      "refr_urlfragment" varchar(3000),
      -- Referrer details
      "refr_medium" varchar(25),
      "refr_source" varchar(50),
      "refr_term" varchar(255),
      -- Marketing
      "mkt_medium" varchar(255),
      "mkt_source" varchar(255),
      "mkt_term" varchar(255),
      "mkt_content" varchar(500),
      "mkt_campaign" varchar(255),
      -- Custom structured event
      "se_category" varchar(1000),
      "se_action" varchar(1000),
      "se_label" varchar(1000),
      "se_property" varchar(1000),
      "se_value" double precision,
      -- Ecommerce
      "tr_orderid" varchar(255),
      "tr_affiliation" varchar(255),
      "tr_total" decimal(18,2),
      "tr_tax" decimal(18,2),
      "tr_shipping" decimal(18,2),
      "tr_city" varchar(255),
      "tr_state" varchar(255),
      "tr_country" varchar(255),
      "ti_orderid" varchar(255),
      "ti_sku" varchar(255),
      "ti_name" varchar(255),
      "ti_category" varchar(255),
      "ti_price" decimal(18,2),
      "ti_quantity" integer,
      -- Page ping
      "pp_xoffset_min" integer,
      "pp_xoffset_max" integer,
      "pp_yoffset_min" integer,
      "pp_yoffset_max" integer,
      -- User Agent
      "useragent" varchar(1000),
      -- Browser
      "br_name" varchar(50),
      "br_family" varchar(50),
      "br_version" varchar(50),
      "br_type" varchar(50),
      "br_renderengine" varchar(50),
      "br_lang" varchar(255),
      "br_features_pdf" boolean,
      "br_features_flash" boolean,
      "br_features_java" boolean,
      "br_features_director" boolean,
      "br_features_quicktime" boolean,
      "br_features_realplayer" boolean,
      "br_features_windowsmedia" boolean,
      "br_features_gears" boolean,
      "br_features_silverlight" boolean,
      "br_cookies" boolean,
      "br_colordepth" varchar(12),
      "br_viewwidth" integer,
      "br_viewheight" integer,
      -- Operating System
      "os_name" varchar(50),
      "os_family" varchar(50),
      "os_manufacturer" varchar(50),
      "os_timezone" varchar(50),
      -- Device/Hardware
      "dvce_type" varchar(50),
      "dvce_ismobile" boolean,
      "dvce_screenwidth" integer,
      "dvce_screenheight" integer,
      -- Document
      "doc_charset" varchar(128),
      "doc_width" integer,
      "doc_height" integer,
      -- Currency
      "tr_currency" char(3),
      "tr_total_base" decimal(18, 2),
      "tr_tax_base" decimal(18, 2),
      "tr_shipping_base" decimal(18, 2),
      "ti_currency" char(3),
      "ti_price_base" decimal(18, 2),
      "base_currency" char(3),
      -- Geolocation
      "geo_timezone" varchar(64),
      -- Click ID
      "mkt_clickid" varchar(128),
      "mkt_network" varchar(64),
      -- ETL tags
      "etl_tags" varchar(500),
      -- Time event was sent
      "dvce_sent_tstamp" timestamp,
      -- Referer
      "refr_domain_userid" varchar(36),
      "refr_dvce_tstamp" timestamp,
      -- Session ID
      "domain_sessionid" char(36),
      -- Derived timestamp
      "derived_tstamp" timestamp,
      -- Event schema
      "event_vendor" varchar(1000),
      "event_name" varchar(1000),
      "event_format" varchar(128),
      "event_version" varchar(128),
      -- Event fingerprint
      "event_fingerprint" varchar(128),
      -- True timestamp
      "true_tstamp" timestamp
    )
    WITH (OIDS=FALSE)
    ;'
    add_concurrent_index :product_analytics_events, :app_id
    add_concurrent_index :product_analytics_events, :collector_tstamp
  end

  def down
    execute 'DROP TABLE "product_analytics_events";'
  end
end
