# frozen_string_literal: true

module AlertManagement
  class CreateAlertIssueService
    include Gitlab::Utils::StrongMemoize

    INCIDENT_LABEL = ::IncidentManagement::CreateIssueService::INCIDENT_LABEL

    # @param alert [AlertManagement::Alert]
    # @param user [User]
    def initialize(alert, user)
      @alert = alert
      @user = user
    end

    def execute
      return error_no_permissions unless allowed?
      return error_issue_already_exists if alert.issue

      result = create_issue
      @issue = result.payload[:issue]

      return error(result.message) if result.error?
      return error(alert.errors.full_messages.to_sentence) unless update_alert_issue_id

      success
    end

    private

    attr_reader :alert, :user, :issue

    delegate :project, to: :alert

    def allowed?
      user.can?(:create_issue, project)
    end

    def create_issue
      issue = do_create_issue(label_ids: issue_label_ids)

      # Create an unlabelled issue if we couldn't create the issue
      # due to labels errors.
      # See https://gitlab.com/gitlab-org/gitlab-foss/issues/65042
      if issue.errors.include?(:labels)
        log_label_error(issue)
        issue = do_create_issue
      end

      return error(issue_errors(issue)) unless issue.valid?

      @issue = issue
      success
    end

    def update_alert_issue_id
      alert.update(issue_id: issue.id)
    end

    def success
      ServiceResponse.success(payload: { issue: issue })
    end

    def error(message)
      ServiceResponse.error(payload: { issue: issue }, message: message)
    end

    def error_issue_already_exists
      error(_('An issue already exists'))
    end

    def error_no_permissions
      error(_('You have no permissions'))
    end

    def do_create_issue(**params)
      Issues::CreateService.new(
        project,
        user,
        title: alert_presenter.title,
        description: alert_presenter.issue_description,
        **params
      ).execute
    end

    def alert_presenter
      strong_memoize(:alert_presenter) do
        alert.present
      end
    end

    def issue_label_ids
      [
        find_or_create_label(**INCIDENT_LABEL)
      ].compact.map(&:id)
    end

    def find_or_create_label(**params)
      Labels::FindOrCreateService
        .new(user, project, **params)
        .execute
    end

    def issue_errors(issue)
      issue.errors.full_messages.to_sentence
    end

    def log_label_error(issue)
      Gitlab::AppLogger.info(
        <<~TEXT.chomp
          Cannot create incident issue with labels \
          #{issue.labels.map(&:title).inspect} \
          for "#{project.full_name}": #{issue.errors.full_messages.to_sentence}.
          Retrying without labels.
        TEXT
      )
    end
  end
end
