# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::PermissionTypes::Ci::Job do
  it do
    expected_permissions = [
      :read_job_artifacts, :read_build, :update_build
    ]

    expected_permissions.each do |permission|
      expect(described_class).to have_graphql_field(permission)
    end
  end
end
