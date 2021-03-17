# frozen_string_literal: true

module Dast
  class ProfilePipeline < ApplicationRecord
    self.table_name = 'dast_profile_pipelines'

    belongs_to :profile, class_name: 'Dast::Profile', foreign_key: :dast_profile_id
    belongs_to :pipeline, class_name: 'Ci::Pipeline', foreign_key: :ci_pipeline_id

    validates :dast_profile_id, :ci_pipeline_id, presence: true
  end
end
