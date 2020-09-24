# frozen_string_literal: true

module EE
  module IssuesFinder
    module Params
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      def by_epic?
        params[:epic_id].present?
      end

      def filter_by_no_epic?
        params[:epic_id].to_s.downcase == ::IssuableFinder::Params::FILTER_NONE
      end

      def filter_by_any_epic?
        params[:epic_id].to_s.downcase == ::IssuableFinder::Params::FILTER_ANY
      end

      def weights?
        params[:weight].present? && params[:weight] != ::Issue::WEIGHT_ALL
      end

      def filter_by_no_weight?
        params[:weight].to_s.downcase == ::IssuableFinder::Params::FILTER_NONE
      end

      def filter_by_any_weight?
        params[:weight].to_s.downcase == ::IssuableFinder::Params::FILTER_ANY
      end

      override :assignees
      # rubocop: disable CodeReuse/ActiveRecord
      def assignees
        strong_memoize(:assignees) do
          if assignee_ids?
            ::User.where(id: params[:assignee_ids])
          else
            super
          end
        end
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def epics
        if params[:include_subepics]
          ::Gitlab::ObjectHierarchy.new(::Epic.for_ids(params[:epic_id])).base_and_descendants.select(:id)
        else
          params[:epic_id]
        end
      end

      def iterations
        params[:iteration_id]
      end
    end
  end
end
