# frozen_string_literal: true

module Types
  module AlertManagement
    class DomainFilterEnum < BaseEnum
      graphql_name 'AlertManagementDomainFilter'
      description  'Filters the alerts based on given domain'

      ::AlertManagement::Alert::DOMAINS.keys.each do |view|
        value view.to_s.upcase, description: "Alerts for #{view.to_s.titleize} view"
      end
    end
  end
end
