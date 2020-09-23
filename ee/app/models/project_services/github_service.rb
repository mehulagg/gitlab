# frozen_string_literal: true

class GithubService < Service
  include Gitlab::Routing
  include ActionView::Helpers::UrlHelper

  prop_accessor :token, :repository_url
  boolean_accessor :static_context

  delegate :api_url, :owner, :repository_name, to: :remote_project

  validates :token, presence: true, if: :activated?
  validates :repository_url, public_url: true, allow_blank: true

  default_value_for :pipeline_events, true

  def initialize_properties
    self.properties ||= { static_context: true }
  end

  def title
    'GitHub'
  end

  def description
    "See pipeline statuses on GitHub for your commits and pull requests"
  end

  def detailed_description
    mirror_path = project_settings_repository_path(project)
    mirror_link = link_to('mirroring your GitHub repository', mirror_path)
    "This requires #{mirror_link} to this project.".html_safe
  end

  def self.to_param
    'github'
  end

  def fields
    [
      { type: 'password',
        name: "token",
        required: true,
        placeholder: "e.g. 8d3f016698e...",
        help: 'Create a <a href="https://github.com/settings/tokens">personal access token</a> with  <code>repo:status</code> access granted and paste it here.'.html_safe },
      { type: 'text',
        name: "repository_url",
        title: 'Repository URL',
        required: true,
        placeholder: 'e.g. https://github.com/owner/repository' },
      { type: 'checkbox',
        name: "static_context",
        title: 'Static status check names',
        help: 'GitHub status checks need static name in order to be marked as "required".' }
    ]
  end

  def self.supported_events
    %w(pipeline)
  end

  def can_test?
    project&.ci_pipelines&.any?
  end

  def execute(data)
    return if disabled? || invalid? || irrelevant_result?(data)

    status_message = StatusMessage.from_pipeline_data(project, self, data)

    update_status(status_message)
  end

  def test(data)
    begin
      result = execute(data)

      context = result[:context]
      by_user = result.dig(:creator, :login)
      result = "Status for #{context} updated by #{by_user}" if context && by_user
    rescue StandardError => error
      return { success: false, result: error }
    end

    { success: true, result: result }
  end

  private

  def irrelevant_result?(data)
    !external_pull_request_pipeline?(data) &&
      external_pull_request_pipelines_exist_for_sha?(data)
  end

  def external_pull_request_pipeline?(data)
    id = data.dig(:object_attributes, :id)

    external_pull_request_pipelines.id_in(id).exists?
  end

  def external_pull_request_pipelines_exist_for_sha?(data)
    sha = data.dig(:object_attributes, :sha)

    return false if sha.nil?

    external_pull_request_pipelines.for_sha(sha).exists?
  end

  def external_pull_request_pipelines
    @external_pull_request_pipelines ||= project
      .ci_pipelines
      .external_pull_request_event
  end

  def remote_project
    RemoteProject.new(repository_url)
  end

  def disabled?
    project.disabled_services.include?(to_param)
  end

  def update_status(status_message)
    notifier.notify(status_message.sha,
                    status_message.status,
                    status_message.status_options)
  end

  def notifier
    StatusNotifier.new(token, remote_repo_path, api_endpoint: api_url)
  end

  def remote_repo_path
    "#{owner}/#{repository_name}"
  end
end
