# frozen_string_literal: true

module Types
  module AlertManagement
    class ViewFilterEnum < BaseEnum
      graphql_name 'AlertManagementViewFilter'
      description 'View filter'

      ::AlertManagement::Alert::VIEW_FILTERS.keys.each do |view|
        value view.to_s.upcase, description: "Alerts for #{view.to_s.titleize} view"
      end
    end
  end
end
