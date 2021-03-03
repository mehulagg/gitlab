# frozen_string_literal: true

class Elastic::ReindexingSlice < ApplicationRecord
  self.table_name = 'elastic_reindexing_slices'

  belongs_to :elastic_reindexing_subtask, class_name: 'Elastic::ReindexingSubtask'

  validates :elastic_task, presence: true
end
