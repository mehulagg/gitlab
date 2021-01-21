# frozen_string_literal: true

module Security
  module CiConfiguration
    class ApiFuzzing < ApplicationRecord
      SCAN_MODES = {
        har: 1,
        openapi: 2
      }.freeze

      self.table_name = 'api_fuzzing_ci_configurations'

      belongs_to :project, optional: false

      enum scan_mode: SCAN_MODES

      validates :api_definition, presence: true
      validates :scan_mode, presence: true
      validates :target, presence: true
    end
  end
end
