# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module Security
        module Locations
          class ContainerScanning < Base
            attr_reader :image
            attr_reader :operating_system
            attr_reader :package_name
            attr_reader :package_version

            def initialize(image:, operating_system:, package_name: nil, package_version: nil)
              @image = image
              @operating_system = operating_system
              @package_name = package_name
              @package_version = package_version
            end

            def fingerprint_data
              "#{docker_image_name_without_tag}:#{package_name}"
            end

            private

            def docker_image_name_without_tag
              base_name, version = image.split(':')

              return image if version_semver_like?(version)

              base_name
            end

            def version_semver_like?(version)
              hash_like = /\A[0-9a-f]{32,128}\z/i

              if Gem::Version.correct?(version)
                !hash_like.match?(version)
              else
                false
              end
            end
          end
        end
      end
    end
  end
end
