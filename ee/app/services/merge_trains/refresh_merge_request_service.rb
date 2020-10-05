# frozen_string_literal: true
module MergeTrains
  class RefreshMergeRequestService < BaseService
    include Gitlab::Utils::StrongMemoize

    ProcessError = Class.new(StandardError)

    attr_reader :merge_request

    ##
    # Arguments:
    # merge_request ... The merge request to be refreshed
    def execute(merge_request)
      @merge_request = merge_request

      validate!
      pipeline_created = create_pipeline! if should_create_pipeline?
      merge! if should_merge?

      success(pipeline_created: pipeline_created.present?)
    rescue ProcessError => e
      abort(e)
    end

    private

    def validate!
      unless project.merge_trains_enabled?
        raise ProcessError, 'project disabled merge trains'
      end

      unless merge_request.on_train?
        raise ProcessError, 'merge request is not on a merge train'
      end

      unless merge_request.mergeable_state?(skip_ci_check: true, skip_discussions_check: true)
        raise ProcessError, 'merge request is not mergeable'
      end

      unless previous_ref_exist?
        raise ProcessError, 'previous ref does not exist'
      end

      if pipeline_for_merge_train
        if pipeline_for_merge_train.complete? && !pipeline_for_merge_train.success?
          raise ProcessError, 'pipeline did not succeed'
        end
      end
    end

    def should_create_pipeline?
      pipeline_absent? || require_recreate? || stale_pipeline?
    end

    def create_pipeline!
      result = MergeTrains::CreatePipelineService.new(merge_request.project, merge_user)
        .execute(merge_request, previous_ref)

      raise ProcessError, result[:message] unless result[:status] == :success

      cancel_pipeline_for_merge_train(result[:pipeline])
      update_pipeline_for_merge_train(result[:pipeline])
    end

    def should_merge?
      pipeline_for_merge_train&.success? && first_in_train?
    end

    def merge!
      merge_train.start_merge!

      MergeRequests::MergeService.new(project, merge_user, merge_request.merge_params)
                                 .execute(merge_request, skip_discussions_check: true)

      raise ProcessError, "failed to merge. #{merge_request.merge_error}" unless merge_request.merged?

      merge_train.finish_merge!
    end

    def stale_pipeline?
      merge_train.stale?
    end

    def pipeline_absent?
      !pipeline_for_merge_train.present?
    end

    def merge_train
      merge_request.merge_train
    end

    def pipeline_for_merge_train
      merge_train.pipeline
    end

    def cancel_pipeline_for_merge_train(new_pipeline)
      pipeline_for_merge_train&.auto_cancel_running(new_pipeline, retries: 1)
    rescue ActiveRecord::StaleObjectError
      # Often the pipeline has already been canceled by the default cancelaltion
      # mechanizm `Ci::CreatePipelineService#cancel_pending_pipelines`. In this
      # case, we can ignore the exception as it's already canceled.
    end

    def update_pipeline_for_merge_train(pipeline)
      merge_train.refresh_pipeline!(pipeline.id)
    end

    def merge_user
      merge_request.merge_user
    end

    def first_in_train?
      strong_memoize(:is_first_in_train) do
        merge_train.first_in_train?
      end
    end

    def previous_ref_sha
      strong_memoize(:previous_ref_sha) do
        merge_request.project.repository.commit(previous_ref)&.sha
      end
    end

    def previous_ref
      previous_merge_request&.train_ref_path || merge_request.target_branch_ref
    end

    def previous_ref_exist?
      previous_ref_sha.present?
    end

    def previous_merge_request
      strong_memoize(:previous_merge_request) do
        merge_request.merge_train.prev
      end
    end

    def require_recreate?
      params[:require_recreate]
    end

    def abort(error)
      AutoMerge::MergeTrainService.new(project, merge_user)
        .abort(merge_request, error.message, process_next: false)

      error(error.message)
    end
  end
end
