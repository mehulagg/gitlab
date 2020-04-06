# frozen_string_literal: true

class JiraImportState < ApplicationRecord
  include AfterCommitQueue
  include ImportState::SidekiqJobTracker

  self.table_name = 'jira_imports'

  STATUSES = { initial: 0, scheduled: 1, started: 2, failed: 3, finished: 4 }.freeze

  belongs_to :project
  belongs_to :user
  belongs_to :label

  validates :project, presence: true
  validates :jira_project_key, presence: true
  validates :jira_project_name, presence: true
  validates :jira_project_xid, presence: true

  validates :project, uniqueness: {
    conditions: -> { where.not(status: STATUSES.values_at(:failed, :finished)) },
    message: _('Cannot have multiple Jira imports running at the same time')
  }

  state_machine :status, initial: :initial do
    event :schedule do
      transition initial: :scheduled
    end

    event :start do
      transition scheduled: :started
    end

    event :finish do
      transition started: :finished
    end

    event :do_fail do
      transition [:initial, :scheduled, :started] => :failed
    end

    after_transition initial: :scheduled do |state, _|
      state.run_after_commit do
        job_id = Gitlab::JiraImport::Stage::StartImportWorker.perform_async(project.id)
        state.update(jid: job_id) if job_id
      end
    end

    after_transition any => :finished do |state, _|
      if state.jid.present?
        Gitlab::SidekiqStatus.unset(state.jid)

        state.update_column(:jid, nil)
      end
    end

    # Supress warning:
    # both JiraImportState and its :status machine have defined a different default for "status".
    # although both have same value but represented in 2 ways: integer(0) and symbol(:initial)
    def owner_class_attribute_default
      'initial'
    end
  end

  enum status: STATUSES

  def in_progress?
    scheduled? || started?
  end
end
