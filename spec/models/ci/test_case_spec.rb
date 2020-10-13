# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::TestCase do
  describe '.find_or_create_by_batch' do
    it 'finds or creates records for the given test case keys', :aggregate_failures do
      project = create(:project)
      existing_tc = create(:ci_test_case, project: project)
      new_key = Digest::SHA256.hexdigest(SecureRandom.hex)
      keys = [existing_tc.key_hash, new_key]

      result = described_class.find_or_create_by_batch(project, keys)

      expect(result.map(&:key_hash)).to eq([existing_tc.key_hash, new_key])
    end
  end
end
