# frozen_string_literal: true

class InitializeConversionOfEventsIdToBigint < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # Initialize the conversion of events.id to bigint
    # Primary Key of the Events table
    initialize_conversion_of_integer_to_bigint :events,
                                               :id,
                                               batch_size: 7000,
                                               sub_batch_size: 100

    # Foreign key that references events.id
    # Also Primary key of the push_event_payloads table
    initialize_conversion_of_integer_to_bigint :push_event_payloads,
                                               :event_id,
                                               primary_key: :event_id,
                                               batch_size: 7000,
                                               sub_batch_size: 100
  end

  def down
    remove_rename_triggers_for_postgresql(
      :events,
      rename_trigger_name(:events, :id, :id_convert_to_bigint)
    )

    remove_rename_triggers_for_postgresql(
      :push_event_payloads,
      rename_trigger_name(:push_event_payloads, :event_id, :event_id_convert_to_bigint)
    )

    remove_column :events, :id_convert_to_bigint
    remove_column :push_event_payloads, :event_id_convert_to_bigint
  end
end
