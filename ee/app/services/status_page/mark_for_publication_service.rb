# frozen_string_literal: true

module StatusPage
  # Marks an issue as published.
  class MarkForPublicationService
    def self.publishable?(project, user, issue)
      project.status_page_setting&.enabled? &&
        user&.can?(:mark_issue_for_publication, project) &&
        !issue.confidential? &&
        !issue.status_page_published_incident
    end

    def initialize(project, user, issue)
      @project = project
      @user = user
      @issue = issue
    end

    def execute
      return error('Issue cannot be published') unless publishable?

      PublishedIncident.transaction do
        track_incident
        add_system_note
      end

      ServiceResponse.success
    rescue StandardError => e
      Gitlab::ErrorTracking.track_exception(e)

      error(e.message)
    end

    private

    attr_reader :user, :project, :issue

    def publishable?
      self.class.publishable?(project, user, issue)
    end

    def add_system_note
      ::SystemNoteService.publish_issue_to_status_page(issue, project, user)
    end

    def track_incident
      ::Gitlab::StatusPage::UsageDataCounters::IncidentCounter.count(:publishes)

      PublishedIncident.track(issue)
    end

    def error(message)
      ServiceResponse.error(message: message)
    end
  end
end
