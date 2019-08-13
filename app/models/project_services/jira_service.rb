# frozen_string_literal: true

class JiraService < ReferableIssueTrackerService
  extend ::Gitlab::Utils::Override
  include Gitlab::Routing
  include ApplicationHelper
  include ActionView::Helpers::AssetUrlHelper

  validates :url, public_url: true, presence: true, if: :activated?
  validates :api_url, public_url: true, allow_blank: true
  validates :username, presence: true, if: :activated?
  validates :password, presence: true, if: :activated?

  validates :jira_issue_transition_id,
            format: { with: Gitlab::Regex.jira_transition_id_regex, message: s_("JiraService|transition ids can have only numbers which can be split with , or ;") },
            allow_blank: true

  # Jira Cloud version is deprecating authentication via username and password.
  # We should use username/password for Jira Server and email/api_token for Jira Cloud,
  # for more information check: https://gitlab.com/gitlab-org/gitlab-foss/issues/49936.

  # TODO: we can probably just delegate as part of
  # https://gitlab.com/gitlab-org/gitlab/issues/29404
  data_field :username, :password, :url, :api_url, :jira_issue_transition_id

  before_update :reset_password

  alias_method :project_url, :url

  # When these are false GitLab does not create cross reference
  # comments on Jira except when an issue gets transitioned.
  def self.supported_events
    %w(commit merge_request)
  end

  def self.supported_event_actions
    %w(comment)
  end

  # {PROJECT-KEY}-{NUMBER} Examples: JIRA-1, PROJECT-1
  def self.reference_pattern(only_long: true)
    @reference_pattern ||= /(?<issue>\b#{Gitlab::Regex.jira_issue_key_regex})/
  end

  override :issue_tracker_name
  def self.issue_tracker_name
    "JIRA"
  end

  override :initialize_properties
  def initialize_properties
    {}
  end

  def data_fields
    jira_tracker_data || self.build_jira_tracker_data
  end

  def reset_password
    data_fields.password = nil if reset_password?
  end

  def set_default_data
    return unless issues_tracker.present?

    self.title ||= issues_tracker['title']

    return if url

    data_fields.url ||= issues_tracker['url']
    data_fields.api_url ||= issues_tracker['api_url']
  end

  def options
    url = URI.parse(client_url)

    {
      username: username&.strip,
      password: password,
      site: URI.join(url, '/').to_s, # Intended to find the root
      context_path: url.path,
      auth_type: :basic,
      read_timeout: 120,
      use_cookies: true,
      additional_cookies: ['OBBasicAuth=fromDialog'],
      use_ssl: url.scheme == 'https'
    }
  end

  def client
    @client ||= begin
      JIRA::Client.new(options).tap do |client|
        # Replaces JIRA default http client with our implementation
        client.request_client = Gitlab::Jira::HttpClient.new(client.options)
      end
    end
  end

  override :help
  def help
    "You need to configure Jira before enabling this service. For more details
    read the
    [Jira service documentation](#{help_page_url('user/project/integrations/jira')})."
  end

  def default_title
    'Jira'
  end

  def default_description
    s_('JiraService|Jira issue tracker')
  end

  override :to_param
  def self.to_param
    'jira'
  end

  override :fields
  def fields
    [
      { type: 'text', name: 'url', title: s_('JiraService|Web URL'), placeholder: 'https://jira.example.com', required: true },
      { type: 'text', name: 'api_url', title: s_('JiraService|Jira API URL'), placeholder: s_('JiraService|If different from Web URL') },
      { type: 'text', name: 'username', title: s_('JiraService|Username or Email'), placeholder: s_('JiraService|Use a username for server version and an email for cloud version'), required: true },
      { type: 'password', name: 'password', title: s_('JiraService|Password or API token'), placeholder: s_('JiraService|Use a password for server version and an API token for cloud version'), required: true },
      { type: 'text', name: 'jira_issue_transition_id', title: s_('JiraService|Transition ID(s)'), placeholder: s_('JiraService|Use , or ; to separate multiple transition IDs') }
    ]
  end

  def issues_url
    "#{url}/browse/:id"
  end

  def new_issue_url
    "#{url}/secure/CreateIssue.jspa"
  end

  alias_method :original_url, :url
  def url
    original_url&.delete_suffix('/')
  end

  alias_method :original_api_url, :api_url
  def api_url
    original_api_url&.delete_suffix('/')
  end

  def execute(push)
    # This method is a no-op, because currently JiraService does not
    # support any events.
  end

  override :message_format_style
  def message_format_style
    "JIRA"
  end

  override :close_issue
  def close_issue(entity, external_issue)
    issue = jira_request { client.Issue.find(external_issue.iid) }

    return if issue.nil? || has_resolution?(issue) || !jira_issue_transition_id.present?

    commit_id = case entity
                when Commit then entity.id
                when MergeRequest then entity.diff_head_sha
                end

    commit_url = build_entity_url(:commit, commit_id)

    # Depending on the Jira project's workflow, a comment during transition
    # may or may not be allowed. Refresh the issue after transition and check
    # if it is closed, so we don't have one comment for every commit.
    issue = jira_request { client.Issue.find(issue.key) } if transition_issue(issue)
    add_issue_solved_comment(issue, commit_id, commit_url) if has_resolution?(issue)
  end

  # User JIRA client to find the JIRA issue by the mentioned id
  def tracker_issue_by_gitlab_id(mentioned_id)
    jira_request { client.Issue.find(mentioned_id) }
  end

  override :test
  def test(_)
    result = test_settings
    success = result.present?
    result = @error&.message unless success

    { success: success, result: result }
  end

  # Jira does not need test data.
  # We are requesting the project that belongs to the project key.
  override :test_data
  def test_data(user = nil, project = nil)
    nil
  end

  override :support_close_issue?
  def support_close_issue?
    true
  end

  override :support_cross_reference?
  def support_cross_reference?
    true
  end

  private

  def test_settings
    return unless client_url.present?

    # Test settings by getting the project
    jira_request { client.ServerInfo.all.attrs }
  end

  def can_cross_reference?(noteable)
    case noteable
    when Commit then commit_events
    when MergeRequest then merge_requests_events
    else true
    end
  end

  private

  # jira_issue_transition_id can have multiple values split by , or ;
  # the issue is transitioned at the order given by the user
  # if any transition fails it will log the error message and stop the transition sequence
  def transition_issue(issue)
    jira_issue_transition_id.scan(Gitlab::Regex.jira_transition_id_regex).each do |transition_id|
      issue.transitions.build.save!(transition: { id: transition_id })
    rescue => error
      log_error(
        "Issue transition failed",
          error: {
            exception_class: error.class.name,
            exception_message: error.message,
            exception_backtrace: Gitlab::BacktraceCleaner.clean_backtrace(error.backtrace)
          },
         client_url: client_url
      )
      return false
    end
  end

  def has_resolution?(issue)
    issue.respond_to?(:resolution) && issue.resolution.present?
  end

  def comment_exists?(issue, message)
    comments = jira_request { issue.comments }

    comments.present? && comments.any? { |comment| comment.body.include?(message) }
  end

  override :send_message
  def send_message(issue, message, remote_link_props)
    return unless client_url.present?

    jira_request do
      remote_link = find_remote_link(issue, remote_link_props[:object][:url])

      create_issue_comment(issue, message) unless remote_link
      remote_link ||= issue.remotelink.build
      remote_link.save!(remote_link_props)

      log_info("Successfully posted", client_url: client_url)
      "SUCCESS: Successfully posted to #{client_url}."
    end
  end

  def create_issue_comment(issue, message)
    return unless comment_on_event_enabled

    issue.comments.build.save!(body: message)
  end

  def find_remote_link(issue, url)
    links = jira_request { issue.remotelink.all }
    return unless links

    links.find { |link| link.object["url"] == url }
  end

  def build_remote_link_props(url:, title:, resolved: false)
    status = {
      resolved: resolved
    }

    {
      GlobalID: 'GitLab',
      relationship: 'mentioned on',
      object: {
        url: url,
        title: title,
        status: status,
        icon: {
          title: 'GitLab', url16x16: asset_url(Gitlab::Favicon.main, host: gitlab_config.base_url)
        }
      }
    }
  end

  def resource_url(resource)
    "#{Settings.gitlab.base_url.chomp("/")}#{resource}"
  end

  def build_entity_url(noteable_type, entity_id)
    polymorphic_url(
      [
        self.project.namespace.becomes(Namespace),
        self.project,
        noteable_type.to_sym
      ],
      id:   entity_id,
      host: Settings.gitlab.base_url
    )
  end

  def noteable_name(noteable)
    name = noteable.model_name.singular

    # ProjectSnippet inherits from Snippet class so it causes
    # routing error building the URL.
    name == "project_snippet" ? "snippet" : name
  end

  # Handle errors when doing Jira API calls
  def jira_request
    yield
  rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, Errno::ECONNREFUSED, URI::InvalidURIError, JIRA::HTTPError, OpenSSL::SSL::SSLError => error
    @error = error
    log_error(
      "Error sending message",
      client_url: client_url,
      error: {
        exception_class: error.class.name,
        exception_message: error.message,
        exception_backtrace: Gitlab::BacktraceCleaner.clean_backtrace(error.backtrace)
      }
    )
    nil
  end

  def client_url
    api_url.presence || url
  end

  def reset_password?
    # don't reset the password if a new one is provided
    return false if password_touched?
    return true if api_url_changed?
    return false if api_url.present?

    url_changed?
  end

  def self.event_description(event)
    case event
    when "merge_request", "merge_request_events"
      s_("JiraService|Jira comments will be created when an issue gets referenced in a merge request.")
    when "commit", "commit_events"
      s_("JiraService|Jira comments will be created when an issue gets referenced in a commit.")
    end
  end
end
