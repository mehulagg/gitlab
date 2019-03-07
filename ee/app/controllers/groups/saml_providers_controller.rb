# frozen_string_literal: true

class Groups::SamlProvidersController < Groups::ApplicationController
  before_action :require_top_level_group
  before_action :authorize_manage_saml!
  before_action :check_group_saml_available!
  before_action :check_group_saml_configured

  def show
    @saml_provider = @group.saml_provider || @group.build_saml_provider
  end

  def create
    @saml_provider = @group.build_saml_provider(saml_provider_params)

    @saml_provider.save

    render :show
  end

  def update
    @saml_provider = @group.saml_provider

    GroupSaml::SamlProvider::UpdateService.new(current_user, @saml_provider, params: saml_provider_params).execute

    render :show
  end

  private

  def authorize_manage_saml!
    render_404 unless can?(current_user, :admin_group_saml, @group)
  end

  def check_group_saml_configured
    render_404 unless Gitlab::Auth::GroupSaml::Config.enabled?
  end

  def require_top_level_group
    render_404 if @group.subgroup?
  end

  def saml_provider_params
    allowed_params = %i[sso_url certificate_fingerprint enabled]

    allowed_params += [:enforced_sso] if Feature.enabled?(:enforced_sso, group)
    allowed_params += [:enforced_group_managed_accounts] if Feature.enabled?(:group_managed_accounts, group)

    params.require(:saml_provider).permit(allowed_params)
  end
end
