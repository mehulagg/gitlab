# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Geo::TerraformStateVersionRegistriesResolver, let_it_be_light_freeze: false do
  it_behaves_like 'a Geo registries resolver', :geo_terraform_state_version_registry
end
