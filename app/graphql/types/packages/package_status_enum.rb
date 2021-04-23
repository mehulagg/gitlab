# frozen_string_literal: true

module Types
  module Packages
    class PackageStatusEnum < BaseEnum
      PACKAGE_STATUS_NAMES = {
        default: 'Valid',
        hidden: 'Hidden',
        processing: 'Processing',
        error: 'Error'
      }.freeze

      ::Packages::Package.statuses.keys.each do |status|
        status_name = PACKAGE_STATUS_NAMES.fetch(status.to_sym, status.capitalize)
        value status.to_s.upcase, "Packages from the #{status_name} package manager", value: status.to_s
      end
    end
  end
end
