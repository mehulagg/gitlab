# frozen_string_literal: true

module EE
  module Types
    module PermissionTypes
      module Project
        extend ActiveSupport::Concern

        prepended do
          ability_field :admin_path_locks
        end
      end
    end
  end
end
