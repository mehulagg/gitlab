# frozen_string_literal: true

class Elastic::ReindexingSubtask < ApplicationRecord
  self.table_name = 'elastic_reindexing_subtasks'

  belongs_to :elastic_reindexing_task
end
