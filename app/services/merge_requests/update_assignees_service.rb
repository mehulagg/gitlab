# frozen_string_literal: true

module MergeRequests
  class UpdateAssigneesService
    attr_reader :project, :user, :params

    def initialize(project, user = nil, params = {})
      @project = project
      @user = user
      @params = params
    end

    def execute(merge_request)
      return unless user&.can?(:update_merge_request, merge_request)

      merge_request.update!(assignee_ids: assignee_ids)
    end

    def assignee_ids
      params.fetch(:assignee_ids).take(1) # rubocop: disable CodeReuse/ActiveRecord (false positive)
    end
  end
end

MergeRequests::UpdateAssigneesService.prepend_if_ee('EE::MergeRequests::UpdateAssigneesService')
