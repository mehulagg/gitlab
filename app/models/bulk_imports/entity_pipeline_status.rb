# frozen_string_literal: true

module BulkImports
  class EntityPipelineStatus < ApplicationRecord
    self.table_name = 'bulk_import_entity_pipeline_statuses'

    belongs_to :entity,
      foreign_key: :bulk_import_entity_id,
      class_name: 'BulkImports::Entity',
      optional: false

    validates :stage_name, presence: true
    validates :pipeline_name, presence: true

    state_machine :status, initial: :created do
      state :created, value: 0
      state :started, value: 1
      state :finished, value: 2
      state :failed, value: -1

      event :start do
        transition created: :started
      end

      event :finish do
        transition started: :finished
        transition failed: :failed
      end

      event :fail_op do
        transition any => :failed
      end
    end
  end
end
