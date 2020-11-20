# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class AuthHash < Gitlab::Auth::Saml::AuthHash
        def groups
          Array.wrap(get_raw('groups') || get_raw('Groups'))
        end
      end
    end
  end
end
