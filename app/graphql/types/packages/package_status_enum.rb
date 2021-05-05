# frozen_string_literal: true

module Types
  module Packages
    class PackageStatusEnum < BaseEnum
      ::Packages::Package.statuses.keys.each do |status|
        value status.to_s.upcase, "Packages with a #{status} status", value: status.to_s
      end
    end
  end
end
