# frozen_string_literal: true

class DropNonPartitionedAuditEvents < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  include Gitlab::Database::PartitioningMigrationHelpers::TableManagementHelpers

  DOWNTIME = false

  def up
    drop_nonpartitioned_archive_table(:audit_events)
  end

  def down
    execute(<<~SQL)
      CREATE TABLE audit_events_archived (
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

      ALTER TABLE ONLY audit_events_archived ADD CONSTRAINT audit_events_archived_pkey PRIMARY KEY (id);

      CREATE FUNCTION table_sync_function_2be879775d() RETURNS trigger
      LANGUAGE plpgsql
      AS $$
      BEGIN
      IF (TG_OP = 'DELETE') THEN
        DELETE FROM audit_events_archived where id = OLD.id;
      ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE audit_events_archived
        SET author_id = NEW.author_id,
          entity_id = NEW.entity_id,
          entity_type = NEW.entity_type,
          details = NEW.details,
          created_at = NEW.created_at,
          ip_address = NEW.ip_address,
          author_name = NEW.author_name,
          entity_path = NEW.entity_path,
          target_details = NEW.target_details,
          target_type = NEW.target_type,
          target_id = NEW.target_id
        WHERE audit_events_archived.id = NEW.id;
      ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_events_archived (id,
          author_id,
          entity_id,
          entity_type,
          details,
          created_at,
          ip_address,
          author_name,
          entity_path,
          target_details,
          target_type,
          target_id)
        VALUES (NEW.id,
          NEW.author_id,
          NEW.entity_id,
          NEW.entity_type,
          NEW.details,
          NEW.created_at,
          NEW.ip_address,
          NEW.author_name,
          NEW.entity_path,
          NEW.target_details,
          NEW.target_type,
          NEW.target_id);
      END IF;
      RETURN NULL;
      
      END
      $$;
      
      COMMENT ON FUNCTION table_sync_function_2be879775d() IS 'Partitioning migration: table sync for audit_events table';      

      CREATE TRIGGER table_sync_trigger_ee39a25f9d AFTER INSERT OR DELETE OR UPDATE ON audit_events FOR EACH ROW EXECUTE PROCEDURE table_sync_function_2be879775d();

      CREATE INDEX analytics_index_audit_events_on_created_at_and_author_id ON audit_events_archived USING btree (created_at, author_id);

      CREATE INDEX idx_audit_events_on_entity_id_desc_author_id_created_at ON audit_events_archived USING btree (entity_id, entity_type, id DESC, author_id, created_at);
    SQL

    with_lock_retries do
      create_trigger_to_sync_tables(:audit_events, :audit_events_archived, :id)
    end
  end
end
