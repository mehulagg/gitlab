# frozen_string_literal: true

# This class is abstract class of Issue Tracker which support create cross reference comment and close issue on 3rd
#  party issue tracker platform. So every issue tracker integration should extend this class and override the corresponding
#  method based on the feature supported.
class ReferableIssueTrackerService < IssueTrackerService
  include Gitlab::Routing
  include ApplicationHelper
  include ActionView::Helpers::AssetUrlHelper
  extend ::Gitlab::Utils::Override

  GENERAL_ISSUE_FORMAT_REGEXP = /(?<issue>\b([A-Z][A-Z0-9_]+-)\d+)/

  override :title
  def title
    self.properties&.dig('title') || self.class.issue_tracker_name
  end

  override :description
  def description
    self.properties&.dig('description') || "#{self.class.issue_tracker_name.titlecase} issue tracker"
  end

  override :execute
  def execute(push)
    # This method is a no-op, because currently JiraService does not
    # support any events.
    raise NotImplementedError
  end

  def self.issue_tracker_name
    'Referable Issue Tracker'
  end

  def support_close_issue?
    activated?
  end

  def support_cross_reference?
    activated?
  end

  # When these are false GitLab does not create cross reference
  # comments on Referable Issue Tracker except when an issue gets transitioned.
  # TODO: Discussion Are these comments right? I think this method only for return the events list to support trigger action.
  override :supported_events
  def self.supported_events
    %w(commit merge_request)
  end

  # {PROJECT-KEY}-{NUMBER} Examples: JIRA-1, PROJECT-1
  override :reference_pattern
  def self.reference_pattern(only_long: true)
    @reference_pattern ||= GENERAL_ISSUE_FORMAT_REGEXP
  end

  # the description for the event which support push comment to the issue
  override :event_description
  def self.event_description(event)
    case event
    when 'merge_request', 'merge_request_events'
      "#{self.issue_tracker_name} comments will be created when an issue gets referenced in a merge request."
    when 'commit', 'commit_events'
      "#{self.issue_tracker_name} comments will be created when an issue gets referenced in a commit."
    end
  end

  # if support_cross_reference? can be true, this method should be override
  # Invoke 3rd party issue tracker API to create cross reference comment
  def create_cross_reference_note(mentioned, noteable, author)
    unless can_cross_reference?(noteable)
      return "Events for #{noteable.model_name.plural.humanize(capitalize: false)} are disabled."
    end

    external_issue = tracker_issue_by_gitlab_id(mentioned.id)

    return unless external_issue.present?

    data = generate_cross_ref_data(noteable, author)
    add_comment(data, external_issue)
  end

  # The concrete service class should override this method: get the external issue by given mentioned_id
  def tracker_issue_by_gitlab_id(mentioned_id)
    raise NotImplementedError
  end

  # if support_close_issue? can be true, this method should be override
  # Invoke 3rd party issue tracker API to close corresponding issue
  def close_issue(entity, external_issue)
    raise NotImplementedError
  end

  # get commit_id by entity
  def commit_id(entity)
    if entity.is_a?(Commit)
      entity.id
    elsif entity.is_a?(MergeRequest)
      entity.diff_head_sha
    end
  end

  def can_cross_reference?(noteable)
    case noteable
    when Commit then
      commit_events
    when MergeRequest then
      merge_requests_events
    else
      true
    end
  end

  def noteable_name(noteable)
    name = noteable.model_name.singular

    # ProjectSnippet inherits from Snippet class so it causes
    # routing error building the URL.
    name == 'project_snippet' ? 'snippet' : name
  end

  def build_entity_url(noteable_type, entity_id)
    polymorphic_url(
      [
          self.project.namespace.becomes(Namespace),
          self.project,
          noteable_type.to_sym
      ],
        id: entity_id,
        host: Settings.gitlab.base_url
    )
  end

  def resource_url(resource)
    "#{Settings.gitlab.base_url.chomp("/")}#{resource}"
  end

  # this method build the link to the gitlab, which can be used if the issue tracker support add related link such as JIRA.
  def build_remote_link_props(url:, title:, resolved: false)
    status = {
        resolved: resolved
    }

    {
        GlobalID: 'GitLab',
        object: {
            url: url,
            title: title,
            status: status,
            icon: {
                title: 'GitLab', url16x16: asset_url(Gitlab::Favicon.main, host: gitlab_config.url)
            }
        }
    }
  end

  # generate the data structure which is used to build cross reference message
  def generate_cross_ref_data(noteable, author)
    noteable_id = noteable.respond_to?(:iid) ? noteable.iid : noteable.id
    noteable_type = noteable_name(noteable)
    entity_url = build_entity_url(noteable_type, noteable_id)

    {
        user: {
            name: author.name,
            url: resource_url(user_path(author))
        },
        project: {
            name: project.full_path,
            url: resource_url(namespace_project_path(project.namespace, project)) # rubocop:disable Cop/ProjectPathHelper
        },
        entity: {
            name: noteable_type.humanize.downcase,
            url: entity_url,
            title: noteable.title
        }
    }
  end

  # default message style is MARKDOWN, and we can support MARKDOWN and JIRA format
  def message_format_style
    'MARKDOWN'
  end

  # build message based on style, current support MARKDOWN and JIRA.
  # <b>Develop Note</b>: Other format need to override this method to customize.
  def generate_cross_ref_message(data)
    cross_ref_message = CrossRefMessage.new(data)

    return cross_ref_message.jira_message if message_format_style == 'JIRA'

    # default style is markdown
    cross_ref_message.markdown_message
  end

  # add cross reference comment to the 3rd party issue tracker platform.
  # the issue parameter is the identity the 3rd party service issue, it can be unique id string or object such as JIRA issue
  def add_comment(data, issue)
    entity_name = data[:entity][:name]
    entity_url = data[:entity][:url]
    entity_title = data[:entity][:title]

    # default style is markdown
    message = generate_cross_ref_message(data)
    link_title = "GitLab: Mentioned on #{entity_name} - #{entity_title}"
    link_props = build_remote_link_props(url: entity_url, title: link_title)

    unless comment_exists?(issue, message)
      send_message(issue, message, link_props)
    end
  end

  # build close issue message based on style, current support MARKDOWN and JIRA.
  # <b>Develop Note</b>: Other format need to override this method to customize.
  def generate_close_message(commit_id, commit_url)
    comment = "Issue solved with [#{commit_id}](#{commit_url})."

    if message_format_style == "JIRA"
      comment = "Issue solved with [#{commit_id}|#{commit_url}]."
    end

    comment
  end

  # add close issue comment to the 3rd party issue tracker platform.
  # the issue parameter is the identity the 3rd party service issue, it can be unique id string or object such as JIRA issue
  def add_issue_solved_comment(issue, commit_id, commit_url)
    link_title = "GitLab: Solved by commit #{commit_id}."
    # we use the markdown syntax to build comment
    comment = generate_close_message(commit_id, commit_url)
    link_props = build_remote_link_props(url: commit_url, title: link_title, resolved: true)
    send_message(issue, comment, link_props)
  end

  def send_message(issue, message, remote_link_props)
    raise NotImplementedError
  end

  # Should we need to check if the comment exists, we can override this method. Defaults to false to indicate a comment does not exist by default.
  def comment_exists?(issue, message)
    false
  end
end
