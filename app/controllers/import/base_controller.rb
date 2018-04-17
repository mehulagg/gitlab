class Import::BaseController < ApplicationController
  private

  def find_jobs(import_type)
    current_user.created_projects
        .joins_import_state
        .where(import_type: import_type)
        .to_json(only: [:id], include: { import_state: { only: [:status] } })
  end

  def find_or_create_namespace(names, owner)
    names = params[:target_namespace].presence || names

    return current_user.namespace if names == owner

    group = Groups::NestedCreateService.new(current_user, group_path: names).execute

    group.errors.any? ? current_user.namespace : group
  rescue => e
    Gitlab::AppLogger.error(e)

    current_user.namespace
  end
end
