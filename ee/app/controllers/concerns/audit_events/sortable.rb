# frozen_string_literal: true

module AuditEvents
  module Sortable
    extend ActiveSupport::Concern

    include SortingHelper
    include SortingPreference

    included do
      before_action :set_sorting, only: [:index]
    end

    private

    def default_sort_order
      sort_value_recently_created
    end

    def set_sorting
      params[:sort] = set_sort_order
    end
  end
end
