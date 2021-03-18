# frozen_string_literal: true

class RemoveUnreferencedLfsObjectsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :git_lfs

  # rubocop: disable Cop/DestroyAll
  def perform
    LfsObject.unreferenced_in_batches do |lfs_objects_without_projects|
      lfs_objects_without_projects.destroy_all
    end
  end
  # rubocop: enable Cop/DestroyAll
end
