# frozen_string_literal: true

# Imports a top level group and descendant subgroups
# Optionally imports into parent group
# Entity must be of type: 'group' & have parent_id: nil
module Gitlab
  module BulkImport
    module Importer
      class GroupImporter
        def initialize(entity_id)
          @entity_id = entity_id
        end

        def execute
          return if entity.parent # import only top level groups, subgroups handles within the process

          # 1. Construct object hierarchy to get all descendant groups that need to be created
          # 2. Create pipeline context
          # 3. Execute Gitlab::BulkImport::Group::Pipelines::GroupPipeline

          context = Gitlab::BulkImport::PipelineContext.new(
            import_entities:[

                            ]
          )
          Gitlab::BulkImport::PipelineContext.new(import_entities: [OpenStruct.new(full_path: 'georgekoltsov-group'), OpenStruct.new(full_path: 'georgekoltsov-group/tests'), OpenStruct.new(full_path: 'georgekoltsov-group/tests/test')], import_config: OpenStruct.new(url: 'https://gitlab.com', token: '2MLQg-2x56de4ywA_tys'), query: Gitlab::BulkImport::Graphql::Queries::GetGroupQuery, variables: [:full_path]), current_user: User.first

          Gitlab::BulkImport::Group::Pipelines::GroupPipeline.run(context)
        end
      end
    end
  end
end
