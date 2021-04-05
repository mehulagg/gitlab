# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Security::CiConfiguration::ConfigureSast do
  let(:mutation) { described_class.new(object: nil, context: context, field: nil) }

  let(:service) { ::Security::CiConfiguration::SastCreateService }

  subject { mutation.resolve(project_path: project.full_path, configuration: {}) }

  include_examples 'graphql mutations security ci configuration'
end
