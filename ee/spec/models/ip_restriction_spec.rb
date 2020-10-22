# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IpRestriction do
  describe 'relations' do
    it { is_expected.to belong_to(:group) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:range) }
    it { is_expected.to validate_presence_of(:group_id) }

    describe '#valid_subnet' do
      subject { described_class.new(group: create(:group), range: range) }

      context 'valid subnet' do
        let(:range) { '192.168.0.0/24' }

        it 'succeeds' do
          expect(subject.valid?).to be_truthy
        end
      end

      context 'invalid subnet' do
        let(:range) { 'boom!' }

        it 'fails' do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:range]).to include('is an invalid IP address range')
        end
      end
    end

    describe '#allow_root_group_only' do
      subject { described_class.new(group: group, range: '192.168.0.0/24' ) }

      context 'top-level group' do
        let(:group) { create(:group) }

        it 'succeeds' do
          expect(subject.valid?).to be_truthy
        end
      end

      context 'subgroup' do
        let(:group) { create(:group, :nested) }

        it 'fails' do
          expect(subject.valid?).to be_falsey
          expect(subject.errors[:base]).to include('IP subnet restriction only allowed for top-level groups')
        end
      end
    end
  end

  describe '#allows_address?' do
    let(:range) { '192.168.0.0/24' }
    let(:address) { '192.168.0.1' }

    subject { described_class.new(range: range).allows_address?(address) }

    context 'address is within the range' do
      it { is_expected.to be_truthy }
    end

    context 'address is outside the range' do
      let(:range) { '10.0.0.0/8' }

      it { is_expected.to be_falsey }
    end

    context 'range is invalid' do
      let(:range) { nil }

      it { is_expected.to be_falsey }
    end

    context 'address is invalid' do
      let(:address) { nil }

      it { is_expected.to be_falsey }
    end
  end
end
