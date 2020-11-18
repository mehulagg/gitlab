# frozen_string_literal: true

module Gitlab
  module Graphql
    module Authorize
      module AuthorizeResource
        extend ActiveSupport::Concern

        RESOURCE_ACCESS_ERROR = "The resource that you are attempting to access does not exist or you don't have permission to perform this action"

        class_methods do
          def required_permissions
            # If the `#authorize` call is used on multiple classes, we add the
            # permissions specified on a subclass, to the ones that were specified
            # on its superclass.
            @required_permissions ||= if self.respond_to?(:superclass) && superclass.respond_to?(:required_permissions)
                                        superclass.required_permissions.dup
                                      else
                                        []
                                      end
          end

          def authorize(*permissions)
            required_permissions.concat(permissions)
          end

          def authorizes_object?
            defined?(@authorizes_object) ? @authorizes_object : false
          end

          def authorizes_object!
            @authorizes_object = true
          end
        end

        def find_object(*args)
          raise NotImplementedError, "Implement #find_object in #{self.class.name}"
        end

        def authorized_find!(*args, **kwargs)
          object = Graphql::Lazy.force(find_object(*args, **kwargs))

          authorize!(object)

          object
        end

        def authorize!(object)
          raise_resource_not_available_error! unless authorized_resource?(object)
        end

        def authorized_resource?(object)
          if Feature.enabled?(:graphql_framework_authorization) && self.class < ::Types::BaseObject
            self.class.authorized?(object, context)
          else
            # Sanity check. We don't want to accidentally allow a developer to authorize
            # without first adding permissions to authorize against
            if self.class.required_permissions.empty?
              raise Gitlab::Graphql::Errors::ArgumentError, "#{self.class.name} has no authorizations"
            end

            self.class.required_permissions.all? do |ability|
              # The actions could be performed across multiple objects. In which
              # case the current user is common, and we could benefit from the
              # caching in `DeclarativePolicy`.
              Ability.allowed?(current_user, ability, object, scope: :user)
            end
          end
        end

        def raise_resource_not_available_error!
          raise Gitlab::Graphql::Errors::ResourceNotAvailable, RESOURCE_ACCESS_ERROR
        end
      end
    end
  end
end
