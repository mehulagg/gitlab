# frozen_string_literal: true

module Types
  class SecurityScannerTypeEnum < BaseEnum
    graphql_name 'SecurityScannerType'
    description 'The type of the security scanner'

    ::Security::SecurityJobsFinder.allowed_job_types.each do |scanner|
      value scanner.upcase.to_s
    end
  end
end
