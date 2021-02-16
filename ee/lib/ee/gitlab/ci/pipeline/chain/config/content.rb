# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Config
            module Content
              extend ::Gitlab::Utils::Override

              EE_SOURCES = [::Gitlab::Ci::Pipeline::Chain::Config::Content::Compliance].freeze

              private

              override :sources
              def sources
                EE_SOURCES + super
              end
            end
          end
        end
      end
    end
  end
end
