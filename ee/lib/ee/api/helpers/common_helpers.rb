# frozen_string_literal: true

module EE
  module API
    module Helpers
      module CommonHelpers
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :convert_parameters_from_legacy_format
        def convert_parameters_from_legacy_format(params)
          params.tap do |params|
            # this can be removed with API v5, see
            # https://gitlab.com/gitlab-org/gitlab/issues/35089
            iid = params.delete(:epic_iid)

            if iid.present?
              group_id = user_project&.group&.id

              raise_epic_not_found! unless group_id

              epic = EpicsFinder.new(current_user, group_id: group_id).find_by(iid: iid) # rubocop: disable CodeReuse/ActiveRecord

              raise_epic_not_found! unless epic

              params[:epic_id] = epic.id
            end
          end

          super
        end

        def raise_epic_not_found!
          not_found!('Epic')
        end
      end
    end
  end
end
