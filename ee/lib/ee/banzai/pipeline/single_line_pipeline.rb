# frozen_string_literal: true

module EE
  module Banzai
    module Pipeline
      module SingleLinePipeline
        extend ActiveSupport::Concern

        class_methods do
          def reference_filters
            [
              ::Banzai::Filter::EpicReferenceFilter,
              ::Banzai::Filter::IterationReferenceFilter,
              ::Banzai::Filter::VulnerabilityReferenceFilter,
              *super
            ]
          end
        end
      end
    end
  end
end
