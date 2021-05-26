# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class EpicsPipeline
        include BulkImports::NdjsonPipeline

        RELATION = 'epics'

        extractor ::BulkImports::Common::Extractors::NdjsonExtractor, relation: RELATION

        def transform(context, data)
          relation_hash = data.first
          relation_index = data.last
          relation_definition = import_export_config.top_relation_tree(RELATION)

          deep_transform_relation!(relation_hash, RELATION, relation_definition) do |key, hash|
            Gitlab::ImportExport::Group::RelationFactory.create(
              relation_index: relation_index,
              relation_sym: key.to_sym,
              relation_hash: hash,
              importable: context.portable,
              members_mapper: members_mapper,
              object_builder: object_builder,
              user: context.current_user,
              excluded_keys: import_export_config.relation_excluded_keys(key)
            )
          end
        end

        def load(_, epic)
          return unless epic

          epic.save! unless epic.persisted?
        end

        private

        def members_mapper
          @members_mapper ||= Gitlab::ImportExport::MembersMapper.new(
            exported_members: [], # importer user is authoring everything for now
            user: context.current_user,
            importable: context.portable
          )
        end
      end
    end
  end
end
