# frozen_string_literal: true

module Todos
  module Destroy
    # Service class for deleting todos that belong to confidential epics.
    # It deletes todos for users that are not at least reporters.
    class ConfidentialEpicService < ::Todos::Destroy::BaseService
      extend ::Gitlab::Utils::Override

      attr_reader :epic

      def initialize(epic_id:)
        @epic = ::Epic.find_by_id(epic_id)
      end

      private

      override :todos
      def todos
        epic.todos
      end

      override :todos_to_remove?
      def todos_to_remove?
        epic&.confidential?
      end

      override :authorized_users
      def authorized_users
        epic.group.members_with_parents.non_guests.select(:user_id)
      end
    end
  end
end
