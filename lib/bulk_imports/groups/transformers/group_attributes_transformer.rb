# frozen_string_literal: true

module BulkImports
  module Groups
    module Transformers
      class GroupAttributesTransformer
        def initialize(options = {})
          @options = options
        end

        def transform(context, data)
          data
            .then { |data| transform_name(context, data) }
            .then { |data| transform_path(context, data) }
            .then { |data| transform_full_path(data) }
            .then { |data| transform_parent(context, context, data) }
            .then { |data| transform_visibility_level(data) }
            .then { |data| transform_project_creation_level(data) }
            .then { |data| transform_subgroup_creation_level(data) }
        end

        private

        def transform_name(context, data)
          data.merge(name: context.destination_name)
        end

        def transform_path(context, data)
          data.merge(path: context.destination_name.parameterize)
        end

        def transform_full_path(data)
          data.except(:full_path)
        end

        def transform_parent(context, context, data)
          current_user = context.current_user
          namespace = Namespace.find_by_full_path(context.destination_namespace)

          return data if namespace == current_user.namespace

          data.merge(parent_id: namespace.id)
        end

        def transform_visibility_level(data)
          visibility = data['visibility']

          return data unless visibility.present?

          data
            .merge(visibility_level: Gitlab::VisibilityLevel.string_options[visibility])
            .except(:visibility)
        end

        def transform_project_creation_level(data)
          project_creation_level = data['project_creation_level']

          return data unless project_creation_level.present?

          data.merge(project_creation_level: Gitlab::Access.project_creation_string_options[project_creation_level])
        end

        def transform_subgroup_creation_level(data)
          subgroup_creation_level = data['subgroup_creation_level']

          return data unless subgroup_creation_level.present?

          data.merge(subgroup_creation_level: Gitlab::Access.subgroup_creation_string_options[subgroup_creation_level])
        end
      end
    end
  end
end
