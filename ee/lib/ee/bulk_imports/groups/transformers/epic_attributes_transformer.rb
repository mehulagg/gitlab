# frozen_string_literal: true

module EE
  module BulkImports
    module Groups
      module Transformers
        class EpicAttributesTransformer
          def initialize(*args); end

          def transform(context, data)
            data
              .then { |data| add_group_id(context, data) }
              .then { |data| add_author_id(context, data) }
              .then { |data| add_parent(context, data) }
              .then { |data| add_children(context, data) }
          end

          private

          def add_group_id(context, data)
            data.merge('group_id' => context.entity.namespace_id)
          end

          def add_author_id(context, data)
            data.merge('author_id' => context.current_user.id)
          end

          def add_parent(context, data)
            data.merge(
              'parent' => context.group.epics.find_by_iid(data.dig('parent', 'iid'))
            )
          end

          def add_children(context, data)
            nodes = Array.wrap(data.dig('children', 'nodes'))
            children_iids = nodes.filter_map { |child| child['iid'] }

            data.merge('children' => context.group.epics.where(iid: children_iids))
          end
        end
      end
    end
  end
end
