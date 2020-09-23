# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Config
        module Entry
          module Job
            extend ActiveSupport::Concern
            extend ::Gitlab::Utils::Override

            prepended do
              attributes :secrets

              entry :secrets, ::Gitlab::Ci::Config::Entry::Secrets,
                description: 'Configured secrets for this job',
                inherit: false
            end

            override :value
            def value
              super.merge({ secrets: secrets_value }.compact)
            end
          end
        end
      end
    end
  end
end
