# frozen_string_literal: true

module Ci
  class BuildReportResults < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :build, class_name: "Ci::Build", inverse_of: :build_report_results
    belongs_to :project, class_name: "Project", inverse_of: :build_report_results

    validates :build, :project, presence: true
    validates :data, json_schema: { file_name: "build_report_results_data" }

    scope :for_build_ids, -> (ids) { where(build_id: ids) }

    store_accessor :data, :coverage, :junit

    def name
      junit["name"]
    end

    def duration
      junit["duration"]
    end

    def success
      junit["success"]
    end

    def failed
      junit["failed"]
    end

    def errored
      junit["errored"]
    end

    def skipped
      junit["skipped"]
    end

    def total
      [success, failed, errored, skipped].sum
    end
  end
end
