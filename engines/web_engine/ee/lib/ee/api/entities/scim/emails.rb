# frozen_string_literal: true

module EE
  module API
    module Entities
      module Scim
        class Emails < Grape::Entity
          expose :type
          expose :value do |user, _options|
            user.email
          end
          expose :primary

          private

          def type
            'work'
          end

          def primary
            true
          end
        end
      end
    end
  end
end
