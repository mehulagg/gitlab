# frozen_string_literal: true

module BulkImports
  module Groups
    module Pipelines
      class GroupPipeline
        include Pipeline

        abort_on_failure!

        def extract(context)
          Common::Extractors::GraphqlExtractor
            .new(query: Graphql::GetGroupQuery)
            .extract(context)
        end

        def transform(context, entry)
          entry
            .dig('data', 'group')
            .deep_transform_keys { |key| key.to_s.underscore }
            .then { |data| clean_prohibited_attributes(context, data) }
            .then { |data| Transformers::GroupAttributesTransformer.transform(context, data) }
        end

        def load(context, entry)
          return unless user_can_create_group?(context.current_user, entry)

          ::Groups::CreateService.new(context.current_user, entry).execute.tap do |group|
            context.entity.update!(group: group)
          end
        end

        private

        def user_can_create_group?(current_user, data)
          if data['parent_id']
            parent = Namespace.find_by_id(data['parent_id'])

            Ability.allowed?(current_user, :create_subgroup, parent)
          else
            Ability.allowed?(current_user, :create_group)
          end
        end
      end
    end
  end
end
