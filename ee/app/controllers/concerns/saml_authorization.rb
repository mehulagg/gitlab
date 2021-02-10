# frozen_string_literal: true
module SamlAuthorization
  extend ActiveSupport::Concern

  private

  def authorize_manage_saml!
    render_404 unless can?(current_user, :admin_group_saml, group)
  end

  def check_group_saml_configured
    render_404 unless Gitlab::Auth::GroupSaml::Config.enabled?
  end

  def require_top_level_group
    render_404 if group.subgroup?
  end
end
