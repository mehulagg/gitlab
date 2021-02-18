# frozen_string_literal: true

module EE
  module TemplateFinder
    extend ::Gitlab::Utils::Override

    CUSTOM_TEMPLATES = HashWithIndifferentAccess.new(
      dockerfiles: ::Gitlab::Template::CustomDockerfileTemplate,
      gitignores: ::Gitlab::Template::CustomGitignoreTemplate,
      gitlab_ci_ymls: ::Gitlab::Template::CustomGitlabCiYmlTemplate,
      metrics_dashboard_ymls: ::Gitlab::Template::CustomMetricsDashboardYmlTemplate
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

    override :template_names
    def template_names
      return super if custom_templates.nil? || !custom_templates.enabled?

      # on custom templates we do want to fetch all template names as this will iterate through inherited templates
      # from ancestor group levels
      custom_templates.all_template_names.merge(super)
    end

    # This method is going to be removed once we remove the `inherited_issuable_templates` FF and
    # issues and merge_requests entries will go into CUSTOM_TEMPLATES
    def custom_templates_mapping
      if project&.inherited_issuable_templates_enabled?
        CUSTOM_TEMPLATES.merge(
          issues: ::Gitlab::Template::IssueTemplate,
          merge_requests: ::Gitlab::Template::MergeRequestTemplate
        )
      else
        CUSTOM_TEMPLATES
      end
    end
  end
end
