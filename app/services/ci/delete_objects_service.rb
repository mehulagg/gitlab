# frozen_string_literal: true

module Ci
  class DeleteObjectsService
    BATCH_SIZE = 100
    LEASE_LIMIT = 10.minutes

    def execute
      objects = load_next_batch
      destroy_everything(objects)
    end

    def remaining_count(limit:)
      Ci::DeletedObject.ready_for_destruction(limit).count
    end

    private

    def load_next_batch
      objects = Ci::DeletedObject.none

      Ci::DeletedObject.transaction do
        objects = Ci::DeletedObject.lock_for_destruction(BATCH_SIZE).load
        next unless objects.any?

        Ci::DeletedObject
          .for_relationship(objects)
          .update_all(pick_up_at: LEASE_LIMIT.from_now)
      end

      objects
    end

    def destroy_everything(objects)
      return unless objects.any?

      objects.each { |object| object.file.remove! }
      Ci::DeletedObject.for_relationship(objects).delete_all
    end
  end
end
