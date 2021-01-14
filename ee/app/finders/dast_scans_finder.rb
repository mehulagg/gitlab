# frozen_string_literal: true

class DastScansFinder
  DEFAULT_SORT_VALUE = 'id'.freeze
  DEFAULT_SORT_DIRECTION = 'desc'.freeze

  def initialize(params = {})
    @params = params
  end

  def execute
    relation = DastScan.includes(:dast_site_profile, :dast_scanner_profile) # rubocop: disable CodeReuse/ActiveRecord
    relation = by_project(relation)

    sort(relation)
  end

  private

  attr_reader :params

  # rubocop: disable CodeReuse/ActiveRecord
  def by_project(relation)
    return relation if params[:project_id].nil?

    relation.where(project_id: params[:project_id])
  end
  # rubocop: enable CodeReuse/ActiveRecord

  # rubocop: disable CodeReuse/ActiveRecord
  def sort(relation)
    relation.order(DEFAULT_SORT_VALUE => DEFAULT_SORT_DIRECTION)
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
