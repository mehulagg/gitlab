# frozen_string_literal: true

module Boards
  module Epics
    class CreateService < Boards::BaseService
      def initialize(parent, user, params = {})
        @group = parent

        super(parent, user, params)
      end

      def execute
        error = check_arguments
        if error
          return ServiceResponse.error(message: error)
        end

        create_epic(params.merge(epic_params))
      end

      private

      alias_method :group, :parent

      def epic_params
        { label_ids: [list.label_id] }
      end

      def board
        @board ||= parent.epic_boards.find(params.delete(:board_id))
      end

      def list
        @list ||= board.lists.find(params.delete(:list_id))
      end

      def create_epic(params)
        created_epic = ::Epics::CreateService.new(group: group, current_user: current_user, params: params).execute

        ServiceResponse.success(payload: created_epic)
      rescue => error
        Gitlab::ErrorTracking.track_and_raise_for_dev_exception(error)
      end

      def check_arguments
        return _('Title required') if params[:title].blank?

        begin
          board
        rescue => e
          return _('Board not found') if @board.blank?
        end

        begin
          list
        rescue => e
          return _('List not found') if @list.blank?
        end

        nil
      end
    end
  end
end
