# frozen_string_literal: true

class Admin::CredentialsController < Admin::ApplicationController
  extend ::Gitlab::Utils::Override
  include CredentialsInventoryActions
  include Analytics::UniqueVisitsHelper

  helper_method :credentials_inventory_path, :user_detail_path, :personal_access_token_revoke_path, :revoke_button_available?, :ssh_key_delete_path

  before_action :check_license_credentials_inventory_available!, only: [:index, :revoke, :destroy]
  before_action :check_gpg_keys_list_enabled!, only: [:index]

  track_unique_visits :index, target_id: 'i_compliance_credential_inventory'

  feature_category :compliance_management

  private

  def check_license_credentials_inventory_available!
    render_404 unless credentials_inventory_feature_available?
  end

  def check_gpg_keys_list_enabled!
    render_404 if show_gpg_keys? && Feature.disabled?(:credential_inventory_gpg_keys)
  end

  override :credentials_inventory_path
  def credentials_inventory_path(args)
    admin_credentials_path(args)
  end

  override :filter_credentials
  def filter_credentials
    show_gpg_keys? ? ::GpgKeysFinder.new(users: users).execute : super
  end

  override :user_detail_path
  def user_detail_path(user)
    admin_user_path(user)
  end

  override :ssh_key_delete_path
  def ssh_key_delete_path(key)
    admin_credential_path(key)
  end

  override :personal_access_token_revoke_path
  def personal_access_token_revoke_path(token)
    revoke_admin_credential_path(token)
  end

  override :revoke_button_available?
  def revoke_button_available?
    true
  end

  override :users
  def users
    nil
  end

  override :revocable
  def revocable
    nil
  end
end
