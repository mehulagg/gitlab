CREATE SCHEMA gitlab_partitions_dynamic;

COMMENT ON SCHEMA gitlab_partitions_dynamic IS 'Schema to hold partitions managed dynamically from the application, e.g. for time space partitioning.';

CREATE SCHEMA gitlab_partitions_static;

COMMENT ON SCHEMA gitlab_partitions_static IS 'Schema to hold static partitions, e.g. for hash partitioning';

CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE ci_build_needs (
    id integer NOT NULL,
    build_id integer NOT NULL,
    name text NOT NULL,
    artifacts boolean DEFAULT true NOT NULL,
    optional boolean DEFAULT false NOT NULL,
    build_id_convert_to_bigint bigint DEFAULT 0 NOT NULL
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
    trace_checksum bytea,
    trace_bytesize bigint
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
    lock_version integer DEFAULT 0 NOT NULL,
    build_id_convert_to_bigint bigint DEFAULT 0 NOT NULL
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
    project_id integer,
    erased_by_id integer,
    erased_at timestamp without time zone,
    artifacts_expire_at timestamp without time zone,
    environment character varying,
    "when" character varying,
    yaml_variables text,
    queued_at timestamp without time zone,
    token character varying,
    lock_version integer DEFAULT 0,
    coverage_regex character varying,
    auto_canceled_by_id integer,
    retried boolean,
    stage_id integer,
    protected boolean,
    failure_reason integer,
    scheduled_at timestamp with time zone,
    token_encrypted character varying,
    upstream_pipeline_id integer,
    resource_group_id bigint,
    waiting_for_resource_at timestamp with time zone,
    processed boolean,
    scheduling_type smallint,
    id_convert_to_bigint bigint DEFAULT 0 NOT NULL,
    stage_id_convert_to_bigint bigint,
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
    "authorization" character varying,
    build_id_convert_to_bigint bigint DEFAULT 0 NOT NULL
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
    data jsonb NOT NULL,
    default_branch boolean DEFAULT false NOT NULL,
    group_id bigint
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
    variable_type smallint DEFAULT 1 NOT NULL,
    environment_scope text DEFAULT '*'::text NOT NULL,
    CONSTRAINT check_dfe009485a CHECK ((char_length(environment_scope) <= 255))
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
    id_convert_to_bigint bigint DEFAULT 0 NOT NULL,
    job_id_convert_to_bigint bigint DEFAULT 0 NOT NULL,
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

CREATE TABLE ci_namespace_monthly_usages (
    id bigint NOT NULL,
    namespace_id bigint NOT NULL,
    date date NOT NULL,
    additional_amount_available integer DEFAULT 0 NOT NULL,
    amount_used numeric(18,2) DEFAULT 0.0 NOT NULL,
    CONSTRAINT ci_namespace_monthly_usages_year_month_constraint CHECK ((date = date_trunc('month'::text, (date)::timestamp with time zone)))
);

CREATE SEQUENCE ci_namespace_monthly_usages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_namespace_monthly_usages_id_seq OWNED BY ci_namespace_monthly_usages.id;

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
    verification_started_at timestamp with time zone,
    verification_retry_at timestamp with time zone,
    verified_at timestamp with time zone,
    verification_state smallint DEFAULT 0 NOT NULL,
    verification_retry_count smallint,
    verification_checksum bytea,
    verification_failure text,
    CONSTRAINT check_191b5850ec CHECK ((char_length(file) <= 255)),
    CONSTRAINT check_abeeb71caf CHECK ((file IS NOT NULL)),
    CONSTRAINT ci_pipeline_artifacts_verification_failure_text_limit CHECK ((char_length(verification_failure) <= 255))
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

CREATE TABLE ci_project_monthly_usages (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    date date NOT NULL,
    amount_used numeric(18,2) DEFAULT 0.0 NOT NULL,
    CONSTRAINT ci_project_monthly_usages_year_month_constraint CHECK ((date = date_trunc('month'::text, (date)::timestamp with time zone)))
);

CREATE SEQUENCE ci_project_monthly_usages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_project_monthly_usages_id_seq OWNED BY ci_project_monthly_usages.id;

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
    source_pipeline_id integer,
    source_job_id_convert_to_bigint bigint
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

CREATE TABLE ci_test_case_failures (
    id bigint NOT NULL,
    failed_at timestamp with time zone,
    test_case_id bigint NOT NULL,
    build_id bigint NOT NULL
);

CREATE SEQUENCE ci_test_case_failures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_test_case_failures_id_seq OWNED BY ci_test_case_failures.id;

CREATE TABLE ci_test_cases (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    key_hash text NOT NULL,
    CONSTRAINT check_dd3c5d1c15 CHECK ((char_length(key_hash) <= 64))
);

CREATE SEQUENCE ci_test_cases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_test_cases_id_seq OWNED BY ci_test_cases.id;

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

CREATE TABLE ci_unit_test_failures (
    id bigint NOT NULL,
    failed_at timestamp with time zone NOT NULL,
    unit_test_id bigint NOT NULL,
    build_id bigint NOT NULL
);

CREATE SEQUENCE ci_unit_test_failures_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_unit_test_failures_id_seq OWNED BY ci_unit_test_failures.id;

CREATE TABLE ci_unit_tests (
    id bigint NOT NULL,
    project_id bigint NOT NULL,
    key_hash text NOT NULL,
    name text NOT NULL,
    suite_name text NOT NULL,
    CONSTRAINT check_248fae1a3b CHECK ((char_length(name) <= 255)),
    CONSTRAINT check_b288215ffe CHECK ((char_length(key_hash) <= 64)),
    CONSTRAINT check_c2d57b3c49 CHECK ((char_length(suite_name) <= 255))
);

CREATE SEQUENCE ci_unit_tests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE ci_unit_tests_id_seq OWNED BY ci_unit_tests.id;

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

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);

ALTER TABLE ONLY schema_migrations ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

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

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);
ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);

ALTER TABLE ONLY taggings ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY tags ADD CONSTRAINT tags_pkey PRIMARY KEY (id);

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);
CREATE INDEX index_taggings_on_taggable_id_and_taggable_type ON taggings USING btree (taggable_id, taggable_type);
CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);
CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);
CREATE INDEX index_tags_on_name_trigram ON tags USING gin (name gin_trgm_ops);

CREATE UNIQUE INDEX taggings_idx ON taggings USING btree (tag_id, taggable_id, taggable_type, context, tagger_id, tagger_type);

ALTER TABLE ONLY ci_build_needs ADD CONSTRAINT ci_build_needs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_build_pending_states ADD CONSTRAINT ci_build_pending_states_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_build_report_results ADD CONSTRAINT ci_build_report_results_pkey PRIMARY KEY (build_id);
ALTER TABLE ONLY ci_build_trace_chunks ADD CONSTRAINT ci_build_trace_chunks_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_build_trace_section_names ADD CONSTRAINT ci_build_trace_section_names_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_build_trace_sections ADD CONSTRAINT ci_build_trace_sections_pkey PRIMARY KEY (build_id, section_name_id);
ALTER TABLE ONLY ci_builds_metadata ADD CONSTRAINT ci_builds_metadata_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_builds ADD CONSTRAINT ci_builds_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_builds_runner_session ADD CONSTRAINT ci_builds_runner_session_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_daily_build_group_report_results ADD CONSTRAINT ci_daily_build_group_report_results_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_deleted_objects ADD CONSTRAINT ci_deleted_objects_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_freeze_periods ADD CONSTRAINT ci_freeze_periods_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_group_variables ADD CONSTRAINT ci_group_variables_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_instance_variables ADD CONSTRAINT ci_instance_variables_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_job_artifacts ADD CONSTRAINT ci_job_artifacts_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_job_variables ADD CONSTRAINT ci_job_variables_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_namespace_monthly_usages ADD CONSTRAINT ci_namespace_monthly_usages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_pipeline_artifacts ADD CONSTRAINT ci_pipeline_artifacts_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_pipeline_chat_data ADD CONSTRAINT ci_pipeline_chat_data_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_pipeline_messages ADD CONSTRAINT ci_pipeline_messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_pipeline_schedule_variables ADD CONSTRAINT ci_pipeline_schedule_variables_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_pipeline_schedules ADD CONSTRAINT ci_pipeline_schedules_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_pipeline_variables ADD CONSTRAINT ci_pipeline_variables_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_pipelines_config ADD CONSTRAINT ci_pipelines_config_pkey PRIMARY KEY (pipeline_id);
ALTER TABLE ONLY ci_pipelines ADD CONSTRAINT ci_pipelines_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_platform_metrics ADD CONSTRAINT ci_platform_metrics_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_project_monthly_usages ADD CONSTRAINT ci_project_monthly_usages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_refs ADD CONSTRAINT ci_refs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_resource_groups ADD CONSTRAINT ci_resource_groups_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_resources ADD CONSTRAINT ci_resources_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_runner_namespaces ADD CONSTRAINT ci_runner_namespaces_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_runner_projects ADD CONSTRAINT ci_runner_projects_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_runners ADD CONSTRAINT ci_runners_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_sources_pipelines ADD CONSTRAINT ci_sources_pipelines_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_sources_projects ADD CONSTRAINT ci_sources_projects_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_stages ADD CONSTRAINT ci_stages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_subscriptions_projects ADD CONSTRAINT ci_subscriptions_projects_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_test_case_failures ADD CONSTRAINT ci_test_case_failures_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_test_cases ADD CONSTRAINT ci_test_cases_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_trigger_requests ADD CONSTRAINT ci_trigger_requests_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_triggers ADD CONSTRAINT ci_triggers_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_unit_test_failures ADD CONSTRAINT ci_unit_test_failures_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_unit_tests ADD CONSTRAINT ci_unit_tests_pkey PRIMARY KEY (id);
ALTER TABLE ONLY ci_variables ADD CONSTRAINT ci_variables_pkey PRIMARY KEY (id);

ALTER TABLE ONLY ci_unit_test_failures ADD CONSTRAINT fk_0f09856e1f FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipelines ADD CONSTRAINT fk_262d4c2d19 FOREIGN KEY (auto_canceled_by_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;
ALTER TABLE ONLY ci_build_trace_sections ADD CONSTRAINT fk_264e112c66 FOREIGN KEY (section_name_id) REFERENCES ci_build_trace_section_names(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_builds ADD CONSTRAINT fk_3a9eaa254d FOREIGN KEY (stage_id) REFERENCES ci_stages(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipelines ADD CONSTRAINT fk_3d34ab2e06 FOREIGN KEY (pipeline_schedule_id) REFERENCES ci_pipeline_schedules(id) ON DELETE SET NULL;
ALTER TABLE ONLY ci_pipeline_schedule_variables ADD CONSTRAINT fk_41c35fda51 FOREIGN KEY (pipeline_schedule_id) REFERENCES ci_pipeline_schedules(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_build_trace_sections ADD CONSTRAINT fk_4ebe41f502 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_builds ADD CONSTRAINT fk_6661f4f0e8 FOREIGN KEY (resource_group_id) REFERENCES ci_resource_groups(id) ON DELETE SET NULL;
ALTER TABLE ONLY ci_builds ADD CONSTRAINT fk_87f4cefcda FOREIGN KEY (upstream_pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_builds ADD CONSTRAINT fk_a2141b1522 FOREIGN KEY (auto_canceled_by_id) REFERENCES ci_pipelines(id) ON DELETE SET NULL;
ALTER TABLE ONLY ci_trigger_requests ADD CONSTRAINT fk_b8ec8b7245 FOREIGN KEY (trigger_id) REFERENCES ci_triggers(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_sources_pipelines ADD CONSTRAINT fk_be5624bf37 FOREIGN KEY (source_job_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_builds ADD CONSTRAINT fk_d3130c9a7f FOREIGN KEY (commit_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_sources_pipelines ADD CONSTRAINT fk_d4e29af7d7 FOREIGN KEY (source_pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_test_case_failures ADD CONSTRAINT fk_d69404d827 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipelines ADD CONSTRAINT fk_d80e161c54 FOREIGN KEY (ci_ref_id) REFERENCES ci_refs(id) ON DELETE SET NULL;
ALTER TABLE ONLY ci_resources ADD CONSTRAINT fk_e169a8e3d5 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE SET NULL;
ALTER TABLE ONLY ci_sources_pipelines ADD CONSTRAINT fk_e1bad85861 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipeline_variables ADD CONSTRAINT fk_f29c5f4380 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_stages ADD CONSTRAINT fk_fb57e6cc56 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_build_pending_states ADD CONSTRAINT fk_rails_0bbbfeaf9d FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_build_trace_chunks ADD CONSTRAINT fk_rails_1013b761f2 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_sources_projects ADD CONSTRAINT fk_rails_10a1eb379a FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_build_report_results ADD CONSTRAINT fk_rails_16cb1ff064 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_unit_test_failures ADD CONSTRAINT fk_rails_259da3e79c FOREIGN KEY (unit_test_id) REFERENCES ci_unit_tests(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_build_needs ADD CONSTRAINT fk_rails_3cf221d4ed FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipeline_chat_data ADD CONSTRAINT fk_rails_64ebfab6b3 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_builds_runner_session ADD CONSTRAINT fk_rails_70707857d3 FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_runner_namespaces ADD CONSTRAINT fk_rails_8767676b7a FOREIGN KEY (runner_id) REFERENCES ci_runners(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipeline_artifacts ADD CONSTRAINT fk_rails_a9e811a466 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_resources ADD CONSTRAINT fk_rails_430336af2d FOREIGN KEY (resource_group_id) REFERENCES ci_resource_groups(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipeline_messages ADD CONSTRAINT fk_rails_8d3b04e3e1 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_pipelines_config ADD CONSTRAINT fk_rails_906c9a2533 FOREIGN KEY (pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_job_artifacts ADD CONSTRAINT fk_rails_c5137cb2c1 FOREIGN KEY (job_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_builds_metadata ADD CONSTRAINT fk_rails_e20479742e FOREIGN KEY (build_id) REFERENCES ci_builds(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_test_case_failures ADD CONSTRAINT fk_rails_eab6349715 FOREIGN KEY (test_case_id) REFERENCES ci_test_cases(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_daily_build_group_report_results ADD CONSTRAINT fk_rails_ee072d13b3 FOREIGN KEY (last_pipeline_id) REFERENCES ci_pipelines(id) ON DELETE CASCADE;
ALTER TABLE ONLY ci_job_variables ADD CONSTRAINT fk_rails_fbf3b34792 FOREIGN KEY (job_id) REFERENCES ci_builds(id) ON DELETE CASCADE;

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
ALTER TABLE ONLY ci_namespace_monthly_usages ALTER COLUMN id SET DEFAULT nextval('ci_namespace_monthly_usages_id_seq'::regclass);
ALTER TABLE ONLY ci_pipeline_artifacts ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_artifacts_id_seq'::regclass);
ALTER TABLE ONLY ci_pipeline_chat_data ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_chat_data_id_seq'::regclass);
ALTER TABLE ONLY ci_pipeline_messages ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_messages_id_seq'::regclass);
ALTER TABLE ONLY ci_pipeline_schedule_variables ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_schedule_variables_id_seq'::regclass);
ALTER TABLE ONLY ci_pipeline_schedules ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_schedules_id_seq'::regclass);
ALTER TABLE ONLY ci_pipeline_variables ALTER COLUMN id SET DEFAULT nextval('ci_pipeline_variables_id_seq'::regclass);
ALTER TABLE ONLY ci_pipelines ALTER COLUMN id SET DEFAULT nextval('ci_pipelines_id_seq'::regclass);
ALTER TABLE ONLY ci_pipelines_config ALTER COLUMN pipeline_id SET DEFAULT nextval('ci_pipelines_config_pipeline_id_seq'::regclass);
ALTER TABLE ONLY ci_platform_metrics ALTER COLUMN id SET DEFAULT nextval('ci_platform_metrics_id_seq'::regclass);
ALTER TABLE ONLY ci_project_monthly_usages ALTER COLUMN id SET DEFAULT nextval('ci_project_monthly_usages_id_seq'::regclass);
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
ALTER TABLE ONLY ci_test_case_failures ALTER COLUMN id SET DEFAULT nextval('ci_test_case_failures_id_seq'::regclass);
ALTER TABLE ONLY ci_test_cases ALTER COLUMN id SET DEFAULT nextval('ci_test_cases_id_seq'::regclass);
ALTER TABLE ONLY ci_trigger_requests ALTER COLUMN id SET DEFAULT nextval('ci_trigger_requests_id_seq'::regclass);
ALTER TABLE ONLY ci_triggers ALTER COLUMN id SET DEFAULT nextval('ci_triggers_id_seq'::regclass);
ALTER TABLE ONLY ci_unit_test_failures ALTER COLUMN id SET DEFAULT nextval('ci_unit_test_failures_id_seq'::regclass);
ALTER TABLE ONLY ci_unit_tests ALTER COLUMN id SET DEFAULT nextval('ci_unit_tests_id_seq'::regclass);
ALTER TABLE ONLY ci_variables ALTER COLUMN id SET DEFAULT nextval('ci_variables_id_seq'::regclass);

CREATE INDEX ci_builds_gitlab_monitor_metrics ON ci_builds USING btree (status, created_at, project_id) WHERE ((type)::text = 'Ci::Build'::text);
CREATE INDEX idx_ci_pipelines_artifacts_locked ON ci_pipelines USING btree (ci_ref_id, id) WHERE (locked = 1);
CREATE UNIQUE INDEX index_ci_build_needs_on_build_id_and_name ON ci_build_needs USING btree (build_id, name);
CREATE UNIQUE INDEX index_ci_build_pending_states_on_build_id ON ci_build_pending_states USING btree (build_id);
CREATE INDEX index_ci_build_report_results_on_project_id ON ci_build_report_results USING btree (project_id);
CREATE UNIQUE INDEX index_ci_build_trace_chunks_on_build_id_and_chunk_index ON ci_build_trace_chunks USING btree (build_id, chunk_index);
CREATE UNIQUE INDEX index_ci_build_trace_section_names_on_project_id_and_name ON ci_build_trace_section_names USING btree (project_id, name);
CREATE INDEX index_ci_build_trace_sections_on_project_id ON ci_build_trace_sections USING btree (project_id);
CREATE INDEX index_ci_build_trace_sections_on_section_name_id ON ci_build_trace_sections USING btree (section_name_id);
CREATE UNIQUE INDEX index_ci_builds_metadata_on_build_id ON ci_builds_metadata USING btree (build_id);
CREATE INDEX index_ci_builds_metadata_on_build_id_and_has_exposed_artifacts ON ci_builds_metadata USING btree (build_id) WHERE (has_exposed_artifacts IS TRUE);
CREATE INDEX index_ci_builds_metadata_on_build_id_and_id_and_interruptible ON ci_builds_metadata USING btree (build_id) INCLUDE (id) WHERE (interruptible = true);
CREATE INDEX index_ci_builds_metadata_on_project_id ON ci_builds_metadata USING btree (project_id);
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
CREATE INDEX index_ci_builds_on_runner_id_and_id_desc ON ci_builds USING btree (runner_id, id DESC);
CREATE INDEX index_ci_builds_on_stage_id ON ci_builds USING btree (stage_id);
CREATE INDEX index_ci_builds_on_status_and_type_and_runner_id ON ci_builds USING btree (status, type, runner_id);
CREATE UNIQUE INDEX index_ci_builds_on_token ON ci_builds USING btree (token);
CREATE UNIQUE INDEX index_ci_builds_on_token_encrypted ON ci_builds USING btree (token_encrypted) WHERE (token_encrypted IS NOT NULL);
CREATE INDEX index_ci_builds_on_updated_at ON ci_builds USING btree (updated_at);
CREATE INDEX index_ci_builds_on_upstream_pipeline_id ON ci_builds USING btree (upstream_pipeline_id) WHERE (upstream_pipeline_id IS NOT NULL);
CREATE INDEX index_ci_builds_on_user_id ON ci_builds USING btree (user_id);
CREATE INDEX index_ci_builds_on_user_id_and_created_at_and_type_eq_ci_build ON ci_builds USING btree (user_id, created_at) WHERE ((type)::text = 'Ci::Build'::text);
CREATE INDEX index_ci_builds_project_id_and_status_for_live_jobs_partial2 ON ci_builds USING btree (project_id, status) WHERE (((type)::text = 'Ci::Build'::text) AND ((status)::text = ANY (ARRAY[('running'::character varying)::text, ('pending'::character varying)::text, ('created'::character varying)::text])));
CREATE INDEX index_ci_builds_runner_id_pending_covering ON ci_builds USING btree (runner_id, id) INCLUDE (project_id) WHERE (((status)::text = 'pending'::text) AND ((type)::text = 'Ci::Build'::text));
CREATE INDEX index_ci_builds_runner_id_running ON ci_builds USING btree (runner_id) WHERE (((status)::text = 'running'::text) AND ((type)::text = 'Ci::Build'::text));
CREATE UNIQUE INDEX index_ci_builds_runner_session_on_build_id ON ci_builds_runner_session USING btree (build_id);
CREATE INDEX index_ci_daily_build_group_report_results_on_group_id ON ci_daily_build_group_report_results USING btree (group_id);
CREATE INDEX index_ci_daily_build_group_report_results_on_last_pipeline_id ON ci_daily_build_group_report_results USING btree (last_pipeline_id);
CREATE INDEX index_ci_daily_build_group_report_results_on_project_and_date ON ci_daily_build_group_report_results USING btree (project_id, date DESC) WHERE ((default_branch = true) AND ((data -> 'coverage'::text) IS NOT NULL));
CREATE INDEX index_ci_deleted_objects_on_pick_up_at ON ci_deleted_objects USING btree (pick_up_at);
CREATE INDEX index_ci_freeze_periods_on_project_id ON ci_freeze_periods USING btree (project_id);
CREATE UNIQUE INDEX index_ci_group_variables_on_group_id_and_key_and_environment ON ci_group_variables USING btree (group_id, key, environment_scope);
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
CREATE UNIQUE INDEX index_ci_namespace_monthly_usages_on_namespace_id_and_date ON ci_namespace_monthly_usages USING btree (namespace_id, date);
CREATE INDEX index_ci_pipeline_artifacts_failed_verification ON ci_pipeline_artifacts USING btree (verification_retry_at NULLS FIRST) WHERE (verification_state = 3);
CREATE INDEX index_ci_pipeline_artifacts_needs_verification ON ci_pipeline_artifacts USING btree (verification_state) WHERE ((verification_state = 0) OR (verification_state = 3));
CREATE INDEX index_ci_pipeline_artifacts_on_expire_at ON ci_pipeline_artifacts USING btree (expire_at);
CREATE INDEX index_ci_pipeline_artifacts_on_pipeline_id ON ci_pipeline_artifacts USING btree (pipeline_id);
CREATE UNIQUE INDEX index_ci_pipeline_artifacts_on_pipeline_id_and_file_type ON ci_pipeline_artifacts USING btree (pipeline_id, file_type);
CREATE INDEX index_ci_pipeline_artifacts_on_project_id ON ci_pipeline_artifacts USING btree (project_id);
CREATE INDEX index_ci_pipeline_artifacts_pending_verification ON ci_pipeline_artifacts USING btree (verified_at NULLS FIRST) WHERE (verification_state = 0);
CREATE INDEX index_ci_pipeline_artifacts_verification_state ON ci_pipeline_artifacts USING btree (verification_state);
CREATE INDEX index_ci_pipeline_chat_data_on_chat_name_id ON ci_pipeline_chat_data USING btree (chat_name_id);
CREATE UNIQUE INDEX index_ci_pipeline_chat_data_on_pipeline_id ON ci_pipeline_chat_data USING btree (pipeline_id);
CREATE INDEX index_ci_pipeline_messages_on_pipeline_id ON ci_pipeline_messages USING btree (pipeline_id);
CREATE UNIQUE INDEX index_ci_pipeline_schedule_variables_on_schedule_id_and_key ON ci_pipeline_schedule_variables USING btree (pipeline_schedule_id, key);
CREATE INDEX index_ci_pipeline_schedules_on_next_run_at_and_active ON ci_pipeline_schedules USING btree (next_run_at, active);
CREATE INDEX index_ci_pipeline_schedules_on_owner_id ON ci_pipeline_schedules USING btree (owner_id);
CREATE INDEX index_ci_pipeline_schedules_on_owner_id_and_id_and_active ON ci_pipeline_schedules USING btree (owner_id, id) WHERE (active = true);
CREATE INDEX index_ci_pipeline_schedules_on_project_id ON ci_pipeline_schedules USING btree (project_id);
CREATE UNIQUE INDEX index_ci_pipeline_variables_on_pipeline_id_and_key ON ci_pipeline_variables USING btree (pipeline_id, key);
CREATE INDEX index_ci_pipelines_config_on_pipeline_id ON ci_pipelines_config USING btree (pipeline_id);
CREATE INDEX index_ci_pipelines_for_ondemand_dast_scans ON ci_pipelines USING btree (id) WHERE (source = 13);
CREATE INDEX index_ci_pipelines_on_auto_canceled_by_id ON ci_pipelines USING btree (auto_canceled_by_id);
CREATE INDEX index_ci_pipelines_on_ci_ref_id_and_more ON ci_pipelines USING btree (ci_ref_id, id DESC, source, status) WHERE (ci_ref_id IS NOT NULL);
CREATE INDEX index_ci_pipelines_on_external_pull_request_id ON ci_pipelines USING btree (external_pull_request_id) WHERE (external_pull_request_id IS NOT NULL);
CREATE INDEX index_ci_pipelines_on_merge_request_id ON ci_pipelines USING btree (merge_request_id) WHERE (merge_request_id IS NOT NULL);
CREATE INDEX index_ci_pipelines_on_pipeline_schedule_id_and_id ON ci_pipelines USING btree (pipeline_schedule_id, id);
CREATE INDEX index_ci_pipelines_on_project_id_and_id_desc ON ci_pipelines USING btree (project_id, id DESC);
CREATE UNIQUE INDEX index_ci_pipelines_on_project_id_and_iid ON ci_pipelines USING btree (project_id, iid) WHERE (iid IS NOT NULL);
CREATE INDEX index_ci_pipelines_on_project_id_and_ref_and_status_and_id ON ci_pipelines USING btree (project_id, ref, status, id);
CREATE INDEX index_ci_pipelines_on_project_id_and_sha ON ci_pipelines USING btree (project_id, sha);
CREATE INDEX index_ci_pipelines_on_project_id_and_source ON ci_pipelines USING btree (project_id, source);
CREATE INDEX index_ci_pipelines_on_project_id_and_status_and_config_source ON ci_pipelines USING btree (project_id, status, config_source);
CREATE INDEX index_ci_pipelines_on_project_id_and_status_and_created_at ON ci_pipelines USING btree (project_id, status, created_at);
CREATE INDEX index_ci_pipelines_on_project_id_and_status_and_updated_at ON ci_pipelines USING btree (project_id, status, updated_at);
CREATE INDEX index_ci_pipelines_on_project_id_and_user_id_and_status_and_ref ON ci_pipelines USING btree (project_id, user_id, status, ref) WHERE (source <> 12);
CREATE INDEX index_ci_pipelines_on_project_idandrefandiddesc ON ci_pipelines USING btree (project_id, ref, id DESC);
CREATE INDEX index_ci_pipelines_on_status_and_id ON ci_pipelines USING btree (status, id);
CREATE INDEX index_ci_pipelines_on_user_id_and_created_at_and_config_source ON ci_pipelines USING btree (user_id, created_at, config_source);
CREATE INDEX index_ci_pipelines_on_user_id_and_created_at_and_source ON ci_pipelines USING btree (user_id, created_at, source);
CREATE INDEX index_ci_pipelines_on_user_id_and_id_and_cancelable_status ON ci_pipelines USING btree (user_id, id) WHERE ((status)::text = ANY (ARRAY[('running'::character varying)::text, ('waiting_for_resource'::character varying)::text, ('preparing'::character varying)::text, ('pending'::character varying)::text, ('created'::character varying)::text, ('scheduled'::character varying)::text]));
CREATE UNIQUE INDEX index_ci_project_monthly_usages_on_project_id_and_date ON ci_project_monthly_usages USING btree (project_id, date);
CREATE UNIQUE INDEX index_ci_refs_on_project_id_and_ref_path ON ci_refs USING btree (project_id, ref_path);
CREATE UNIQUE INDEX index_ci_resource_groups_on_project_id_and_key ON ci_resource_groups USING btree (project_id, key);
CREATE INDEX index_ci_resources_on_build_id ON ci_resources USING btree (build_id);
CREATE UNIQUE INDEX index_ci_resources_on_resource_group_id_and_build_id ON ci_resources USING btree (resource_group_id, build_id);
CREATE INDEX index_ci_runner_namespaces_on_namespace_id ON ci_runner_namespaces USING btree (namespace_id);
CREATE UNIQUE INDEX index_ci_runner_namespaces_on_runner_id_and_namespace_id ON ci_runner_namespaces USING btree (runner_id, namespace_id);
CREATE INDEX index_ci_runner_projects_on_project_id ON ci_runner_projects USING btree (project_id);
CREATE INDEX index_ci_runner_projects_on_runner_id ON ci_runner_projects USING btree (runner_id);
CREATE INDEX index_ci_runners_on_contacted_at ON ci_runners USING btree (contacted_at);
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
CREATE INDEX index_ci_stages_on_pipeline_id_and_id ON ci_stages USING btree (pipeline_id, id) WHERE (status = ANY (ARRAY[0, 1, 2, 8, 9, 10]));
CREATE UNIQUE INDEX index_ci_stages_on_pipeline_id_and_name ON ci_stages USING btree (pipeline_id, name);
CREATE INDEX index_ci_stages_on_pipeline_id_and_position ON ci_stages USING btree (pipeline_id, "position");
CREATE INDEX index_ci_stages_on_project_id ON ci_stages USING btree (project_id);
CREATE INDEX index_ci_subscriptions_projects_on_upstream_project_id ON ci_subscriptions_projects USING btree (upstream_project_id);
CREATE UNIQUE INDEX index_ci_subscriptions_projects_unique_subscription ON ci_subscriptions_projects USING btree (downstream_project_id, upstream_project_id);
CREATE INDEX index_ci_test_case_failures_on_build_id ON ci_test_case_failures USING btree (build_id);
CREATE UNIQUE INDEX index_ci_test_cases_on_project_id_and_key_hash ON ci_test_cases USING btree (project_id, key_hash);
CREATE INDEX index_ci_trigger_requests_on_commit_id ON ci_trigger_requests USING btree (commit_id);
CREATE INDEX index_ci_trigger_requests_on_trigger_id_and_id ON ci_trigger_requests USING btree (trigger_id, id DESC);
CREATE INDEX index_ci_triggers_on_owner_id ON ci_triggers USING btree (owner_id);
CREATE INDEX index_ci_triggers_on_project_id ON ci_triggers USING btree (project_id);
CREATE INDEX index_ci_unit_test_failures_on_build_id ON ci_unit_test_failures USING btree (build_id);
CREATE UNIQUE INDEX index_ci_unit_tests_on_project_id_and_key_hash ON ci_unit_tests USING btree (project_id, key_hash);
CREATE INDEX index_ci_variables_on_key ON ci_variables USING btree (key);
CREATE UNIQUE INDEX index_ci_variables_on_project_id_and_key_and_environment_scope ON ci_variables USING btree (project_id, key, environment_scope);
CREATE UNIQUE INDEX index_daily_build_group_report_results_unique_columns ON ci_daily_build_group_report_results USING btree (project_id, ref_path, date, group_name);
CREATE INDEX index_for_resource_group ON ci_builds USING btree (resource_group_id, id) WHERE (resource_group_id IS NOT NULL);
CREATE INDEX index_partial_ci_builds_on_user_id_name_parser_features ON ci_builds USING btree (user_id, name) WHERE (((type)::text = 'Ci::Build'::text) AND ((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('license_scanning'::character varying)::text, ('sast'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('secret_detection'::character varying)::text])));
CREATE INDEX index_secure_ci_builds_on_user_id_name_created_at ON ci_builds USING btree (user_id, name, created_at) WHERE (((type)::text = 'Ci::Build'::text) AND ((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('license_scanning'::character varying)::text, ('sast'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('apifuzzer_fuzz'::character varying)::text, ('apifuzzer_fuzz_dnd'::character varying)::text, ('secret_detection'::character varying)::text])));
CREATE INDEX index_security_ci_builds_on_name_and_id_parser_features ON ci_builds USING btree (name, id) WHERE (((name)::text = ANY (ARRAY[('container_scanning'::character varying)::text, ('dast'::character varying)::text, ('dependency_scanning'::character varying)::text, ('license_management'::character varying)::text, ('sast'::character varying)::text, ('secret_detection'::character varying)::text, ('coverage_fuzzing'::character varying)::text, ('license_scanning'::character varying)::text])) AND ((type)::text = 'Ci::Build'::text));
CREATE UNIQUE INDEX index_test_case_failures_unique_columns ON ci_test_case_failures USING btree (test_case_id, failed_at DESC, build_id);
CREATE INDEX index_unit_test_failures_failed_at ON ci_unit_test_failures USING btree (failed_at DESC);
CREATE UNIQUE INDEX index_unit_test_failures_unique_columns ON ci_unit_test_failures USING btree (unit_test_id, failed_at DESC, build_id);
CREATE INDEX partial_index_ci_builds_on_scheduled_at_with_scheduled_jobs ON ci_builds USING btree (scheduled_at) WHERE ((scheduled_at IS NOT NULL) AND ((type)::text = 'Ci::Build'::text) AND ((status)::text = 'scheduled'::text));
