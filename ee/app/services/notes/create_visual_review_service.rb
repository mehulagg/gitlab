# frozen_string_literal: true

module Notes
  class CreateVisualReviewService < CreateService
    def initialize(merge_request, current_user, body:, position: nil)
      super(
        merge_request.project,
        User.visual_review_bot,
        {
          note: note_body(current_user, body),
          position: position,
          type: 'DiscussionNote',
          noteable_type: 'MergeRequest',
          noteable_id: merge_request.id
        }
      )
    end

    private

    def note_body(user, body)
      if user && body.present?
        "**Feedback from @#{user.username} (#{user.email})**\n\n#{body}"
      else
        body
      end
    end
  end
end
