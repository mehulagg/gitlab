# frozen_string_literal: true

module NotificationRecipients
  module Builder
    class RequestReview < Base
      attr_reader :current_user, :merge_request, :reviewer
      def initialize(current_user, merge_request, reviewer)
        @current_user, @merge_request, @reviewer = current_user, merge_request, reviewer
      end

      def target
        merge_request
      end

      def build!
        add_recipients(reviewer, :participating, nil)
      end
    end
  end
end
