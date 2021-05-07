# frozen_string_literal: true

module EE
  module API
    module Entities
      class GitlabLicenseWithActiveUsers < GitlabLicense
        expose :active_users do |license, _options|
          license.daily_billable_users_count
        end
      end
    end
  end
end
