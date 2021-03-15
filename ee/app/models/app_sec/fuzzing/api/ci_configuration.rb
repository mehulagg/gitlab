# frozen_string_literal: true

module AppSec
  module Fuzzing
    module Api
      class CiConfiguration
        PROFILES_DEFINITION_FILE = 'https://gitlab.com/gitlab-org/security-products/analyzers' \
          '/api-fuzzing/-/raw/master/gitlab-api-fuzzing-config.yml'
        SCAN_MODES = [:har, :openapi, :postman].freeze

        def initialize(project:)
          @project = project
        end

        def scan_profiles
          fetch_scan_profiles.map do |profile|
            next unless ScanProfile::NAMES.include?(profile[:Name])

            ScanProfile.new(
              name: profile[:Name],
              project: project,
              yaml: profile.deep_stringify_keys.to_yaml
            )
          end.compact
        end

        private

        attr_reader :project

        def fetch_scan_profiles
          response = Gitlab::HTTP.try_get(PROFILES_DEFINITION_FILE)

          if response&.success?
            content = Gitlab::Config::Loader::Yaml.new(response.to_s).load!

            content.fetch(:Profiles, [])
          else
            []
          end
        end
      end
    end
  end
end
