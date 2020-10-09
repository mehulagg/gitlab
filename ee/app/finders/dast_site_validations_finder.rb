# frozen_string_literal: true

class DastSiteValidationsFinder
  def initialize(params = {})
    @params = params
  end

  def execute
    relation = DastSiteValidation.all
    relation = by_project(relation)
    relation = by_url_base(relation)
    relation
  end

  private

  attr_reader :params

  def by_project(relation)
    return relation if params[:project_id].nil?

    relation.by_project_id(params[:project_id])
  end

  def by_url_base(relation)
    return relation if params[:url_base].nil?

    relation.most_recent_by_url_base(params[:url_base])
  end
end
