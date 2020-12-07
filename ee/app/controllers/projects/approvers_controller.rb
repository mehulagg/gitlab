# frozen_string_literal: true

class Projects::ApproversController < Projects::ApplicationController
  before_action :authorize_for_subject!

  feature_category :source_code_management

  # @deprecated
  def destroy
    subject.approvers.find(params[:id]).destroy

    redirect_back_or_default(default: { action: 'index' })
  end

  def destroy_via_user_id
    subject.approvers.find_by_user_id(params[:user_id]).destroy

    redirect_back_or_default(default: { action: 'index' })
  end

  private

  def authorize_for_subject!
    access_denied! unless can?(current_user, :update_approvers, subject)
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def subject
    @subject ||=
      if params[:merge_request_id]
        project.merge_requests.find_by!(iid: params[:merge_request_id])
      else
        project
      end
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
