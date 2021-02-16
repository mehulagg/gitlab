# frozen_string_literal: true

class Groups::ComplianceFrameworksController < Groups::ApplicationController
  extend ActiveSupport::Concern

  before_action :check_group_compliance_frameworks_available!
  before_action :authorize_admin_group!

  def new
  end

  protected

  def check_group_compliance_frameworks_available!
    render_404 unless License.feature_available?(:custom_compliance_frameworks) && Feature.enabled?(:ff_custom_compliance_frameworks, @group)
  end
end

