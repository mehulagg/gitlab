# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::PermissionTypes::Epic do
  specify do
    expected_permissions = [:read_epic, :read_epic_iid, :update_epic, :destroy_epic,
                            :admin_epic, :create_epic, :create_note, :award_emoji]

    expected_permissions.each do |permission|
      expect(described_class).to have_graphql_field(permission)
    end
  end
end
