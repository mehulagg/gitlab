# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::LfsObjectRegistryFinder do
  it_behaves_like 'a framework registry finder', :geo_lfs_object_registry
end
