# frozen_string_literal: true

module Gitlab
  class CustomFileTemplates
    include ::Gitlab::Utils::StrongMemoize

    attr_reader :finder, :project

    def initialize(finder, project)
      @finder = finder
      @project = project
    end

    def enabled?
      instance_enabled? || namespace_enabled?
    end

    def all
      by_namespace = namespace_template_projects_hash.flat_map do |namespace, project|
        templates_for(project, category_for(namespace))
      end

      by_instance =
        if instance_enabled?
          templates_for(instance_template_project, 'Instance')
        else
          []
        end

      by_namespace + by_instance
    end

    def find(name)
      namespace_template_projects_hash.each do |namespace, project|
        found = template_for(project, name, category_for(namespace))
        return found if found
      end

      template_for(instance_template_project, name, 'Instance')
    end

    private

    def instance_enabled?
      instance_template_project.present?
    end

    def namespace_enabled?
      namespace_template_projects_hash.present?
    end

    def instance_template_project
      strong_memoize(:instance_template_project) do
        if ::License.feature_available?(:custom_file_templates)
          ::Gitlab::CurrentSettings.file_template_project
        end
      end
    end

    def category_for(namespace)
      "Group #{namespace.full_name}"
    end

    # Template projects referenced by each group are included here. They are
    # ordered from most-specific to least-specific
    def namespace_template_projects_hash
      strong_memoize(:namespace_template_projects_hash) do
        next [] unless project.present?

        project
          .ancestors_upto(nil)
          .with_custom_file_templates
          .select { |namespace| namespace.checked_file_template_project }
          .map { |namespace| [namespace, namespace.checked_file_template_project] }
          .to_h
      end
    end

    def templates_for(project, category)
      return [] unless project

      finder.all(project).map { |template| translate(template, category: category) }
    end

    def template_for(project, name, category)
      return unless project

      translate(finder.find(name, project), category: category)
    rescue ::Gitlab::Template::Finders::RepoTemplateFinder::FileNotFoundError
      nil
    end

    def translate(template, category:)
      return unless template

      template.category = category

      # License templates require special handling as the "vendored" licenses
      # are actually in a gem, not on disk like the rest of the templates. So,
      # all license templates use a shim that presents a unified interface.
      return template unless license_templates?

      LicenseTemplate.new(
        key: template.key,
        name: template.name,
        nickname: template.name,
        category: template.category,
        content: -> { template.content }
      )
    end

    def license_templates?
      finder == ::Gitlab::Template::CustomLicenseTemplate
    end
  end
end
