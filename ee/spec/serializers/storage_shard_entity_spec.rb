# frozen_string_literal: true

require 'spec_helper'

RSpec.describe StorageShardEntity do
  let(:entity) { described_class.new(StorageShard.new, request: double) }

  subject { entity.as_json }

  it { is_expected.to have_key(:name) }
end
