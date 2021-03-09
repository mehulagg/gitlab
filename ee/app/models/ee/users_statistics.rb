# frozen_string_literal: true

module EE
  module UsersStatistics
    def billable
      (base_billable_users + guest_billable_users).sum
    end

    private

    def base_billable_users
      [
        with_highest_role_reporter,
        with_highest_role_developer,
        with_highest_role_maintainer,
        with_highest_role_owner
      ]
    end

    def guest_billable_users
      if License.current&.exclude_guests_from_active_count?
        []
      else
        [without_groups_and_projects, with_highest_role_guest]
      end
    end
  end
end
