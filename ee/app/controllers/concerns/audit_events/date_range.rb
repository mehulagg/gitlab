# frozen_string_literal: true

module AuditEvents
  module DateRange
    extend ActiveSupport::Concern

    included do
      before_action :set_date_range, only: [:index]
    end

    private

    def set_date_range
      params[:created_before] = params[:created_before].nil? ? Date.today.end_of_day : Date.parse(params[:created_before]).end_of_day
      params[:created_after] = Date.today.beginning_of_month unless params[:created_after]
    end
  end
end
