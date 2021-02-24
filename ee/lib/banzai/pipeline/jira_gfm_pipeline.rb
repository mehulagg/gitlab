# frozen_string_literal: true

module Banzai
  module Pipeline
    class JiraGfmPipeline < ::Banzai::Pipeline::GfmPipeline
      def self.filters
        [
          Banzai::Filter::JiraPrivateImageLinkFilter,
          *super
        ]
      end
    end
  end
end
