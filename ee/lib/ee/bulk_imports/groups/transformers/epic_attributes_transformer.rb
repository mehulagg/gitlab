# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Transformers
        class EpicAttributesTransformer
          def initialize(*args); end

          def transform(context, data)
            parent = data['parent']

            data = update_id_attributes(context, data)
            data['parent'] = update_id_attributes(context, parent) if parent
            data
          end

          private

          def update_id_attributes(context, data)
            data['group_id'] = context.entity.namespace_id
            data['author_id'] = context.current_user.id
            data
          end
        end
      end
    end
  end
end
