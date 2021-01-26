# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Transformers
        class EpicAttributesTransformer
          def initialize(*args); end

          def transform(context, data)
            parent = data.delete('parent')

            data = update_id_attributes(context, data)
            data = update_description(data)
            data['parent'] = find_or_build_parent_epic(context, parent) if parent
            data
          end

          private

          def update_id_attributes(context, data)
            data['group_id'] = context.entity.namespace_id
            data['author_id'] = context.current_user.id
            data
          end

          # Convert description empty string to nil
          # due to existing object being saved with description: nil
          # Which makes object lookup to fail since nil != ''
          def update_description(data)
            data['description'] == '' ? nil : data['description']
            data
          end

          def find_or_build_parent_epic(context, parent)
            find_epic(context, parent) || build_epic(context, parent)
          end

          def find_epic(context, parent)
            find_attributes = {
              group_id: context.entity.namespace_id,
              title: parent['title'],
              description: parent['description'],
              created_at: parent['created_at']
            }

            ::Epic.find_by(find_attributes) # rubocop: disable CodeReuse/ActiveRecord
          end

          def build_epic(context, attributes)
            parent_attributes = update_id_attributes(context, attributes)

            ::Epic.new(parent_attributes)
          end
        end
      end
    end
  end
end
