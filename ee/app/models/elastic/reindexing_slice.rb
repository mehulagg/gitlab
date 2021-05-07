# frozen_string_literal: true

class Elastic::ReindexingSlice < ApplicationRecord
  self.table_name = 'elastic_reindexing_slices'

  belongs_to :elastic_reindexing_subtask, class_name: 'Elastic::ReindexingSubtask'

  validates :elastic_slice, :elastic_max_slice, :retry_attempt, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :started, -> { where.not(elastic_task: nil).order(elastic_slice: :asc) }
  scope :not_started, -> { where(elastic_task: nil).order(elastic_slice: :asc) }
end
