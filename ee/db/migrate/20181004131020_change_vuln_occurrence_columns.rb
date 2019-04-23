class ChangeVulnOccurrenceColumns < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    drop_table :vulnerability_occurrence_identifiers
    drop_table :vulnerability_occurrences

    create_table :vulnerability_occurrences, id: :bigserial do |t|
      t.timestamps_with_timezone null: false

      t.integer :severity, null: false, limit: 2
      t.integer :confidence, null: false, limit: 2
      t.integer :report_type, null: false, limit: 2

      t.references :project, null: false, foreign_key: { on_delete: :cascade }

      t.bigint :scanner_id, null: false
      t.foreign_key :vulnerability_scanners, column: :scanner_id, on_delete: :cascade

      t.bigint :primary_identifier_id, null: false
      t.foreign_key :vulnerability_identifiers, column: :primary_identifier_id, on_delete: :cascade

      t.binary :project_fingerprint, null: false, limit: 20
      t.binary :location_fingerprint, null: false, limit: 20

      t.string :uuid, null: false, limit: 36
      t.string :name, null: false
      t.string :metadata_version, null: false
      t.text :raw_metadata, null: false

      t.index :primary_identifier_id
      t.index :scanner_id
      t.index :uuid, unique: true

      t.index [:project_id, :primary_identifier_id, :location_fingerprint, :scanner_id],
        unique: true,
        name: 'index_vulnerability_occurrences_on_unique_keys',
        length: { location_fingerprint: 20, primary_identifier_fingerprint: 20 }
    end

    create_table :vulnerability_occurrence_identifiers, id: :bigserial do |t|
      t.timestamps_with_timezone null: false

      t.bigint :occurrence_id, null: false
      t.foreign_key :vulnerability_occurrences, column: :occurrence_id, on_delete: :cascade
      t.bigint :identifier_id, null: false
      t.foreign_key :vulnerability_identifiers, column: :identifier_id, on_delete: :cascade

      t.index :identifier_id
      t.index [:occurrence_id, :identifier_id],
        unique: true,
        name: 'index_vulnerability_occurrence_identifiers_on_unique_keys'
    end
  end

  def down
    drop_table :vulnerability_occurrence_identifiers
    drop_table :vulnerability_occurrences

    create_table :vulnerability_occurrences, id: :bigserial do |t|
      t.timestamps_with_timezone null: false

      t.integer :severity, null: false, limit: 2
      t.integer :confidence, null: false, limit: 2
      t.integer :report_type, null: false, limit: 2

      t.integer :pipeline_id, null: false
      t.foreign_key :ci_pipelines, column: :pipeline_id, on_delete: :cascade
      t.references :project, null: false, foreign_key: { on_delete: :cascade }

      t.bigint :scanner_id, null: false
      t.foreign_key :vulnerability_scanners, column: :scanner_id, on_delete: :cascade

      t.binary :project_fingerprint, null: false, limit: 20
      t.binary :location_fingerprint, null: false, limit: 20
      t.binary :primary_identifier_fingerprint, null: false, limit: 20

      t.string :uuid, null: false, limit: 36
      t.string :ref, null: false
      t.string :name, null: false
      t.string :metadata_version, null: false
      t.text :raw_metadata, null: false

      t.index :pipeline_id
      t.index :scanner_id
      t.index :uuid, unique: true

      t.index [:project_id, :ref, :primary_identifier_fingerprint, :location_fingerprint, :pipeline_id, :scanner_id],
        unique: true,
        name: 'index_vulnerability_occurrences_on_unique_keys',
        length: { location_fingerprint: 20, primary_identifier_fingerprint: 20 }
    end

    create_table :vulnerability_occurrence_identifiers, id: :bigserial do |t|
      t.timestamps_with_timezone null: false

      t.bigint :occurrence_id, null: false
      t.foreign_key :vulnerability_occurrences, column: :occurrence_id, on_delete: :cascade
      t.bigint :identifier_id, null: false
      t.foreign_key :vulnerability_identifiers, column: :identifier_id, on_delete: :cascade

      t.index :identifier_id
      t.index [:occurrence_id, :identifier_id],
        unique: true,
        name: 'index_vulnerability_occurrence_identifiers_on_unique_keys'
    end
  end
end
