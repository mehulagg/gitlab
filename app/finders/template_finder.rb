# frozen_string_literal: true

class TemplateFinder
  include Gitlab::Utils::StrongMemoize

  VENDORED_TEMPLATES = HashWithIndifferentAccess.new(
    dockerfiles: ::Gitlab::Template::DockerfileTemplate,
    gitignores: ::Gitlab::Template::GitignoreTemplate,
    gitlab_ci_ymls: ::Gitlab::Template::GitlabCiYmlTemplate,
    gitlab_ci_syntax_ymls: ::Gitlab::Template::GitlabCiSyntaxYmlTemplate,
    metrics_dashboard_ymls: ::Gitlab::Template::MetricsDashboardTemplate,
    issues: ::Gitlab::Template::IssueTemplate,
    merge_requests: ::Gitlab::Template::MergeRequestTemplate
  ).freeze

  class << self
    def build(type, project, params = {})
      if type.to_s == 'licenses'
        LicenseTemplateFinder.new(project, params) # rubocop: disable CodeReuse/Finder
      else
        new(type, project, params)
      end
    end

    # This method is going to be replaced by _template_names once we introduce issue and merge request templates at group level
    # https://gitlab.com/gitlab-org/gitlab/-/merge_requests/51692
    #
    # For issue and merge request description templates we return an array of templates for now,
    # instead of a hash of templates grouped by category
    def template_names(project, type)
      return _template_names(project, type) unless %w[issues merge_requests].include?(type.to_s)

      _template_names(project, type).values.flatten
    end

    private

    def _template_names(project, type)
      return {} if !VENDORED_TEMPLATES.key?(type.to_s) && type.to_s != 'licenses'

      template_names_by_category(build(type, project).execute)
    end

    def template_names_by_category(items)
      grouped = items.group_by(&:category)
      categories = grouped.keys

      categories.each_with_object({}) do |category, hash|
        hash[category] = grouped[category].map do |item|
          { name: item.name, id: item.key, project_id: item.try(:project_id) }
        end
      end
    end
  end

  attr_reader :type, :project, :params

  attr_reader :vendored_templates
  private :vendored_templates

  def initialize(type, project, params = {})
    @type = type
    @project = project
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
