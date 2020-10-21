# frozen_string_literal: true

module EE
  module API
    module Entities
      class GitlabLicenseWithActiveUsers < GitlabLicense
        expose :active_users do |license, options|
          ::License.current_active_users.count
        end
      end
    end
  end
end
