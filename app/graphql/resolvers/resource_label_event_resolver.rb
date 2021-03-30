# frozen_string_literal: true

module Resolvers
  class ResourceLabelEventResolver < BaseResolver
    type ::Types::ResourceLabelEventType.connection_type, null: true
    description 'Label events, indicating when labels were added and removed.'

    def resolve
      BatchLoader::GraphQL.for(object.id).batch(key: object.class) do |ids, loader, args|
        model = args[:key]
        relation = for_ids(model, ids)
        next [] unless relation

        relation.order(created_at: :desc).preload(:label)

        if ids.one?
          loader.call(ids.first, relation)
        else
          relation.each do |event|
            loader.call(event.id) { |vs| vs << event }
          end
        end
      end
    end

    def for_ids(model, ids)
      return ResourceLabelEvent.where(issue_id: ids) if model == ::Issue
      return ResourceLabelEvent.where(merge_request_id: ids) if model == ::MergeRequest
    end
  end
end
