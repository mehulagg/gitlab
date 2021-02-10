# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      class MigrateLfsObjectRegistryFields
        class LfsObjectRegistry < ActiveRecord::Base
          self.table_name = 'lfs_object_registry'
        end

        def perform(registry_id)
          entry = LfsObjectRegistry.find_by(id: registry_id)

          return unless entry

          entry.update(created_at: Time.now) if entry.created_at.nil?
        end
      end
    end
  end
end
