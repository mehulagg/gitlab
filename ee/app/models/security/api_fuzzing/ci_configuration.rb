# frozen_string_literal: true

module Security
  module ApiFuzzing
    class CiConfiguration
      SCAN_MODES = [:har, :openapi].freeze

      def self.scan_profiles
        location = 'https://gitlab.com/gitlab-org/security-products/analyzers/api-fuzzing/-/raw/master/gitlab-api-fuzzing-config.yml'
        response = Gitlab::HTTP.get(location)
        content = Gitlab::Config::Loader::Yaml.new(response.to_s).load!

        content[:Profiles].map do |profile|
          ScanProfile.new(
            name: profile[:Name],
            description: 'um',
            yaml: ''
          )
        end
      end
    end
  end
end
