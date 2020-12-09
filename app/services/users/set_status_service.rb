# frozen_string_literal: true

module Users
  class SetStatusService
    include Gitlab::Allowable

    attr_reader :current_user, :target_user, :params

    def initialize(current_user, params)
      @current_user, @params = current_user, params.dup
      @target_user = params.delete(:user) || current_user
    end

    def execute
      return false unless can?(current_user, :update_user_status, target_user)

      if params[:emoji].present? || params[:message].present? || availability_set?
        set_status
      else
        remove_status
      end
    end

    private

    def set_status
      params[:emoji] = UserStatus::DEFAULT_EMOJI if params[:emoji].blank? && params[:message].present?
      params.delete(:availability) unless availability_set?

      user_status.update(params)
    end

    def remove_status
      UserStatus.delete(target_user.id)
    end

    def user_status
      target_user.status || target_user.build_status
    end

    def availability_set?
      availability_value = UserStatus.availabilities[params[:availability]]
      availability_value && availability_value != UserStatus.availabilities[:not_set]
    end
  end
end
