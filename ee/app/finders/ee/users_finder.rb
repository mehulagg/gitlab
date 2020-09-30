# frozen_string_literal: true

module EE
  module UsersFinder
    extend ::Gitlab::Utils::Override

    override :execute
    def execute
      users = by_non_ldap(super)

      by_using_license_seat(users)
    end

    def by_non_ldap(users)
      return users unless params[:skip_ldap]

      users.non_ldap
    end

    def by_using_license_seat(users)
      return users unless current_user&.admin? && params[:using_license_seat]

      users.using_license_seat
    end
  end
end
