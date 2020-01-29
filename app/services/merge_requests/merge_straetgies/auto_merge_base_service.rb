# frozen_string_literal: true

module MergeRequests
  module MergeStrategies
    class AutoMergeBaseService < MergeRequests::MergeStrategies::BaseService
      include Gitlab::Utils::StrongMemoize
      include MergeRequests::AssignsMergeParams

      def schedule(merge_request)
        assign_allowed_merge_params(merge_request, params.merge(merge_strategy: strategy))

        merge_request.auto_merge_enabled = true
        merge_request.merge_user = current_user

        return :failed unless merge_request.save

        yield if block_given?

        # Notify the event that auto merge is enabled or merge param is updated
        AutoMergeProcessWorker.perform_async(merge_request.id)

        success(strategy: strategy.to_sym)
      end

      def process(merge_request)
        raise NotImplementedError
      end

      def update(merge_request)
        assign_allowed_merge_params(merge_request, params.merge(merge_strategy: strategy))

        return :failed unless merge_request.save

        success(strategy: strategy.to_sym)
      end

      def cancel(merge_request)
        if clear_auto_merge_parameters(merge_request)
          yield if block_given?

          success
        else
          error("Can't cancel the automatic merge", 406)
        end
      end

      def abort(merge_request, reason)
        if clear_auto_merge_parameters(merge_request)
          yield if block_given?

          success
        else
          error("Can't abort the automatic merge", 406)
        end
      end

      private

      def strategy
        strong_memoize(:strategy) do
          self.class.name.demodulize.remove('Service').underscore
        end
      end

      def clear_auto_merge_parameters(merge_request)
        merge_request.auto_merge_enabled = false
        merge_request.merge_user = nil

        merge_request.merge_params&.except!(
          'should_remove_source_branch',
          'commit_message',
          'squash_commit_message',
          'merge_strategy'
        )

        merge_request.save
      end
    end
  end
end
