# frozen_string_literal: true

module EE
  module LicenseTemplateFinder
    extend ::Gitlab::Utils::Override

    attr_reader :custom_templates
    private :custom_templates

    def initialize(project, *args, &blk)
      super

      @custom_templates =
        ::Gitlab::CustomFileTemplates.new(::Gitlab::Template::CustomLicenseTemplate, project)
    end

    override :execute
    def execute
      return super unless custom_templates?

      if params[:name]
        custom_templates.find(params[:name], params[:source_template_project_id]) || super
      else
        custom_templates.all + super
      end
    end

    override :template_names
    def template_names
      return super unless custom_templates?

      custom_templates.all_template_names.merge(super)
    end

    private

    def custom_templates?
      !popular_only? && custom_templates.enabled?
    end
  end
end
