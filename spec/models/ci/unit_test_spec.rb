# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::UnitTest do
  describe 'relationships' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:unit_test_failures) }
  end

  describe 'validations' do
    subject { build(:ci_unit_test) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:key_hash) }
  end

  describe '.find_or_create_by_batch' do
    it 'finds or creates records for the given unit test keys', :aggregate_failures do
      project = create(:project)
      existing_test = create(:ci_unit_test, project: project)
      new_key = Digest::SHA256.hexdigest(SecureRandom.hex)
      keys = [existing_test.key_hash, new_key]

      result = described_class.find_or_create_by_batch(project, keys)

      expect(result.map(&:key_hash)).to match_array([existing_test.key_hash, new_key])
      expect(result).to all(be_persisted)
    end
  end
end
