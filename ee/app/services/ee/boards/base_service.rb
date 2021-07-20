# frozen_string_literal: true

module EE
  module Boards
    module BaseService
      # rubocop: disable CodeReuse/ActiveRecord
      def filter_assignee
        return unless params.key?(:assignee_id)

        assignee = ::User.find_by(id: params.delete(:assignee_id))
        params.merge!(assignee: assignee)
      end
      # rubocop: enable CodeReuse/ActiveRecord

      # rubocop: disable CodeReuse/ActiveRecord
      def filter_milestone
        return if params[:milestone_id].blank?
        return if ::Milestone::Predefined::ALL.map(&:id).include?(params[:milestone_id].to_i)

        finder_params =
          case parent
          when Group
            { group_ids: parent.self_and_ancestors }
          when Project
            { project_ids: [parent.id], group_ids: parent.group&.self_and_ancestors }
          end

        milestone = ::MilestonesFinder.new(finder_params).find_by(id: params[:milestone_id])

        params.delete(:milestone_id) unless milestone
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def filter_iteration
        return if params[:iteration_id].blank?
        return if ::Iteration::Predefined::ALL.map(&:id).include?(params[:iteration_id].to_i)

        iteration = IterationsFinder.new(current_user, iterations_finder_params).find_by(id: params[:iteration_id]) # rubocop: disable CodeReuse/ActiveRecord

        params.delete(:iteration_id) unless iteration
      end

      def filter_labels
        if params.key?(:label_ids)
          params[:label_ids] = (labels_service.filter_labels_ids_in_param(:label_ids) || [])
        elsif params.key?(:labels)
          params[:label_ids] = (labels_service.find_or_create_by_titles.map(&:id) || [])
        end
      end

      def labels_service
        @labels_service ||= ::Labels::AvailableLabelsService.new(current_user, parent, params)
      end

      def iterations_finder_params
        { parent: parent, include_ancestors: true, state: 'all' }
      end
    end
  end
end
