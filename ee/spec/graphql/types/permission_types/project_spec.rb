# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::PermissionTypes::Project do
  specify do
    expected_permissions = [:admin_path_locks]

    expected_permissions.each do |permission|
      expect(described_class).to have_graphql_field(permission)
    end
  end
end
