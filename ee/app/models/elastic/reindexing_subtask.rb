# frozen_string_literal: true

class Elastic::ReindexingSubtask < ApplicationRecord
  self.table_name = 'elastic_reindexing_subtasks'

  belongs_to :elastic_reindexing_task, class_name: 'Elastic::ReindexingTask'

  validates :index_name_from, :index_name_to, :elastic_task, presence: true
  validates :elastic_slice, :elastic_max_slice, :retry_attempt, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
