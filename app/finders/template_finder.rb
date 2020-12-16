# frozen_string_literal: true

class TemplateFinder
  include Gitlab::Utils::StrongMemoize

  VENDORED_TEMPLATES = HashWithIndifferentAccess.new(
    dockerfiles: ::Gitlab::Template::DockerfileTemplate,
    gitignores: ::Gitlab::Template::GitignoreTemplate,
    gitlab_ci_ymls: ::Gitlab::Template::GitlabCiYmlTemplate,
    metrics_dashboard_ymls: ::Gitlab::Template::MetricsDashboardTemplate,
    issues: ::Gitlab::Template::IssueTemplate,
    merge_requests: ::Gitlab::Template::MergeRequestTemplate
  ).freeze

  class << self
    def build(type, project, current_user = nil, params = {})
      if type.to_s == 'licenses'
        LicenseTemplateFinder.new(project, current_user, params) # rubocop: disable CodeReuse/Finder
      else
        new(type, project, current_user, params)
      end
    end
  end

  attr_reader :type, :project, :current_user, :params

  attr_reader :vendored_templates
  private :vendored_templates

  def initialize(type, project, current_user = nil, params = {})
    @type = type
    @project = project
    @current_user = current_user
    @params = params

    @vendored_templates = VENDORED_TEMPLATES.fetch(type)
  end

  def execute
    if params[:name]
      vendored_templates.find(params[:name], project)
    else
      vendored_templates.all(project)
    end
  end
end

TemplateFinder.prepend_if_ee('::EE::TemplateFinder')
