# frozen_string_literal: true

module EE
  module Projects
    module HashedStorage
      module MigrateRepositoryService
        extend ::Gitlab::Utils::Override

        override :execute
        def execute
          result = super

          if result
            ::Geo::HashedStorageMigratedEventStore.new(
              project,
              old_storage_version: old_storage_version,
              old_disk_path: old_disk_path,
              old_wiki_disk_path: old_wiki_disk_path,
              old_design_disk_path: old_design_disk_path
            ).create!
          end

          result
        end
      end
    end
  end
end
