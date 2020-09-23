# frozen_string_literal: true

class Groups::Security::CredentialsController < Groups::ApplicationController
  layout 'group'

  extend ::Gitlab::Utils::Override
  include CredentialsInventoryActions
  include Groups::SecurityFeaturesHelper

  helper_method :credentials_inventory_path, :user_detail_path

  before_action :validate_group_level_credentials_inventory_available!, only: [:index]

  private

  def validate_group_level_credentials_inventory_available!
    render_404 unless group_level_credentials_inventory_available?(group)
  end

  override :credentials_inventory_path
  def credentials_inventory_path(args)
    group_security_credentials_path(args)
  end

  override :user_detail_path
  def user_detail_path(user)
    user_path(user)
  end

  override :users
  def users
    group.managed_users
  end
end
