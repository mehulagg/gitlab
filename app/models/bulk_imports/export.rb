# frozen_string_literal: true

class BulkImports::Export < ApplicationRecord
  self.table_name = 'bulk_import_exports'

  belongs_to :project
  belongs_to :group

  validates :group, presence: true, unless: :project
  validates :project, presence: true, unless: :group

  validates :jid, :status, presence: true

  state_machine :status, initial: :created do
    state :created, value: 0
    state :started, value: 1
    state :finished, value: 2
    state :failed, value: -1

    event :start do
      transition created: :started
      transition finished: :started
      transition failed: :started
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
