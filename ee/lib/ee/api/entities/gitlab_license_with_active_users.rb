# frozen_string_literal: true

module EE
  module API
    module Entities
      class GitlabLicenseWithActiveUsers < GitlabLicense
        expose :active_users do |license, options|
          ::User.active.count
        end
      end
    end
  end
end
