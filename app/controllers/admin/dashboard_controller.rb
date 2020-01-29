# frozen_string_literal: true

class Admin::DashboardController < Admin::ApplicationController
  include CountHelper
  helper_method :show_license_breakdown?

  COUNTED_ITEMS = [Project, User, Group].freeze

  # rubocop: disable CodeReuse/ActiveRecord
  def index
    @counts = Gitlab::Database::Count.approximate_counts(COUNTED_ITEMS)
    @projects = Project.order_id_desc.without_deleted.with_route.limit(10)
    @users = User.order_id_desc.limit(10)
    @groups = Group.order_id_desc.with_route.limit(10)
    @notices = [
    { 
      type: 'info',
      message: 'You are running Puma. This is experimental. Please go to puma upgrade document[https://docs.gitlab.com/ee/administration/operations/puma.html] to read more.'
    },
    { 
      type: 'info',
      message: 'You are running Puma with threads=2, please read puma upgrade document[https://docs.gitlab.com/ee/administration/operations/puma.html] of deprecations of running Puma.'
    },
    { 
      type: 'warning',
      message: 'We detected puma thread>1 and rugged service is enabled. This may decrease performance for some occasions. For details refer to puma upgrade document[https://docs.gitlab.com/ee/administration/operations/puma.html#performance-caveat-when-using-puma-with-rugged]'
    }
  ]
  end
  # rubocop: enable CodeReuse/ActiveRecord

  def show_license_breakdown?
    false
  end
end

Admin::DashboardController.prepend_if_ee('EE::Admin::DashboardController')
