# frozen_string_literal: true

module Resolvers
  class NotesResolver < BaseResolver
    argument :sort, Types::NoteSortEnum,
             description: 'Sort notes by this criteria.',
             required: false

    type Types::Notes::NoteType.connection_type, null: false

    def resolve(**args)
      return object.notes unless args[:sort].present?

      object.notes.order_by(args[:sort])
    end
  end
end
