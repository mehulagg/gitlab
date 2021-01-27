# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Config
            module Content
              extend ::Gitlab::Utils::Override

              SOURCES = [::Gitlab::Ci::Pipeline::Chain::Config::Content::CompliancePipelineConfiguration].freeze

              private

              override :sources
              def sources
                SOURCES + super
              end
            end
          end
        end
      end
    end
  end
end
