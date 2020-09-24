# frozen_string_literal: true

module EE
  module API
    module Entities
      class GitlabLicense < Grape::Entity
        expose :id,
               :plan,
               :created_at,
               :starts_at,
               :expires_at,
               :historical_max,
               :maximum_user_count,
               :licensee,
               :add_ons

        expose :expired?, as: :expired

        expose :overage do |license, options|
          license.expired? ? license.overage_with_historical_max : license.overage(options[:current_active_users_count])
        end

        expose :user_limit do |license, options|
          license.restricted?(:active_user_count) ? license.restrictions[:active_user_count] : 0
        end
      end
    end
  end
end
