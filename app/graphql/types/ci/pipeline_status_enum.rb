# frozen_string_literal: true

module Types
  module Ci
    class PipelineStatusEnum < BaseEnum
      descriptions = {
        created: 'Pipeline has been created',
        waiting_for_resource: 'A resource (for example, a runner) that the pipeline requires to run is unavailable',
        preparing: 'Pipeline is preparing to run',
        pending: 'Pipeline has not started running yet',
        running: 'Pipeline is running',
        failed: 'At least one stage of the pipeline failed',
        success: 'Pipeline completed successfully',
        canceled: 'Pipeline was canceled before completion',
        skipped: 'Pipeline was skipped',
        manual: 'Pipeline needs to be manually started',
        scheduled: 'Pipeline is scheduled to run'
      }

      ::Ci::Pipeline.all_state_names.each do |state_symbol|
        value state_symbol.to_s.upcase,
              description: descriptions[state_symbol],
              value: state_symbol.to_s
      end
    end
  end
end
