# frozen_string_literal: true

module RepositoryStorageMoveable
  extend ActiveSupport::Concern

  included do
    include AfterCommitQueue

    validate :container_repository_writeable, on: :create
    validates :state, presence: true
    validates :source_storage_name,
    on: :create,
    presence: true,
    inclusion: { in: ->(_) { Gitlab.config.repositories.storages.keys } }
    validates :destination_storage_name,
    on: :create,
    presence: true,
    inclusion: { in: ->(_) { Gitlab.config.repositories.storages.keys } }

    default_value_for(:destination_storage_name, allows_nil: false) do
      pick_repository_storage
    end

    state_machine initial: :initial do
      event :schedule do
        transition initial: :scheduled
      end

      event :start do
        transition scheduled: :started
      end

      event :finish_replication do
        transition started: :replicated
      end

      event :finish_cleanup do
        transition replicated: :finished
      end

      event :do_fail do
        transition [:initial, :scheduled, :started] => :failed
        transition replicated: :cleanup_failed
      end

      before_transition started: :replicated do |storage_move|
        storage_move.container.set_repository_writable!

        storage_move.container.update_column(:repository_storage, storage_move.destination_storage_name)
      end

      before_transition started: :failed do |storage_move|
        storage_move.container.set_repository_writable!
      end

      state :initial, value: 1
      state :scheduled, value: 2
      state :started, value: 3
      state :finished, value: 4
      state :failed, value: 5
      state :replicated, value: 6
      state :cleanup_failed, value: 7
    end

    scope :order_created_at_desc, -> { order(created_at: :desc) }
  end

  class_methods do
    def pick_repository_storage
      klass.pick_repository_storage
    end

    def klass
      raise NotImplementedError
    end
  end

  def container
    raise NotImplementedError
  end

  private

  def container_repository_writeable
    errors.add(container.model_name.param_key.to_sym, _('is read only')) if container&.repository_read_only?
  end
end
