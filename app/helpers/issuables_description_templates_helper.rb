# frozen_string_literal: true

module IssuablesDescriptionTemplatesHelper
  include Gitlab::Utils::StrongMemoize
  include GitlabRoutingHelper

  def template_dropdown_tag(issuable, &block)
    title = selected_template(issuable) || "Choose a template"
    options = {
      toggle_class: 'js-issuable-selector',
      title: title,
      filter: true,
      placeholder: 'Filter',
      footer_content: true,
      data: {
        data: issuable_templates(ref_project, issuable.to_ability_name),
        field_name: 'issuable_template',
        selected: selected_template(issuable),
        project_id: ref_project.id,
        project_path: ref_project.path,
        namespace_path: ref_project.namespace.full_path
      }
    }

    dropdown_tag(title, options: options) do
      capture(&block)
    end
  end

  # repository.issue_template_names and repository.merge_request_template_names are cached in redis already and
  # memoized in though repository model
  def issuable_templates(project, issuable_type)
    project.issuable_template_names(issuable_type)
  end

  def issuable_templates_names(issuable)
    all_templates = issuable_templates(ref_project, issuable.to_ability_name)

    if(ref_project.inherited_issuable_templates_enabled?)
      all_templates.values.flatten.map { |tpl| tpl[:name] if tpl[:project_id] == ref_project.id }.compact.uniq
    else
      all_templates.map { |template| template[:name] }
    end
  end

  def selected_template(issuable)
    all_templates = issuable_templates(ref_project, issuable.to_ability_name)

    if(ref_project.inherited_issuable_templates_enabled?)
      params[:issuable_template] if all_templates.values.flatten.any? { |template| template[:name] == params[:issuable_template] }
    else
      params[:issuable_template] if all_templates.any? { |template| template[:name] == params[:issuable_template] }
    end

  end

  def template_names_path(parent, issuable)
    return '' unless parent.is_a?(Project)

    project_template_names_path(parent, template_type: issuable.to_ability_name)
  end
end
