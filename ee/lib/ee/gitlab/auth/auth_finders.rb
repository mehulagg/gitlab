# frozen_string_literal: true

module EE
  module Gitlab
    module Auth
      module AuthFinders
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :find_oauth_access_token
        def find_oauth_access_token
          return if scim_request?

          super
        end

        def scim_request?
          current_request.path.starts_with?("/api/scim/")
        end
      end
    end
  end
end
