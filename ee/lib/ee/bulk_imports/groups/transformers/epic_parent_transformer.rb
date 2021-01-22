# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Transformers
        class EpicParentTransformer
          def initialize(*args); end

          def transform(context, data)
            entity = context.entity

            Array.wrap(data['nodes']).each do |epic|
              parent = epic.delete('parent')

              epic['parent'] = find_or_build_parent_epic(entity, parent) if parent
            end

            data
          end

          private

          def find_or_build_parent_epic(entity, parent)
            find_epic(entity, parent) || build_epic(parent)
          end

          def find_epic(entity, attributes)
            find_attributes = {
              group_id: entity.namespace_id,
              title: attributes['title'],
              description: attributes['description'],
              created_at: attributes['created_at']
            }

            ::Epic.find_by(find_attributes) # rubocop: disable CodeReuse/ActiveRecord
          end

          def build_epic(attributes)
            ::Epic.new(attributes)
          end
        end
      end
    end
  end
end
