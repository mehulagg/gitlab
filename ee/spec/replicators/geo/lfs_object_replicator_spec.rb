# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::LfsObjectReplicator do
  let(:model_record) { build(:lfs_object, :with_file) }

  it_behaves_like 'a blob replicator'
end
