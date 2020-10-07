# frozen_string_literal: true

class DastSiteValidationsFinder
  def initialize(params = {})
    @params = params
  end

  def execute
    relation = DastSiteValidation.all
    relation = by_url(relation)
    relation = by_project(relation)
    relation
  end

  private

  attr_reader :params

  def by_url(relation)
    return relation unless params[:urls]

    relation.url_in(params[:urls])
  end

  def by_project(relation)
    return relation unless params[:project_ids]

    relation.by_project_id(params[:project_ids])
  end
end
