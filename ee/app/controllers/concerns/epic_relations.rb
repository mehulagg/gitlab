# frozen_string_literal: true

module EpicRelations
  extend ActiveSupport::Concern
  include Gitlab::Utils::StrongMemoize
  include IssuableLinks

  included do
    before_action :authorize_read!, only: :index
    before_action :authorize_admin!, only: [:create, :destroy, :update]
  end

  def authorize_read!
    render_403 unless can?(current_user, :read_epic, epic)
  end

  def authorize_admin!
    render_403 unless can?(current_user, "admin_#{authorized_object}", epic)
  end

  def epic
    strong_memoize(:epic) do
      group.epics.find_by_iid(params[:epic_id])
    end
  end

  def authorized_object
    raise NotImplementedError
  end
end
