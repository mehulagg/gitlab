# frozen_string_literal: true

module EE
  module Banzai
    module Pipeline
      module SingleLinePipeline
        extend ActiveSupport::Concern

        class_methods do
          def reference_filters
            [
              ::Banzai::Filter::References::EpicReferenceFilter,
              ::Banzai::Filter::References::IterationReferenceFilter,
              ::Banzai::Filter::References::VulnerabilityReferenceFilter,
              *super
            ]
          end
        end
      end
    end
  end
end
