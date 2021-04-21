# frozen_string_literal: true

module BulkImports
  module Groups
    module Transformers
      class EpicAttributesTransformer
        def transform(context, data)
          data
            .then { |data| add_parent(context, data) }
            .then { |data| add_children(context, data) }
            .then { |data| add_labels(context, data) }
        end

        private

        def add_parent(context, data)
          data.merge(
            'parent' => context.group.epics.find_by_iid(data.dig('parent', 'iid'))
          )
        end

        def add_children(context, data)
          nodes = Array.wrap(data.dig('children', 'nodes'))
          children_iids = nodes.filter_map { |child| child['iid'] }

          data.merge('children' => context.group.epics.where(iid: children_iids)) # rubocop: disable CodeReuse/ActiveRecord
        end

        def add_labels(context, data)
          data['labels'] = data.dig('labels', 'nodes').filter_map do |node|
            context.group.labels.find_by_title(node['title'])
          end

          data
        end
      end
    end
  end
end
