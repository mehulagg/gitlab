# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Jwt
        extend ::Gitlab::Utils::Override

        private

        override :environment_protected?
        def environment_protected?
          environment.protected?
        end
      end
    end
  end
end
