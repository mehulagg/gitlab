# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    module Stages
      class UpdateService < BaseService
        def initialize(parent:, current_user:, params:)
          super

          @params = params
        end

        def execute
          return forbidden unless can?(current_user, :update_group_stage, parent)

          parent.cycle_analytics_stages.model.transaction do
            persist_default_stages!

            @stage = find_stage
            handle_position_change
            @stage.assign_attributes(filtered_params)

            raise ActiveRecord::Rollback unless @stage.valid?

            @stage.save!
          end

          @stage.valid? ? success(@stage, :ok) : error(@stage)
        end

        private

        def filtered_params
          {}.tap do |new_params|
            if default_stage?
              new_params[:hidden] = params[:hidden] # for default stage only hidden parameter is allowed
            else
              new_params.merge!(params)
            end
          end.compact
        end

        def default_stage?
          Gitlab::Analytics::CycleAnalytics::DefaultStages.names.include?(params[:id])
        end

        # rubocop: disable CodeReuse/ActiveRecord
        def find_stage
          if default_stage?
            # default stages are already persisted
            parent.cycle_analytics_stages.find_by!(name: params[:id])
          else
            parent.cycle_analytics_stages.find(params[:id])
          end
        end
        # rubocop: enable CodeReuse/ActiveRecord

        def handle_position_change
          # make sure that unpositioned items have relative_position
          @stage.class.move_nulls_to_end(parent.cycle_analytics_stages.ordered)

          move_before_id = params.delete(:move_before_id)
          move_after_id = params.delete(:move_after_id)

          if move_before_id
            before_stage = @stage.find_with_same_parent!(move_before_id)
            @stage.move_before(before_stage)
          elsif move_after_id
            after_stage = @stage.find_with_same_parent!(move_after_id)
            @stage.move_after(after_stage)
          end
        end
      end
    end
  end
end
