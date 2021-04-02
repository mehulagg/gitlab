# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Security::CiConfiguration::ConfigureSecretDetection do
  subject(:service) { ::Security::CiConfiguration::SecretDetectionCreateService }

  include_examples 'graphql mutations security ci configuration'
end
