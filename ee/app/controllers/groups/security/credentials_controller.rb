# frozen_string_literal: true

class Groups::Security::CredentialsController < Groups::ApplicationController
  layout 'group'

  extend ::Gitlab::Utils::Override
  include CredentialsInventoryActions
  include Groups::SecurityFeaturesHelper

  helper_method :credentials_inventory_path, :user_detail_path, :ssh_key_delete_path

  before_action :validate_group_level_credentials_inventory_available!, only: [:index, :destroy]

  feature_category :compliance_management

  private

  def validate_group_level_credentials_inventory_available!
    render_404 unless group_level_credentials_inventory_available?(group)
  end

  override :credentials_inventory_path
  def credentials_inventory_path(args)
    group_security_credentials_path(args)
  end

  override :ssh_key_delete_path
  def ssh_key_delete_path(key)
    group_security_credential_path(@group, key)
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
