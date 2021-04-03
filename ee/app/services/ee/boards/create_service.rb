# frozen_string_literal: true

module EE
  module Boards
    module CreateService
      extend ::Gitlab::Utils::Override

      override :create_board!
      def create_board!
        filter_assignee
        filter_labels
        filter_milestone
        filter_iteration

        super
      end
    end
  end
end
