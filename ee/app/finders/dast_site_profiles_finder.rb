# frozen_string_literal: true

class DastSiteProfilesFinder
  def initialize(params = {})
    @params = params
  end

  def execute
    relation = DastSiteProfile.with_dast_site_and_validation
    relation = by_id(relation)
    relation = by_project(relation)
    by_name(relation)
  end

  private

  attr_reader :params

  # rubocop: disable CodeReuse/ActiveRecord
  def by_id(relation)
    return relation if params[:id].nil?

    relation.where(id: params[:id]).limit(1)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def by_project(relation)
    return relation if params[:project_id].nil?

    relation.where(project_id: params[:project_id])
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def by_name(relation)
    return relation unless params[:name]

    relation.with_name(params[:name])
  end
end
