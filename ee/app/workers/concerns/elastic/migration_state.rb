# frozen_string_literal: true

module Elastic
  module MigrationState
    def migration_state
      migration_record.load_state
    end

    def set_migration_state(state)
      log "Setting migration_state to #{state.to_json}"

      migration_record.save_state!(state)
    end
  end
end
