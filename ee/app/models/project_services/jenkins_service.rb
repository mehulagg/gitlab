# frozen_string_literal: true

class JenkinsService < CiService
  prop_accessor :jenkins_url, :project_name, :username, :password

  before_update :reset_password

  validates :jenkins_url, presence: true, addressable_url: true, if: :activated?
  validates :project_name, presence: true, if: :activated?
  validates :username, presence: true, if: ->(service) { service.activated? && service.password_touched? && service.password.present? }

  default_value_for :push_events, true
  default_value_for :merge_requests_events, false
  default_value_for :tag_push_events, false

  after_save :compose_service_hook, if: :activated?

  def reset_password
    # don't reset the password if a new one is provided
    if (jenkins_url_changed? || username.blank?) && !password_touched?
      self.password = nil
    end
  end

  def compose_service_hook
    hook = service_hook || build_service_hook
    hook.url = hook_url
    hook.save
  end

  def execute(data)
    return if project.disabled_services.include?(to_param)
    return unless supported_events.include?(data[:object_kind])

    if data[:object_kind] == 'push'
      # TODO Find a more elegant way to do this. Maybe in another service class
      pipeline = start_pipeline(data)
      status = find_or_create_status(pipeline)
      status.enqueue!
    end

    hook_response = service_hook.execute(data, "#{data[:object_kind]}_hook")

    if hook_response[:status] == :error
      status.update(description: hook_response[:message])
      status.drop!
    end

    hook_response
  end

  def start_pipeline(data)
    commit_sha = data[:checkout_sha]
    ref = data[:ref].dup

    # TODO is it right to slice it like this? It is what the plugin does too https://github.com/jenkinsci/gitlab-plugin/blob/d316c20bfe9074feb2888b88dee3dba5c0a298ad/src/main/java/com/dabsquared/gitlabjenkins/trigger/handler/pipeline/PipelineHookTriggerHandlerImpl.java#L91
    ref.slice!('refs/heads/')
    project.ci_pipelines.create!(
      source: :external,
      sha: commit_sha,
      ref: ref,
      protected: project.protected_for?(ref)
    )
  end

  def find_or_create_status(pipeline)
    GenericCommitStatus.running_or_pending.find_or_create_by(
      project: project,
      pipeline: pipeline,
      name: 'Jenkins Webhook',
      ref: pipeline.ref,
      protected: project.protected_for?(pipeline.ref)
    )
  end

  def test(data)
    begin
      result = execute(data)
      return { success: false, result: result[:message] } if result[:http_status] != 200
    rescue StandardError => error
      return { success: false, result: error }
    end

    { success: true, result: result[:message] }
  end

  def hook_url
    url = URI.parse(jenkins_url)
    url.path = File.join(url.path || '/', "project/#{project_name}")
    url.user = ERB::Util.url_encode(username) unless username.blank?
    url.password = ERB::Util.url_encode(password) unless password.blank?
    url.to_s
  end

  def self.supported_events
    %w(push merge_request tag_push)
  end

  def title
    'Jenkins CI'
  end

  def description
    'An extendable open source continuous integration server'
  end

  def help
    "You must have installed the Git Plugin and GitLab Plugin in Jenkins. [More information](#{Gitlab::Routing.url_helpers.help_page_url('integration/jenkins')})"
  end

  def self.to_param
    'jenkins'
  end

  def fields
    [
      {
        type: 'text', name: 'jenkins_url',
        placeholder: 'Jenkins URL like http://jenkins.example.com'
      },
      {
        type: 'text', name: 'project_name', placeholder: 'Project Name',
        help: 'The URL-friendly project name. Example: my_project_name'
      },
      { type: 'text', name: 'username' },
      { type: 'password', name: 'password' }
    ]
  end
end
