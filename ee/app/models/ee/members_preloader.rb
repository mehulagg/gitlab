# frozen_string_literal: true

module EE
  module MembersPreloader
    extend ::Gitlab::Utils::Override

    override :preload_all
    def preload_all
      super

      users = members.map(&:user)
      ActiveRecord::Associations::Preloader.new.preload(users, group_saml_identities: :saml_provider)
      ActiveRecord::Associations::Preloader.new.preload(users, oncall_participants: { rotation: :schedule })
    end
  end
end
