# frozen_string_literal: true

module AuditEvents
  module EnforcesValidDateParams
    extend ActiveSupport::Concern

    included do
      before_action :validate_date_params, only: [:index]
    end

    private

    def validate_date_params
      unless valid_utc_date?(params[:created_before]) && valid_utc_date?(params[:created_after])
        flash[:alert] = _('Invalid date format. Please use UTC format as YYYY-MM-DD')
      end
    end

    def valid_utc_date?(date)
      date.blank? || date =~ Gitlab::Regex.utc_date_regex
    end
  end
end
