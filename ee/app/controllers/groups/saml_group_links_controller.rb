# frozen_string_literal: true

module Groups
  class SamlGroupLinksController < Groups::ApplicationController
    before_action :group
    before_action :authorize_admin_group!
    before_action :authorize_manage_saml_group_links!

    layout 'group_settings'

    feature_category :authentication_and_authorization

    def index
    end

    def create
      group_link = group.saml_group_links.build(params)

      notice = if group_link.save
                 _('New SAML group link saved.')
               else
                 _("Could not create new SAML group link: %{errors}") % { errors: group_link.errors.full_messages.join(', ') }
               end

      redirect_back_or_default(default: { action: 'index' }, options: { notice: notice })
    end

    def destroy
      group.saml_group_links.find(params[:id]).destroy
      redirect_back_or_default(default: { action: 'index' }, options: { notice: _('SAML group link removed.') })
    end

    private

    def authorize_manage_saml_group_links!
      render_404 unless can?(current_user, :admin_saml_group_links, group)
    end

    def require_saml_enabled
      render_404 unless group.saml_enabled?
    end

    def params
      params.require(:saml_group_link).permit(:access_level, :group_name)
    end
  end
end
