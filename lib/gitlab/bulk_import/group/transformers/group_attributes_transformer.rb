# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Group
      module Transformers
        class GroupAttributesTransformer
          class << self
            def transform(_, data)
              data
                .then { |data| transform_visibility_level(data) }
                .then { |data| transform_project_creation_level(data) }
                .then { |data| transform_subgroup_creation_level(data) }
            end

            def transform_visibility_level(data)
              visibility = data['visibility']

              return data unless visibility.present?

              data['visibility_level'] = Gitlab::VisibilityLevel.string_options[visibility]
              data.delete('visibility')
              data
            end

            def transform_project_creation_level(data)
              project_creation_level = data['project_creation_level']

              return data unless project_creation_level.present?

              data['project_creation_level'] = Gitlab::Access.project_creation_string_options[project_creation_level]
              data
            end

            def transform_subgroup_creation_level(data)
              subgroup_creation_level = data['subgroup_creation_level']

              return data unless subgroup_creation_level.present?

              data['subgroup_creation_level'] = Gitlab::Access.subgroup_creation_string_options[subgroup_creation_level]
              data
            end
          end
        end
      end
    end
  end
end
