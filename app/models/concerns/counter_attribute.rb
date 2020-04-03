# frozen_string_literal: true

# Add capabilities to increment a numeric model attribute efficiently by
# using CQRS. When an attribute is incremented by a value, the increment
# is logged to a separate events table. When reading the attribute we can
# choose whether to:
# 1. Read the value persisted in the database. This is faster but less
#    accurate because it can take up to ConsolidateCountersWorker::DELAY
#    to be updated. Use this unless high accuracy is required.
#
# @example
#   project_statistics.commit_count
#
# 2. Read the value persisted in the database including logged events.
#    This is more accurate but slower to compute because it includes the
#    sum of the logged events.
#
# @example
#   project_statistics.accurate_commit_count
#
# Periodically, we consolidate the logged events into the origin attribute
# and delete them from the associcate events table.
#
# In order to use this module you need to ensure that an associate events
# table exists: E.g given a model/table
#  project_statistics (
#    project_id (reference),
#    namespace_id (reference),
#    commit_count (bigint),
#    storage_size (bigint),
#    ...
#  )
# To make `commit_count` and `storage_size` as counter attributes we need
# to ensure that an events table exists with the following schema:
#  project_statistics_events (
#    project_statistics_id (reference)
#    commit_count (bigint),
#    storage_size (bigint),
#    created_at (datetime)
#  )
#
# Note that only the primary key (project_statistics_id) and the counter
# attributes are needed for the events table. Other attributes (e.g.
# project_id) are not needed.
#
# Finally, we can enable the counter behavior:
#   class ProjectStatistics
#     counter_attribute :commit_count
#     counter_attribute :storage_size
#   end
#
# To increment the counter we can use the method:
#   increment_counter(:commit_count, 3)
#
module CounterAttribute
  UnknownAttributeError = Class.new(StandardError)
  TransactionForbiddenError = Class.new(StandardError)

  extend ActiveSupport::Concern

  CONSOLIDATION_BATCH_SIZE = 100

  included do |base|
    @counter_attribute_events_class = "#{base}Event".constantize
    @counter_attribute_events_table = @counter_attribute_events_class.table_name
    @counter_attribute_foreign_key = base.name.foreign_key

    has_many :counter_events, class_name: "#{@counter_attribute_events_class}"
  end

  class_methods do
    attr_reader :counter_attribute_events_class,
      :counter_attribute_events_table,
      :counter_attribute_foreign_key

    def counter_attribute(attribute)
      counter_attributes << attribute

      define_method("accurate_#{attribute}") do
        unless counter_attribute_enabled?(attribute)
          return read_attribute(attribute)
        end

        # Return the value persisted in the origin table + all related log events
        results = self.class
          .select("#{self.class.table_name}.#{attribute} + COALESCE(SUM(#{self.class.counter_attribute_events_table}.#{attribute}), 0) AS actual_value")
          .left_outer_joins(:counter_events)
          .where(self.class.arel_table[:id].eq(id))
          .group(self.class.arel_table[attribute], self.class.arel_table[:id])
        # Example of result query:
        # SELECT project_statistics.commit_count + COALESCE(
        #   SUM(project_statistics_events.commit_count), 0) AS actual_value
        # FROM "project_statistics"
        # LEFT OUTER JOIN "project_statistics_events"
        #   ON "project_statistics_events"."project_statistics_id" = "project_statistics"."id"
        # WHERE "project_statistics"."id" = 10
        # GROUP BY "project_statistics"."commit_count", "project_statistics"."id"

        results.first['actual_value']
      end
    end

    def counter_attributes
      @counter_attributes ||= Set.new
    end

    def counter_events_available?
      counter_attribute_events_class.exists?
    end

    # This method must only be called by ConsolidateCountersWorker
    # because it should run asynchronously and with exclusive lease.
    def slow_consolidate_counter_attributes!
      if Gitlab::Database.inside_transaction?
        raise TransactionForbiddenError, "cannot consolidate counter attributes inside a transaction"
      end

      consolidated_records_count = 0

      loop do
        ids_to_consolidate = next_batch_of_events(CONSOLIDATION_BATCH_SIZE)

        ids_to_consolidate.each do |id|
          slow_consolidate_counter_attributes_for!(id)
        end

        current_batch_size = ids_to_consolidate.size
        consolidated_records_count += current_batch_size

        break if current_batch_size < CONSOLIDATION_BATCH_SIZE
      end

      consolidated_records_count
    end

    private

    def next_batch_of_events(batch_size)
      counter_attribute_events_class
        .distinct
        .limit(batch_size)
        .pluck(counter_attribute_foreign_key)
    end

    # Delete events and update the model atomically.
    # E.g. given a model ProjectStatistics and its counter attributes, will produce
    # the following query:
    #
    # WITH events AS (
    #   DELETE FROM project_statistics_events
    #   WHERE project_statistics_id = 1
    #   RETURNING *
    # )
    # UPDATE project_statistics
    # SET
    #   build_artifacts_size = project_statistics.build_artifacts_size + sums.build_artifacts_size,
    #   commit_count = project_statistics.commit_count + sums.commit_count,
    #   ...
    # FROM (
    #   SELECT
    #     SUM(build_artifacts_size) AS build_artifacts_size,
    #     SUM(commit_count) AS commit_count,
    #     ...
    #   FROM events
    # ) AS sums
    # WHERE project_statistics.id = 1
    def slow_consolidate_counter_attributes_for!(id)
      return if counter_attributes.empty?

      consolidate_counters_sql = <<~SQL
        WITH events AS (
          DELETE FROM #{counter_attribute_events_table}
          WHERE #{counter_attribute_foreign_key} = #{id}
          RETURNING *
        )
        UPDATE #{table_name}
        SET #{counter_attributes.map { |attr| "#{attr} = #{table_name}.#{attr} + sums.#{attr}" }.join(', ')}
        FROM (
          SELECT #{counter_attributes.map { |attr| "SUM(#{attr}) AS #{attr}" }.join(', ')}
          FROM events
        ) AS sums
        WHERE #{table_name}.id = #{id}
      SQL

      connection.execute(consolidate_counters_sql)
    end
  end

  def counter_attribute_enabled?(attribute)
    counter_attributes_enabled? && counter_attribute?(attribute)
  end

  def increment_counter(attribute, increment)
    increment_counter!(attribute, increment)

  rescue ActiveRecord::ActiveRecordError => e
    Gitlab::ErrorTracking.track_exception(e,
      model: self.class.name,
      id: id,
      counter_attribute: attribute,
      increment: increment
    )
    false
  end

  def increment_counter!(attribute, increment)
    return if increment == 0

    if counter_attributes_enabled?
      log_event!(attribute, increment)
    else
      legacy_update_counter!(attribute, increment)
    end

    true
  end

  private

  def counter_attributes_enabled?
    # TODO: remove update_project_statistics_after_commit feature flag
    # because if disabled it conflicts with raising an exception if
    # increment runs inside a db transaction.
    Feature.enabled?(:efficient_counter_attribute, project, default_enabled: true) &&
      Feature.enabled?(:update_project_statistics_after_commit, default_enabled: true)
  end

  def counter_attribute?(attribute)
    self.class.counter_attributes.include?(attribute)
  end

  def log_event!(attribute, increment)
    # Forbid running inside transaction because in case of rollback it would
    # introduce data inconsistency
    if Gitlab::Database.inside_transaction?
      error = TransactionForbiddenError.new(
        'cannot perform increment inside a transaction because it may not be rolled back')
      Gitlab::ErrorTracking.track_exception(error, attribute: attribute)
    end

    unless counter_attribute?(attribute)
      raise UnknownAttributeError, "'#{attribute}' is not a counter attribute"
    end

    counter_events.create!(attribute => increment)
    ConsolidateCountersWorker.exclusively_perform_async(self.class.name)
  end

  def legacy_update_counter!(attribute, increment)
    update!(attribute => read_attribute(attribute) + increment)
  end
end
