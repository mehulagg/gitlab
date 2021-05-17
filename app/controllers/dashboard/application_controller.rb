# frozen_string_literal: true

class Dashboard::ApplicationController < ApplicationController
  include ControllerWithCrossProjectAccessCheck
  include RecordUserLastActivity

  layout 'dashboard'

  requires_cross_project_access

  around_action :use_first_shard

  private

  def use_first_shard
    NamespaceShard.use_first_shard { yield }
  end

  def projects
    @projects ||= current_user.authorized_projects.sorted_by_activity.non_archived
  end
end
