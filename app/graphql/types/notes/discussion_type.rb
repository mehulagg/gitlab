# frozen_string_literal: true

module Types
  module Notes
    class DiscussionType < BaseObject
      DiscussionID = ::Types::GlobalIDType[::Discussion]

      graphql_name 'Discussion'

      authorize :read_note

      implements(Types::ResolvableInterface)

      field :id, DiscussionID, null: false,
            description: "ID of this discussion."
      field :reply_id, DiscussionID, null: false,
            description: 'ID used to reply to this discussion.'
      field :created_at, Types::TimeType, null: false,
            description: "Timestamp of the discussion's creation."
      field :notes, Types::Notes::NoteType.connection_type, null: false,
            description: 'All notes in the discussion.'
      field :noteable, Types::NoteableType, null: true, # null is true for because NoteableType union does not implement all types yet.
            description: 'Object which the discussion belongs to.'

      # DiscussionID.coerce_result is suitable here, but will always mark this
      # as being a 'Discussion'. Using `GlobalId.build` guarantees that we get
      # the correct class, and that it matches `id`.
      def reply_id
        ::Gitlab::GlobalId.build(object, id: object.reply_id)
      end

      def noteable
        # Todo: maybe use resolver or allow batch loading
        noteable = object.noteable

        # This should never happen, if user can read discussion it can read noteable, but it feels safer to have it here
        return unless Ability.allowed?(context[:current_user], :"read_#{noteable.to_ability_name}", noteable)

        noteable
      end
    end
  end
end
