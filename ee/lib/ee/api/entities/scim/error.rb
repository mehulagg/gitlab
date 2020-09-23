# frozen_string_literal: true

module EE
  module API
    module Entities
      module Scim
        class Error < Grape::Entity
          STATUS = 412

          expose :schemas
          expose :detail, safe: true
          expose :status

          private

          DEFAULT_SCHEMA = 'urn:ietf:params:scim:api:messages:2.0:Error'

          def schemas
            [DEFAULT_SCHEMA]
          end

          def status
            self.class::STATUS
          end
        end
      end
    end
  end
end
