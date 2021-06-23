# frozen_string_literal: true

module API
  module Entities
    class ResourceAccessToken < Entities::PersonalAccessToken
      expose :access_level do |token, options|
        token.user.project_members.first.access_level
      end
    end
  end
end
