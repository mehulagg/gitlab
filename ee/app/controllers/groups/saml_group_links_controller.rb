# frozen_string_literal: true

module Groups
  class SamlGroupLinksController < Groups::ApplicationController
    before_action :authorize_admin_saml_group_links!

    layout 'group_settings'

    feature_category :authentication_and_authorization

    def create
      group_link = group.saml_group_links.build(saml_group_link_params)

      if group_link.save
        flash[:notice] = s_('GroupSAML|New SAML group link saved.')
      else
        flash[:alert] = alert(group_link.errors.full_messages.join(', '))
      end

      redirect_to group_saml_group_links_path(@group)
    end

    def destroy
      group.saml_group_links.find(params[:id]).destroy

      redirect_to group_saml_group_links_path(@group), status: :found, notice: s_('GroupSAML|SAML group link was successfully removed.')
    end

    private

    def authorize_admin_saml_group_links!
      access_denied! unless can?(current_user, :admin_saml_group_links, group)
    end

    def saml_group_link_params
      params.require(:saml_group_link).permit(:saml_group_name, :access_level)
    end

    def alert(error_message)
      s_('GroupSAML|Could not create SAML group link: %{errors}.') % { errors: error_message }
    end
  end
end
