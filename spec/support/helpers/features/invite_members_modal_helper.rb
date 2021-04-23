# frozen_string_literal: true

module Spec
  module Support
    module Helpers
      module Features
        module InviteMembersModalHelpers
          def add_member(name, role = "Guest", expires_at = nil)
            click_on 'Invite members'

            page.within '#invite-members-modal' do
              fill_in 'Select members or type email addresses', with: name

              wait_for_requests
              click_button name

              click_button 'Guest'
              wait_for_requests
              click_button role

              click_button 'Invite'
            end

            page.refresh
          end
        end
      end
    end
  end
end
