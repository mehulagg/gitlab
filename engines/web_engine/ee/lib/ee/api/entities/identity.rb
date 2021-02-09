# frozen_string_literal: true

module EE
  module API
    module Entities
      module Identity
        extend ActiveSupport::Concern

        prepended do
          expose :saml_provider_id
        end
      end
    end
  end
end
