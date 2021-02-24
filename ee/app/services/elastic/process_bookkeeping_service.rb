# frozen_string_literal: true

module Elastic
  class ProcessBookkeepingService
    LIMIT = 10_000
    SHARDS_NUMBER = 16
    SHARDS = 0.upto(SHARDS_NUMBER).to_a

    class << self
      def shard_number(data)
        Elastic::BookkeepingShardService.shard_number(number_of_shards: SHARDS_NUMBER, data: data)
      end

      def redis_set_key(shard_number)
        "elastic:incremental:updates:#{shard_number}:zset"
      end

      def redis_score_key(shard_number)
        "elastic:incremental:updates:#{shard_number}:score"
      end

      # Add some records to the processing queue. Items must be serializable to
      # a Gitlab::Elastic::DocumentReference
      def track!(*items)
        return true if items.empty?

        items.map! { |item| ::Gitlab::Elastic::DocumentReference.serialize(item) }

        grouped_items = items.group_by { |item| shard_number(item) }

        with_redis do |redis|
          grouped_items.each do |shard_number, shard_items|
            set_key = redis_set_key(shard_number)

            # Efficiently generate a guaranteed-unique score for each item
            max = redis.incrby(redis_score_key(shard_number), shard_items.size)
            min = (max - shard_items.size) + 1

            (min..max).zip(shard_items).each_slice(1000) do |group|
              logger.debug(class: self.name,
                          redis_set: set_key,
                          message: 'track_items',
                          count: group.count,
                          tracked_items_encoded: group.to_json)

              redis.zadd(set_key, group)
            end
          end
        end

        true
      end

      def queue_size
        with_redis do |redis|
          counts = SHARDS.map do |shard_number|
            redis.zcard(redis_set_key(shard_number))
          end

          counts.sum
        end
      end

      def clear_tracking!
        with_redis do |redis|
          Gitlab::Instrumentation::RedisClusterValidator.allow_cross_slot_commands do
            keys = SHARDS.map { |m| [redis_set_key(m), redis_score_key(m)] }.flatten

            redis.unlink(*keys)
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

      SHARDS.sum do |shard_number|
        set_key = self.class.redis_set_key(shard_number)

        specs = redis.zrangebyscore(set_key, '-inf', '+inf', limit: [0, LIMIT], with_scores: true)
        next 0 if specs.empty?

        first_score = specs.first.last
        last_score = specs.last.last

        logger.info(
          message: 'bulk_indexing_start',
          redis_set: set_key,
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
        redis.zremrangebyscore(set_key, first_score, last_score)

        records_count = specs.count

        logger.info(
          message: 'bulk_indexing_end',
          redis_set: set_key,
          records_count: records_count,
          failures_count: failures.count,
          first_score: first_score,
          last_score: last_score,
          bulk_execution_duration_s: Time.current - start_time
        )

        records_count
      end
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
