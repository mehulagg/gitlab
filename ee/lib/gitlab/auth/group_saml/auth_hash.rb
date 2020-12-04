# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class AuthHash < Gitlab::Auth::Saml::AuthHash
        ALLOWED_USER_ATTRIBUTES = %w(can_create_group projects_limit).freeze

        def groups
          Array.wrap(get_raw('groups') || get_raw('Groups'))
        end

        ALLOWED_USER_ATTRIBUTES.each do |attribute|
          define_method(attribute) do
            value = get_raw(attribute)
            return unless value

            Array(value).first
          end
        end
      end
    end
  end
end
