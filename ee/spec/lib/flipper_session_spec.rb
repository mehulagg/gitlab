# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe FlipperSession do
  describe '#flipper_id' do
    context 'without passing in an ID' do
      it 'returns a flipper_session:UUID' do
        expect(described_class.new.flipper_id).to match(/\Aflipper_session:\w{8}-\w{4}-\w{4}-\w{4}-\w{12}\z/)
      end
    end

    context 'passing in an ID' do
      it 'returns a flipper_session:def456' do
        id = 'abc123'

        expect(described_class.new(id).flipper_id).to eq("flipper_session:#{id}")
      end
    end
  end
end
