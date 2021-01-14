# frozen_string_literal: true

module EE
  module TemplateFinder
    extend ::Gitlab::Utils::Override

    CUSTOM_TEMPLATES = HashWithIndifferentAccess.new(
      dockerfiles: ::Gitlab::Template::CustomDockerfileTemplate,
      gitignores: ::Gitlab::Template::CustomGitignoreTemplate,
      gitlab_ci_ymls: ::Gitlab::Template::CustomGitlabCiYmlTemplate,
      metrics_dashboard_ymls: ::Gitlab::Template::CustomMetricsDashboardYmlTemplate,
    ).freeze

    attr_reader :custom_templates
    private :custom_templates

    def initialize(type, project, *args, &blk)
      super

      if custom_templates_mapping.key?(type)
        finder = custom_templates_mapping.fetch(type)
        @custom_templates = ::Gitlab::CustomFileTemplates.new(finder, project)
      end
    end

    override :execute
    def execute
      return super if custom_templates.nil? || !custom_templates.enabled?

      if params[:name]
        custom_templates.find(params[:name], params[:source_template_project_id]) || super
      else
        custom_templates.all + super
      end
    end

    def custom_templates_mapping
      issuable_templates = {}
      if project.inherited_issuable_templates_enabled?
        issuable_templates = {
          issues: ::Gitlab::Template::IssueTemplate,
          merge_requests: ::Gitlab::Template::MergeRequestTemplate
        }
      end

      issuable_templates.merge(CUSTOM_TEMPLATES)
    end
  end
end
