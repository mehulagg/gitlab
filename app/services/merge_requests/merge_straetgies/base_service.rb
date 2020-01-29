# frozen_string_literal: true

module MergeRequests
  module MergeStrategies
    class BaseService < ::BaseService
      def schedule(merge_request)
        clear_merge_error(merge_request)
      end

      def available_for?(merge_request)
        raise NotImplementedError
      end

      private

      def strategy
        strong_memoize(:strategy) do
          self.class.name.demodulize.remove('Service').underscore
        end
      end

      def clear_merge_error(merge_request)
        # merge_request.update(merge_error: nil, squash: params.fetch(:squash, false))
        merge_request.update_column(merge_error: nil)
      end

      def base_params
        { merge_strategy: strategy }
      end
    end
  end
end
