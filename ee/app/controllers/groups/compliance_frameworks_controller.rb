# frozen_string_literal: true

class Groups::ComplianceFrameworksController < Groups::ApplicationController
  extend ActiveSupport::Concern

  before_action :check_group_compliance_frameworks_available!
  before_action :authorize_admin_group!

  feature_category :compliance_management

  def new
  end

  def edit
  end

  protected

  def check_group_compliance_frameworks_available!
    render_404 unless can?(current_user, :admin_compliance_framework, group)
  end
end
