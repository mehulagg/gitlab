# frozen_string_literal: true

module Ci
  class BuildReportResults < ApplicationRecord
    extend Gitlab::Ci::Model

    belongs_to :build, class_name: "Ci::Build", inverse_of: :build_report_results
    belongs_to :project, class_name: "Project", inverse_of: :build_report_results

    validates :build, :project, presence: true
    validates :data, json_schema: { file_name: "build_report_results_data" }
  end
end
