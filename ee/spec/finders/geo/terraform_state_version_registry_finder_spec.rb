# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::TerraformStateVersionRegistryFinder do
  it_behaves_like 'a framework registry finder', :geo_terraform_state_version_registry
end
