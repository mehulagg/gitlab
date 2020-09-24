# frozen_string_literal: true

module GroupSaml
  module SamlProvider
    class CreateService
      include BaseService

      def initialize(current_user, group, params:)
        @group = group
        super(current_user, group.build_saml_provider, params: params)
      end
    end
  end
end
