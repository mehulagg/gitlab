# frozen_string_literal: true

module API
  class GroupAvatar < ::API::Base
    helpers Helpers::GroupsHelpers

    feature_category :subgroups

    resource :groups do
      desc 'Return avatar url for a user' do
        success Entities::Avatar
      end
      params do
        optional :size, type: Integer, desc: 'Single pixel dimension for Avatar images'
      end
      get ':id/avatar' do
        group = find_group!(params[:id])

        forbidden!('Unauthorized access') unless can?(current_user, :read_group, group)

        if group.avatar.file
          present_carrierwave_file!(group.avatar)
        else
          render_api_error!(s_('GroupApi|Group does not have avatar'), 404)
        end
      end
    end
  end
end
