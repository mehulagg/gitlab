# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupWikiRepository do
  describe 'associations' do
    it { is_expected.to belong_to(:shard) }
    it { is_expected.to belong_to(:group) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:shard) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:disk_path) }

    context 'uniqueness' do
      subject { described_class.new(shard: build(:shard), group: build(:group), disk_path: 'path') }

      it { is_expected.to validate_uniqueness_of(:group) }
      it { is_expected.to validate_uniqueness_of(:disk_path) }
    end
  end
end
