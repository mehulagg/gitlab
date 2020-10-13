# frozen_string_literal: true

module EE::Gitlab::Analytics::CycleAnalytics::BaseQueryBuilder
  extend ::Gitlab::Utils::Override

  override :build
  def build
    filter_by_project_ids(super)
  end

  private

  override :build_finder_params
  def build_finder_params(params)
    super.tap do |finder_params|
      finder_params.merge!(params.slice(*::Gitlab::Analytics::CycleAnalytics::RequestParams::FINDER_PARAM_NAMES))

      finder_params[:project_ids] = Array(params[:project_ids])
    end
  end

  override :add_parent_model_params!
  def add_parent_model_params!(finder_params)
    return super unless parent_class.eql?(Group)

    finder_params.merge!(group_id: stage.parent_id, include_subgroups: true)
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def filter_by_project_ids(query)
    return query if params[:project_ids].empty?

    query.where(project_id: params[:project_ids])
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
