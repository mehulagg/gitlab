# frozen_string_literal: true

module StatusPage
  # Triggers a background job to publish of incidents to the status page.
  #
  # This service determines whether the passed +triggered_by+ (issue, note,
  # or emoji) is eligible to kick-off the publish process.
  class TriggerPublishService
    include Gitlab::Utils::StrongMemoize

    # Publish status page only if the following issue attributes have changed.
    # If we expose new fields in +StatusPage::IncidentEntity+ add them to
    # this list too.
    #
    # Note: `closed_by_id` is needed because we cannot rely on `state_id` in
    # Issues::CloseService
    PUBLISH_WHEN_ISSUE_CHANGED =
      %w[title description confidential state_id closed_by_id].freeze

    VALID_ACTIONS = %i[init update].freeze

    def initialize(project, user, triggered_by, action:)
      @project = project
      @user = user
      @triggered_by = triggered_by
      @action = set_action(action)
    end

    def execute
      return unless can_publish?
      return unless status_page_enabled?
      return unless issue_id

      StatusPage::PublishWorker.perform_async(user.id, project.id, issue_id)
    end

    private

    attr_reader :user, :project, :triggered_by, :action

    def set_action(action)
      raise ArgumentError, 'Invalid action' unless VALID_ACTIONS.include?(action)

      action
    end

    def update?
      action == :update
    end

    def init?
      action == :init
    end

    def can_publish?
      user&.can?(:publish_status_page, project)
    end

    def status_page_enabled?
      project.status_page_setting&.enabled?
    end

    def issue_id
      strong_memoize(:issue_id) { eligable_issue_id }
    end

    def eligable_issue_id
      case triggered_by
      when Issue then eligable_issue_id_from_issue
      when Note then eligable_issue_id_from_note
      when AwardEmoji then eligable_issue_id_from_award_emoji
      else
        raise ArgumentError, "unsupported trigger type #{triggered_by.class}"
      end
    end

    # Trigger publish for public (non-confidential) issues
    # - which were changed
    # - which were not changed, and the action is not update (i.e init action)
    # - just become confidential to unpublish
    def eligable_issue_id_from_issue
      issue = triggered_by

      changes = issue.previous_changes.keys & PUBLISH_WHEN_ISSUE_CHANGED

      return if update? && changes.none?
      return if issue.confidential? && changes.exclude?('confidential')
      return unless issue.status_page_published_incident

      issue.id
    end

    # Trigger publish for notes
    # - on issues
    # - which are user-generated (non-system)
    # - which were changed or destroyed
    # - had emoji `microphone` on it
    def eligable_issue_id_from_note
      note = triggered_by

      return unless note.for_issue?
      return if note.system?
      # We can't know the emoji if the note was destroyed, so
      # publish every time to make sure we remove the comment if needed
      return note.noteable_id if note.destroyed?

      return if note.previous_changes.none?
      return if note.award_emoji.named(Gitlab::StatusPage::AWARD_EMOJI).none?

      note.noteable_id
    end

    def eligable_issue_id_from_award_emoji
      award_emoji = triggered_by

      return unless award_emoji.name == Gitlab::StatusPage::AWARD_EMOJI
      return unless award_emoji.awardable.is_a?(Note)
      return unless award_emoji.awardable.for_issue?

      award_emoji.awardable.noteable_id
    end
  end
end
