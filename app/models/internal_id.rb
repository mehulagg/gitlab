# frozen_string_literal: true

# An InternalId is a strictly monotone sequence of integers
# generated for a given scope and usage.
#
# The monotone sequence may be broken if an ID is explicitly provided
# to `.track_greatest_and_save!` or `#track_greatest`.
#
# For example, issues use their project to scope internal ids:
# In that sense, scope is "project" and usage is "issues".
# Generated internal ids for an issue are unique per project.
#
# See InternalId#usage enum for available usages.
#
# In order to leverage InternalId for other usages, the idea is to
# * Add `usage` value to enum
# * (Optionally) add columns to `internal_ids` if needed for scope.
class InternalId < ApplicationRecord
  extend Gitlab::Utils::StrongMemoize

  belongs_to :project
  belongs_to :namespace

  enum usage: Enums::InternalId.usage_resources

  validates :usage, presence: true

  scope :filter_by, -> (scope, usage) do
    where(**scope, usage: usage)
  end

  class << self
    def track_greatest(subject, scope, usage, new_value, init)
      internal_id_transactions_increment(operation: :track_greatest, usage: usage)

      function = Arel::Nodes::NamedFunction.new('GREATEST', [
        arel_table[:last_value],
        new_value.to_i
      ])

      next_iid = update_record!(subject, scope, usage, function)
      return next_iid if next_iid

      create_record!(subject, scope, usage, init) do |object|
        object.last_value = [object.last_value, new_value].max
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def generate_next(subject, scope, usage, init)
      internal_id_transactions_increment(operation: :generate, usage: usage)

      next_iid = update_record!(subject, scope, usage, arel_table[:last_value] + 1)

      return next_iid if next_iid

      create_record!(subject, scope, usage, init) do |iid|
        iid.last_value += 1
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def reset(subject, scope, usage, value)
      return false unless value

      internal_id_transactions_increment(operation: :reset, usage: usage)

      iid = update_record!(subject, scope.merge(last_value: value), usage, arel_table[:last_value] - 1)
      iid == value - 1
    end

    # Flushing records is generally safe in a sense that those
    # records are going to be re-created when needed.
    #
    # A filter condition has to be provided to not accidentally flush
    # records for all projects.
    def flush_records!(filter)
      raise ArgumentError, "filter cannot be empty" if filter.blank?

      where(filter).delete_all
    end

    def update_record!(subject, scope, usage, new_value)
      stmt = Arel::UpdateManager.new
      stmt.table(arel_table)
      stmt.set(arel_table[:last_value] => new_value)
      stmt.wheres = filter_by(scope, usage).arel.constraints

      connection.insert(stmt, 'Update InternalId', 'last_value')
    end

    def create_record!(subject, scope, usage, init)
      raise ArgumentError, 'cannot initialize without init!' unless init

      instance = subject.is_a?(::Class) ? nil : subject

      subject.transaction(requires_new: true) do
        last_value = init.call(instance, scope) || 0
        usage = InternalId.usages[usage.to_s]

        internal_id = InternalId.create!(**scope, usage: usage, last_value: last_value) do |subject|
          yield subject if block_given?
        end

        internal_id.last_value
      end
    end

    def internal_id_transactions_increment(operation:, usage:)
      self.internal_id_transactions_total.increment(
        operation: operation,
        usage: usage.to_s,
        in_transaction: ActiveRecord::Base.connection.transaction_open?.to_s
      )
    end

    def internal_id_transactions_total
      strong_memoize(:internal_id_transactions_total) do
        name = :gitlab_internal_id_transactions_total
        comment = 'Counts all the internal ids happening within transaction'

        Gitlab::Metrics.counter(name, comment)
      end
    end
  end
end
