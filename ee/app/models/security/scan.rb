# frozen_string_literal: true

module Security
  class Scan < ApplicationRecord
    include IgnorableColumns

    self.table_name = 'security_scans'

    ignore_column :scanned_resources_count, remove_with: '13.7', remove_after: '2020-12-22'

    validates :build_id, presence: true
    validates :scan_type, presence: true

    belongs_to :build, class_name: 'Ci::Build'

    has_one :pipeline, class_name: 'Ci::Pipeline', through: :build

    has_many :findings, inverse_of: :scan

    enum scan_type: {
      sast: 1,
      dependency_scanning: 2,
      container_scanning: 3,
      dast: 4,
      secret_detection: 5,
      coverage_fuzzing: 6,
      api_fuzzing: 7
    }

    delegate :project, to: :build
  end
end
