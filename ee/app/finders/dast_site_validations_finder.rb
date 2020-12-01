# frozen_string_literal: true

class DastSiteValidationsFinder
  DEFAULT_SORT_VALUE = 'id'.freeze
  DEFAULT_SORT_DIRECTION = 'desc'.freeze

  def initialize(params = {})
    @params = params
  end

  def execute
    relation = DastSiteValidation.all
    relation = by_project(relation)
    relation = by_url_base(relation)
    relation = by_state(relation)

    sort(relation)
  end

  private

  attr_reader :params

  def by_project(relation)
    return relation if params[:project_id].nil?

    relation.by_project_id(params[:project_id])
  end

  def by_url_base(relation)
    return relation if params[:url_base].nil?

    relation.by_url_base(params[:url_base])
  end

  def by_state(relation)
    return relation if params[:state].nil?

    relation.with_state(params[:state])
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def sort(relation)
    relation.order(DEFAULT_SORT_VALUE => DEFAULT_SORT_DIRECTION)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
