# frozen_string_literal: true

module Gitlab
  module Ci
    module Reports
      module LicenseScanning
        class Dependency
          attr_accessor :path
          attr_reader :name, :package_manager, :version

          def initialize(attributes = {})
            @name = attributes.fetch(:name)
            @package_manager = attributes[:package_manager]
            @path = attributes[:path]
            @version = attributes[:version]
          end

          def blob_path_for(project, sha: project&.default_branch)
            return if path.blank?
            return path if sha.blank?

            ::Gitlab::Routing
              .url_helpers
              .project_blob_path(project, File.join(sha, path))
          end

          def hash
            name.hash
          end

          def eql?(other)
            self.name == other.name
          end
        end
      end
    end
  end
end
