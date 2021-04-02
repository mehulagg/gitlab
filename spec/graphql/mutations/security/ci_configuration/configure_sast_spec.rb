# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Security::CiConfiguration::ConfigureSast do
  subject(:service) { ::Security::CiConfiguration::SastCreateService }

  include_examples 'graphql mutations security ci configuration'
end
