# frozen_string_literal: true

module EE
  module MembersPreloader
    extend ::Gitlab::Utils::Override

    override :preload_all
    def preload_all
      super

      ActiveRecord::Associations::Preloader.new.preload(members.map(&:user), group_saml_identities: :saml_provider)
      ActiveRecord::Associations::Preloader.new.preload(members.map(&:user), oncall_participants: { rotation: :schedule })
    end
  end
end
