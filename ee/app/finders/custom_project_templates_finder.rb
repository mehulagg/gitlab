# frozen_string_literal: true

# To avoid leaking protected project features in templates, users will only have
# access to use project as templates if they have access to all the enabled
# project features
class CustomProjectTemplatesFinder < ::ProjectsFinder
  def initialize(current_user:, search: nil, subgroup_id: nil, project_id: nil)
    @current_user = current_user
    @search = search
    @subgroup_id = subgroup_id
    @project_id = project_id
  end

  def execute
    scope = super

    ::ProjectFeature::EXPORTABLE_FEATURES.reduce(scope) do |scope, feature|
      scope.with_feature_access_level(feature, ::ProjectFeature::DISABLED)
        .or(scope.with_feature_available_for_user(feature, current_user))
    end
  end

  # Override the `::ProjectsFinder#params` to leverage of the scope build there.
  def params
    @params ||=
      if project_id
        {}
      else
        { search: search, sort: 'name_asc' }
      end
  end

  # Override the `::ProjectsFinder#project_ids_relation` to leverage of the scope build there.
  def project_ids_relation
    @project_ids_relation ||=
      if project_id
        templates.id_in(project_id)
      else
        templates
      end
  end

  private

  attr_reader :search, :subgroup_id, :project_id

  def templates
    @templates ||= ::Gitlab::CurrentSettings
      .available_custom_project_templates(subgroup_id)
  end
end
