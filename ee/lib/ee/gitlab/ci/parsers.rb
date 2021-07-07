# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Parsers
        extend ActiveSupport::Concern

        class_methods do
          def parsers
            super.merge({
                license_scanning: ::Gitlab::Ci::Parsers::LicenseCompliance::LicenseScanning,
                dependency_scanning: ::Gitlab::Ci::Parsers::Security::DependencyScanning,
                container_scanning: ::Gitlab::Ci::Parsers::Security::ContainerScanning,
                cluster_image_scanning: ::Gitlab::Ci::Parsers::Security::ContainerScanning,
                dast: ::Gitlab::Ci::Parsers::Security::Dast,
                sast: ::Gitlab::Ci::Parsers::Security::Sast,
                api_fuzzing: ::Gitlab::Ci::Parsers::Security::Dast,
                coverage_fuzzing: ::Gitlab::Ci::Parsers::Security::CoverageFuzzing,
                secret_detection: ::Gitlab::Ci::Parsers::Security::SecretDetection,
                metrics: ::Gitlab::Ci::Parsers::Metrics::Generic,
                requirements: ::Gitlab::Ci::Parsers::RequirementsManagement::Requirement
            })
          end
        end
      end
    end
  end
end
