# frozen_string_literal: true

class MergeRequest::MetricsFinder
  include Gitlab::Allowable

  def initialize(current_user, params = {})
    @current_user = current_user
    @params = params
  end

  def execute
    items = init_collection
    return items.none if target_project_missing? || user_not_authorized?

    items = by_target_project(items)
    items = by_merged_after(items)
    items = by_merged_before(items)

    items
  end

  private

  attr_reader :current_user, :params

  def by_target_project(items)
    items.by_target_project(target_project)
  end

  def by_merged_after(items)
    items = items.merged_after(params[:merged_after]) if params[:merged_after]

    items
  end

  def by_merged_before(items)
    items = items.merged_after(params[:merged_before]) if params[:merged_before]

    items
  end

  def target_project_missing?
    params[:target_project].blank?
  end

  def user_not_authorized?
    !can?(current_user, :read_merge_request, target_project)
  end

  def init_collection
    klass.all
  end

  def klass
    MergeRequest::Metrics
  end

  def target_project
    params[:target_project]
  end
end
