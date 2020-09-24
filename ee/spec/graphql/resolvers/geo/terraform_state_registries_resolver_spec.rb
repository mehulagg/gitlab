# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Geo::TerraformStateRegistriesResolver do
  it_behaves_like 'a Geo registries resolver', :geo_terraform_state_registry
end
