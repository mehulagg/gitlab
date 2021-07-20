# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Geo::LfsObjectRegistriesResolver do
  it_behaves_like 'a Geo registries resolver', :geo_lfs_object_registry
end
