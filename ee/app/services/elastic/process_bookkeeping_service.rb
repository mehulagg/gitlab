# frozen_string_literal: true

module Elastic
  class ProcessBookkeepingService
    REDIS_SET_KEY = 'elastic:incremental:updates:0:zset'
    REDIS_SCORE_KEY = 'elastic:incremental:updates:0:score'
    LIMIT = 10_000

    class << self
      # Add some records to the processing queue. Items must be serializable to
      # a Gitlab::Elastic::DocumentReference
      def track!(*items)
        return true if items.empty?

        items.map! { |item| ::Gitlab::Elastic::DocumentReference.serialize(item) }

        with_redis do |redis|
          # Efficiently generate a guaranteed-unique score for each item
          max = redis.incrby(self::REDIS_SCORE_KEY, items.size)
          min = (max - items.size) + 1

          (min..max).zip(items).each_slice(1000) do |group|
            logger.debug(class: self.name,
                         redis_set: self::REDIS_SET_KEY,
                         message: 'track_items',
                         count: group.count,
                         tracked_items_encoded: group.to_json)

            redis.zadd(self::REDIS_SET_KEY, group)
          end
        end

        true
      end

      def queue_size
        with_redis { |redis| redis.zcard(self::REDIS_SET_KEY) }
      end

      def clear_tracking!
        with_redis do |redis|
          Gitlab::Instrumentation::RedisClusterValidator.allow_cross_slot_commands do
            redis.unlink(self::REDIS_SET_KEY, self::REDIS_SCORE_KEY)
          end
        end
      end

      def logger
        # build already caches the logger via request store
        ::Gitlab::Elasticsearch::Logger.build
      end

      def with_redis(&blk)
        Gitlab::Redis::SharedState.with(&blk) # rubocop:disable CodeReuse/ActiveRecord
      end

      def maintain_indexed_associations(object, associations)
        each_indexed_association(object, associations) do |_, association|
          association.find_in_batches do |group|
            track!(*group)
          end
        end
      end

      private

      def each_indexed_association(object, associations)
        associations.each do |association_name|
          association = object.association(association_name)
          scope = association.scope
          klass = association.klass

          if klass == Note
            scope = scope.searchable
          end

          yield klass, scope
        end
      end
    end

    def execute
      self.class.with_redis { |redis| execute_with_redis(redis) }
    end

    private

    def execute_with_redis(redis)
      start_time = Time.current

      specs = redis.zrangebyscore(self.class::REDIS_SET_KEY, '-inf', '+inf', limit: [0, LIMIT], with_scores: true)
      return 0 if specs.empty?

      first_score = specs.first.last
      last_score = specs.last.last

      logger.info(
        message: 'bulk_indexing_start',
        records_count: specs.count,
        first_score: first_score,
        last_score: last_score
      )

      refs = deserialize_all(specs)
      refs.preload_database_records.each { |ref| submit_document(ref) }
      failures = bulk_indexer.flush

      # Re-enqueue any failures so they are retried
      self.class.track!(*failures) if failures.present?

      # Remove all the successes
      redis.zremrangebyscore(self.class::REDIS_SET_KEY, first_score, last_score)

      records_count = specs.count

      logger.info(
        message: 'bulk_indexing_end',
        records_count: records_count,
        failures_count: failures.count,
        first_score: first_score,
        last_score: last_score,
        bulk_execution_duration_s: Time.current - start_time
      )

      records_count
    end

    def deserialize_all(specs)
      refs = ::Gitlab::Elastic::DocumentReference::Collection.new
      specs.each do |spec, _|
        refs.deserialize_and_add(spec)
      rescue ::Gitlab::Elastic::DocumentReference::InvalidError => err
        logger.warn(
          message: 'submit_document_failed',
          reference: spec,
          error_class: err.class.to_s,
          error_message: err.message
        )
      end

      refs
    end

    def submit_document(ref)
      bulk_indexer.process(ref)
    end

    def bulk_indexer
      @bulk_indexer ||= ::Gitlab::Elastic::BulkIndexer.new(logger: logger)
    end

    def logger
      self.class.logger
    end
  end
end
