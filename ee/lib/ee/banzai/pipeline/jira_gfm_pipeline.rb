# frozen_string_literal: true

module EE
  module Banzai
    module Pipeline
      class JiraGfmPipeline < ::Banzai::Pipeline::GfmPipeline
        def self.filters
          [
            Banzai::Filter::JiraImageLinkFilter,
            *super
          ]
        end
      end
    end
  end
end
