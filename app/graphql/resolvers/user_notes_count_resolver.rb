# frozen_string_literal: true

module Resolvers
  class UserNotesCountResolver < BaseResolver
    include Gitlab::Graphql::Authorize::AuthorizeResource

    type Types::UserNotesCount, null: true

    authorize :read_issue

    private

    def resolve
      BatchLoader::GraphQL.for(object.id).batch(key: :issue_user_notes_count) do |ids, loader, args|
        counts = Note.count_for_collection(ids, 'Issue').index_by(&:noteable_id)

        ids.each do |id|
          loader.call(id, counts[id]&.count || 0)
        end
      end
    end
  end
end
