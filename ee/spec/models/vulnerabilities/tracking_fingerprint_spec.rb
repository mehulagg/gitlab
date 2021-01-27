# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Vulnerabilities::TrackingFingerprint do
  let(:tracking_fingerprint) { create(:tracking_fingerprint) }

  context 'database uniqueness' do
    let(:new_tracking_fingerprint) { tracking_fingerprint.dup }

    it "when all index attributes are identical" do
      expect { new_tracking_fingerprint.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end

#    describe 'when some parameters are changed' do
#      using RSpec::Parameterized::TableSyntax
#
#      # we use block to delay object creations
#      where(:key, :new_value) do
#        :finding | create(:vulnerabilities_finding)
#        :full_sha | 'NEW SHA'
#        :track_type | :hash
#        :track_method | :hash
#        :priority | :hash
#      end
#
#      with_them do
#        it "is valid" do
#          expect { new_tracking_fingerprint.update!({ key => new_value }) }.not_to raise_error
#        end
#      end
#    end
  end

  context 'raw_enum_values' do
    it 'returns an integer for priority_raw' do
      expect(tracking_fingerprint.priority_raw).to be_an(Integer)
    end

    it 'returns an integer for track_type_raw' do
      expect(tracking_fingerprint.track_type_raw).to be_an(Integer)
    end

    it 'returns an integer for track_method_raw' do
      expect(tracking_fingerprint.track_method_raw).to be_an(Integer)
    end
  end

  context 'comparisons' do
    describe '#types_comparable?' do
      let(:tracking_fingerprint2) { tracking_fingerprint.dup }

      it 'returns true for exact matching types' do
        expect(tracking_fingerprint.types_comparable?(tracking_fingerprint2)).to eq(true)
      end

      it 'returns false for non-matching, non-legacy types' do
        tracking_fingerprint.track_type = :hash
        tracking_fingerprint2.track_type = :source
        expect(tracking_fingerprint.types_comparable?(tracking_fingerprint2)).to eq(false)
      end

      it 'returns true if one is a legacy type' do
        tracking_fingerprint2.track_type = :legacy
        expect(tracking_fingerprint.types_comparable?(tracking_fingerprint2)).to eq(true)
      end
    end

    describe '#same_type?' do
      let(:tracking_fingerprint2) { tracking_fingerprint.dup }

      it 'returns true for exact matching types' do
        expect(tracking_fingerprint.same_type?(tracking_fingerprint2)).to eq(true)
      end

      it 'returns false for non-exact matching types' do
        tracking_fingerprint2.track_type = :legacy
        expect(tracking_fingerprint.same_type?(tracking_fingerprint2)).to eq(false)
      end
    end
  end
end
