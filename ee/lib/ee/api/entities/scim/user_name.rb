# frozen_string_literal: true

module EE
  module API
    module Entities
      module Scim
        class UserName < Grape::Entity
          expose :name, as: :formatted
          expose :first_name, as: :givenName
          expose :last_name, as: :familyName
        end
      end
    end
  end
end
