# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::LfsObjectRegistrySsf, :geo, type: :model do
  let_it_be(:registry) { create(:lfs_object_registry_ssf) }

  specify 'factory is valid' do
    expect(registry).to be_valid
  end

  include_examples 'a Geo framework registry'
end
