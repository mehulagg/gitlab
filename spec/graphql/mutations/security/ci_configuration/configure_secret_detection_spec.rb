# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Security::CiConfiguration::ConfigureSecretDetection do
  let(:mutation) { described_class.new(object: nil, context: context, field: nil) }

  let(:service) { ::Security::CiConfiguration::SecretDetectionCreateService }

  subject { mutation.resolve(project_path: project.full_path) }

  include_examples 'graphql mutations security ci configuration'
end
