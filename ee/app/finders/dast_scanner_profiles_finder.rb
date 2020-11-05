# frozen_string_literal: true

class DastScannerProfilesFinder
  def initialize(params = {})
    @params = params
  end

  def execute
    relation = DastScannerProfile.all
    relation = by_id(relation)
    relation = by_project(relation)
    relation
  end

  private

  attr_reader :params

  def by_id(relation)
    return relation unless params[:ids]

    relation.id_in(params[:ids])
  end

  def by_project(relation)
    return relation unless params[:project_ids]

    relation.project_id_in(params[:project_ids])
  end
end
