# frozen_string_literal: true

module Registrations
  class GroupInvitesController < Groups::ApplicationController
    include GroupInviteMembers

    layout 'checkout'

    before_action :authorize_invite_to_group!

    feature_category :navigation

    def new
    end

    def create
      invite_members(@group)

      experiment(:registration_group_invite, actor: @group)
        .track(:invites_sent, property: @group.id, value: @group.members.invite.size)

      redirect_to new_users_sign_up_project_path(trial: params[:trial], namespace_id: @group.id)
    end

    private

    def authorize_invite_to_group!
      access_denied! unless can?(current_user, :admin_group_member, @group)
    end

    def group_invite_params
      params.require(:group).permit(emails: [])
    end
  end
end
