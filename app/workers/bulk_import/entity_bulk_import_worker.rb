# frozen_string_literal: true

module BulkImport
  class EntityBulkImportWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    feature_category :importers
    sidekiq_options retry: false

    def perform(import_entity_id)
      # ImportEntity stub
      @import_entity = OpenStruct.new(
        type: 'Group',
        source_full_path: 'georgekoltsov-group',
        destination_name: 'My Group!',
        destination_full_path: 'group/subgroup/my_group',
        configuration: OpenStruct.new(
          url: 'https://gitlab.com',
          token: '12345'
        )
      )







    end
  end
end
