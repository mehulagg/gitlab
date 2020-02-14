# frozen_string_literal: true

module EE
  module Banzai
    module Pipeline
      module GfmPipeline
        extend ActiveSupport::Concern

        class_methods do
          def reference_filters
            [
              ::Banzai::Filter::EpicReferenceFilter,
              ::Banzai::Filter::DesignReferenceFilter,
              *super
            ]
          end

          def metric_filters
            [
              ::Banzai::Filter::InlineClusterMetricsFilter,
              *super
            ]
          end
        end
      end
    end
  end
end
