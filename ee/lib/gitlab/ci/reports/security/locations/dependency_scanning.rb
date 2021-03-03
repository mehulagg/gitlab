# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Locations
          class DependencyScanning < Base
            include Security::Concerns::FingerprintPathFromFile

            attr_reader :file_path
            attr_reader :package_name
            attr_reader :package_version

            def initialize(file_path:, package_name:, package_version: nil)
              @file_path = file_path
              @package_name = package_name
              @package_version = package_version
            end

            def fingerprint_data
              "#{file_path}:#{package_name}"
            end
          end
        end
      end
    end
  end
end
