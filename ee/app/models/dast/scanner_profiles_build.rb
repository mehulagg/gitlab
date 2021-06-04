# frozen_string_literal: true

module Dast
  class ScannerProfilesBuild < ApplicationRecord
    self.table_name = 'dast_scanner_profiles_builds'

    belongs_to :ci_build, class_name: 'Ci::Build', optional: false, inverse_of: :dast_scanner_profiles_build
    belongs_to :dast_scanner_profile, class_name: 'DastScannerProfile', optional: false, inverse_of: :dast_scanner_profiles_builds

    validates :ci_build_id, :dast_scanner_profile_id, presence: true

    validate :project_ids_match

    private

    def project_ids_match
      return if ci_build.nil? || dast_scanner_profile.nil?

      unless ci_build.project_id == dast_scanner_profile.project_id
        errors.add(:ci_build_id, 'project_id must match dast_scanner_profile.project_id')
      end
    end
  end
end
