# frozen_string_literal: true

require 'spec_helper'

describe GlobalPolicy do
  include ExternalAuthorizationServiceHelpers

  let(:current_user) { create(:user) }
  let(:user) { create(:user) }

  subject { described_class.new(current_user, [user]) }

  describe 'reading operations dashboard' do
    before do
      stub_licensed_features(operations_dashboard: true)
    end

    it { is_expected.to be_allowed(:read_operations_dashboard) }

    context 'when unlicensed' do
      before do
        stub_licensed_features(operations_dashboard: false)
      end

      it { is_expected.not_to be_allowed(:read_operations_dashboard) }
    end
  end

  it { is_expected.to be_disallowed(:read_licenses) }
  it { is_expected.to be_disallowed(:destroy_licenses) }

  it { expect(described_class.new(create(:admin), [user])).to be_allowed(:read_licenses) }
  it { expect(described_class.new(create(:admin), [user])).to be_allowed(:destroy_licenses) }

  describe 'view_productivity_analytics' do
    context 'for anonymous' do
      let(:current_user) { nil }

      it { is_expected.not_to be_allowed(:view_productivity_analytics) }
    end

    context 'for authenticated users' do
      it { is_expected.to be_allowed(:view_productivity_analytics) }
    end
  end

  describe 'view_code_analytics' do
    context 'for anonymous' do
      let(:current_user) { nil }

      it { is_expected.not_to be_allowed(:view_code_analytics) }
    end

    context 'for authenticated users' do
      it { is_expected.to be_allowed(:view_code_analytics) }
    end
  end
end
