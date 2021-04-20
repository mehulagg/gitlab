# frozen_string_literal: true

class EmptyRepoUploadExperiment < ApplicationExperiment # rubocop:disable Gitlab/NamespacedClass
  include Gitlab::Git::WrapsGitalyErrors

  TRACKING_START_DATE = DateTime.parse('2021/4/19')
  INITIAL_COMMIT_COUNT = 1

  def track_initial_write
    return unless should_track? # early return if we don't need to ask for commit counts
    return unless context.project.created_at > TRACKING_START_DATE # early return for older projects
    return unless commit_count == INITIAL_COMMIT_COUNT

    track(:initial_write, project: context.project)
  end

  private

  def commit_count
    Gitlab::ProjectCommitCount.commit_count_for(context.project,
      max_count: INITIAL_COMMIT_COUNT
    )
  rescue StandardError => e
    Gitlab::ErrorTracking.track_exception(e, experiment: name)
  end
end
