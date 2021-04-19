# frozen_string_literal: true

module EE
  module MembersPreloader
    extend ::Gitlab::Utils::Override

    override :preload_all
    def preload_all
      super

      users = members.map(&:user)
      ActiveRecord::Associations::Preloader.new.preload(users, group_saml_identities: :saml_provider)
      ActiveRecord::Associations::Preloader.new.preload(members, user: { oncall_participants: { rotation: :schedule } })
      # from ee/app/serializers/ee/member_user_entity.rb:13:in `uniq'
      ActiveRecord::Associations::Preloader.new.preload(members, user: :oncall_schedules)
    end
  end
end
