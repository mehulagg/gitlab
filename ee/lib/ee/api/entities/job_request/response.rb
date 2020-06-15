# frozen_string_literal: true

module EE
  module API
    module Entities
      module JobRequest
        module Response
          extend ActiveSupport::Concern

          prepended do
            expose :secrets, if: -> (build, _) { build.ci_secrets_management_available? && build.secrets? }
          end
        end
      end
    end
  end
end
