# frozen_string_literal: true

module MergeRequests
  class MergeService < BaseService
    STRATEGY_MERGE_WHEN_PIPELINE_SUCCEEDS = 'merge_when_pipeline_succeeds'
    STRATEGY_MERGE = 'merge'
    STRATEGIES = [STRATEGY_MERGE_WHEN_PIPELINE_SUCCEEDS, STRATEGY_MERGE].freeze

    attr_reader :available_strategies

    class << self
      # NOTE: strategies must be sorted by the preferred order
      def all_strategies
        STRATEGIES
      end

      def get_service_class(strategy)
        return unless all_strategies.include?(strategy)

        "::MergeRequests::MergeStrategies::#{strategy.camelize}Service".constantize
      end
    end

    def schedule(merge_request)
      result = validate(merge_request)
      return result unless result[:status] == :success

      return update(merge_request) if merge_request.merge_strategy.present?

      strategy = merge_strategy_for(merge_request)
      service = get_service_instance(strategy)

      unless service&.available_for?(merge_request)
        return error("The merge strategy '#{strategy}' is not available for the merge request")
      end

      service.execute(merge_request)
    end

    def process(merge_request)
      return error("Can't process unless auto merge is enabled", 406) unless merge_request.auto_merge_enabled?

      get_service_instance(merge_request.merge_strategy).process(merge_request)
    end

    def cancel(merge_request)
      return error("Can't cancel unless auto merge is enabled", 406) unless merge_request.auto_merge_enabled?

      get_service_instance(merge_request.merge_strategy).cancel(merge_request)
    end

    def abort(merge_request, reason)
      return error("Can't abort unless auto merge is enabled", 406) unless merge_request.auto_merge_enabled?

      get_service_instance(merge_request.merge_strategy).abort(merge_request, reason)
    end

    def available_strategies(merge_request)
      @available_strategies[merge_request] ||= {}
      @available_strategies[merge_request] = self.class.all_strategies.select do |strategy|
        get_service_instance(strategy).available_for?(merge_request)
      end
    end

    def preferred_strategy(merge_request)
      available_strategies(merge_request).first
    end

    private

    def validate(merge_request)
      merge_service = ::MergeRequests::MergeBaseService.new(@project, current_user, merge_params)

      unless merge_service.hooks_validation_pass?(@merge_request)
        return error(error_type: :hook_validation_error)
      end

      unless params[:sha] && params[:sha] == @merge_request.diff_head_sha
        return error(error_type: :sha_mismatch)
      end

      success
    end

    def update(merge_request)
      get_service_instance(merge_request.merge_strategy).update(merge_request)
    end

    def get_service_instance(strategy)
      self.class.get_service_class(strategy)&.new(project, current_user, params)
    end

    def merge_strategy_for(merge_request)
      params[:merge_strategy] || preferred_strategy(merge_request)
    end
  end
end

MergeRequests::MergeService.prepend_if_ee('EE::MergeRequests::MergeService')
