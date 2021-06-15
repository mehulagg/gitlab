# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Validate
          class PostProcess < Chain::Base
            include Chain::Helpers

            def perform!
            end

            def break?
              @pipeline.errors.any?
            end
          end
        end
      end
    end
  end
end

Gitlab::Ci::Pipeline::Chain::Validate::PostProcess.prepend_mod_with('Gitlab::Ci::Pipeline::Chain::Validate::PostProcess')
