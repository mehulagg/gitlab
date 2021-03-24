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
  include Gitlab::Utils::StrongMemoize

  belongs_to :project
  belongs_to :namespace

  enum usage: Enums::InternalId.usage_resources

  validates :usage, presence: true

  scope :filter_by, -> (scope, usage) do
    where(**scope, usage: InternalId.usages[usage.to_s])
  end

  private

  class << self
    def track_greatest(subject, scope, usage, new_value, init)
      # update existing record
      next_iid = update_record!(subject, scope, usage,
        "GREATEST(last_value, #{connection.quote(new_value)})")
      return next_iid if next_iid

      # create a new record
      create_record!(subject, scope, usage, init) do |object|
        object.last_value = [object.last_value, new_value].max
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def generate_next(subject, scope, usage, init)
      # if we cannot increment, it means that object does not exist
      # create and retry
      next_iid = update_record!(subject, scope, usage,
        "last_value+1")
      return next_iid if next_iid

      # create a new record
      create_record!(subject, scope, usage, init) do |iid|
        iid.last_value += 1
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    def reset(subject, scope, usage, value)
      return false unless value

      iid = update_record!(subject, scope.merge(last_value: value), usage,
        "last_value - 1")
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

    private

    def update_record!(subject, scope, usage, new_value_sql)
      # TODO: figure out how to do it better, we miss the `returning last_value`
      # especially if we can use `.filter_by()`
      next_value_sql = "UPDATE internal_ids "
      next_value_sql += "SET last_value = #{new_value_sql} "
      next_value_sql += "WHERE usage=#{connection.quote(self.usages[usage.to_s])} "
      scope.each do |key, value|
        next_value_sql += "AND #{key}=#{connection.quote(value)} "
      end
      next_value_sql += "RETURNING last_value"

      result = connection.execute(next_value_sql)
      result.values[0].first if result.values.any?
    end

    def create_record!(subject, scope, usage, init)
      raise ArgumentError, 'Cannot initialize without init!' unless init

      instance = subject.is_a?(::Class) ? nil : subject

      subject.transaction(requires_new: true) do
        InternalId.create!(
          **scope,
          usage: InternalId.usages[usage.to_s],
          last_value: init.call(instance, scope) || 0
        ) do |subject|
          yield(subject) if block_given?
        end.last_value
      end
    end
  end
end
