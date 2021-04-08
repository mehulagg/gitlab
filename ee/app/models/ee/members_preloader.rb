# frozen_string_literal: true

module EE
  module MembersPreloader
    extend ::Gitlab::Utils::Override

    override :preload_all
    def preload_all
      super

      ActiveRecord::Associations::Preloader.new.preload(members, user: :managing_group)
      ActiveRecord::Associations::Preloader.new.preload(members.map(&:user), group_saml_identities: :saml_provider)
    end
  end
end
