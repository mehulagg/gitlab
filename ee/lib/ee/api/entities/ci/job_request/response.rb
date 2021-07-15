# frozen_string_literal: true

module EE
  module API
    module Entities
      module Ci
        module JobRequest
          module Response
            extend ActiveSupport::Concern

            prepended do
              expose :secrets_configuration, as: :secrets, if: -> (build, _) { build.ci_secrets_management_available? }
            end
          end
        end
      end
    end
  end
end
