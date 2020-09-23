# frozen_string_literal: true

module EE
  module API
    module Entities
      module Scim
        class User < Grape::Entity
          expose :schemas
          expose :extern_uid, as: :id
          expose :active
          expose :email_user, as: :emails, using: ::EE::API::Entities::Scim::Emails

          expose :name, using: ::EE::API::Entities::Scim::UserName do |identity, _options|
            identity.user
          end

          expose :meta do
            expose :resource_type, as: :resourceType
          end
          expose :username, as: :userName do |identity, _options|
            identity.user.username
          end

          private

          DEFAULT_SCHEMA = 'urn:ietf:params:scim:schemas:core:2.0:User'

          def schemas
            [DEFAULT_SCHEMA]
          end

          def active
            object_active = object.try(:active)

            return true if object_active.nil?

            object_active
          end

          def email_type
            'work'
          end

          def email_primary
            true
          end

          def email_user
            [object.user]
          end

          def resource_type
            'User'
          end
        end
      end
    end
  end
end
