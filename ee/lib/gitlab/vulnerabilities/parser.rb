# frozen_string_literal: true

module Gitlab
  module Vulnerabilities
    InvalidCategoryError = Class.new(StandardError)

    module Parser
      class << self
        def fabricate(params)
          raise ::Gitlab::Vulnerabilities::InvalidCategoryError unless valid_categories.key?(params[:category])

          category = params[:category]

          if standard_vulnerability? category
            Gitlab::Vulnerabilities::StandardVulnerability.new(params)
          else
            Gitlab::Vulnerabilities::ContainerScanningVulnerability.new(params)
          end
        end

        private

        def valid_categories
          ::Vulnerabilities::Feedback.categories
        end

        def standard_vulnerability?(category)
          (valid_categories.keys - %w[container_scanning cluster_image_scanning]).include?(category)
        end
      end
    end
  end
end
