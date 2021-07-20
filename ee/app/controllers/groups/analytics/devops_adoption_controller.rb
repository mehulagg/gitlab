# frozen_string_literal: true

class Groups::Analytics::DevopsAdoptionController < Groups::Analytics::ApplicationController
  include RedisTracking

  layout 'group'

  before_action :load_group
  before_action -> { authorize_view_by_action!(:view_group_devops_adoption) }

  track_redis_hll_event :show, name: 'users_viewing_analytics_group_devops_adoption'

  def show
  end
end
