# frozen_string_literal: true

require 'rspec/core'

module QA
  module Specs
    module Helpers
      module ContextSelector
        extend self

        def configure_rspec
          RSpec.configure do |config|
            config.before do |example|
              if example.metadata.key?(:only)
                skip('Test is not compatible with this environment, pipeline, or job') unless Runtime::Env.context_matches?(example.metadata[:only])
              elsif example.metadata.key?(:exclude)
                skip('Test is excluded in this environment, pipeline, or job') if Runtime::Env.context_matches?(example.metadata[:exclude])
              end
            end
          end
        end
      end
    end
  end
end
