
# frozen_string_literal: true

class Groups::Analytics::DevopsAdoptionController < Groups::Analytics::ApplicationController
  layout 'group'

  before_action :load_group
  before_action -> { check_feature_availability!(:group_devops_adoption) }
  before_action -> { authorize_view_by_action!(:view_group_devops_adoption) }

  def show
    render_404 unless Feature.enabled?(:group_devops_adoption_flag, @group, default_enabled: :yaml)
  end
end
