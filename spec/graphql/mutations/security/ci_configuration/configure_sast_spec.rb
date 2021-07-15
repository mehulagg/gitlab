# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Security::CiConfiguration::ConfigureSast do
  include GraphqlHelpers

  let(:service) { ::Security::CiConfiguration::SastCreateService }

  subject { resolve(described_class, args: { project_path: project.full_path, configuration: {} }, ctx: { current_user: user }) }

  include_examples 'graphql mutations security ci configuration'

  it 'raises a ArgumentError error if the configuration parameter is not provided' do
    project.add_developer(user)
    expect { resolve(described_class, args: { project_path: project.full_path }, ctx: { current_user: user }) }.to raise_error(ArgumentError)
  end
end
