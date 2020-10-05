# frozen_string_literal: true
#
# Add role specific convenience methods for #add_user.
#
# There must exist a method of the form `#add_user(user, role, **params)`.
#
module AddUserRoleMethods
  extend ActiveSupport::Concern

  class_methods do
    def add_user_role_methods_for(*roles)
      roles.flatten.map(&:to_sym).each do |role|
        method_name = "add_#{role}"
        define_method method_name do |user, **params|
          add_user(user, role, **params)
        end
      end
    end
  end
end
