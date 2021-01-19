# frozen_string_literal: true

module Security
  module Fuzzing
    class ScanProfile
      PROFILE_DEFINITIONS = 'https://gitlab.com/gitlab-org/security-products/analyzers/api-fuzzing/-/raw/master/gitlab-api-fuzzing-config.yml'

      def self.all
        raw = Gitlab::HTTP.get(PROFILE_DEFINITIONS)
        yaml = YAML.safe_load(raw, [Symbol], [], true)

        yaml['Profiles'].map do |profile|
          profile['Name']
        end
      end
    end
  end
end
