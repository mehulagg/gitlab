# frozen_string_literal: true

module EE
  module Member
    extend ActiveSupport::Concern
    extend ::Gitlab::Utils::Override

    prepended do
      after_commit :update_gitlab_subscription, on: [:update, :destroy]
    end

    class_methods do
      extend ::Gitlab::Utils::Override

      override :set_member_attributes
      def set_member_attributes(member, access_level, current_user: nil, expires_at: nil, ldap: false)
        super

        member.attributes = {
          ldap: ldap
        }
      end
    end

    override :notification_service
    def notification_service
      if ldap
        # LDAP users shouldn't receive notifications about membership changes
        ::EE::NullNotificationService.new
      else
        super
      end
    end

    def sso_enforcement
      unless ::Gitlab::Auth::GroupSaml::MembershipEnforcer.new(group).can_add_user?(user)
        errors.add(:user, 'is not linked to a SAML account')
      end
    end

    # The method is exposed in the API as is_using_seat
    # in ee/lib/ee/api/entities.rb
    #
    # rubocop: disable Naming/PredicateName
    def is_using_seat
      return user.using_gitlab_com_seat?(source) if ::Gitlab.com?

      user.using_license_seat?
    end
    # rubocop: enable Naming/PredicateName

    private

    def update_gitlab_subscription
      ::Gitlab::Subscription::MaxSeatsUpdater.update(source)
    end
  end
end
