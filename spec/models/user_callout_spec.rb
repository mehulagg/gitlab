# frozen_string_literal: true

require 'spec_helper'

RSpec.describe UserCallout do
  let_it_be(:callout) { create(:user_callout, dismissed_at: 1.year.ago) }

  it_behaves_like 'having unique enum values'

  describe 'relationships' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:feature_name) }
    it { is_expected.to validate_uniqueness_of(:feature_name).scoped_to([:user_id, :callout_scope]).ignoring_case_sensitivity.with_message('has already been assigned to this user for the same scope') }

    it { is_expected.to validate_exclusion_of(:callout_scope).in_array([nil]).with_message('cannot be nil') }
  end

  describe 'scopes' do
    describe '.with_feature_name' do
      let(:second_feature_name) { described_class.feature_names.keys.second }
      let(:last_feature_name) { described_class.feature_names.keys.last }

      it 'returns callout for requested feature name only' do
        callout1 = create(:user_callout, feature_name: second_feature_name )
        create(:user_callout, feature_name: last_feature_name )

        callouts = described_class.with_feature_name(second_feature_name)

        expect(callouts).to match_array([callout1])
      end
    end

    describe '.with_dismissed_after' do
      let_it_be(:callout_dismissed_month_ago) { create(:user_callout, dismissed_at: 1.month.ago )}

      it 'does not return callouts dismissed before specified date' do
        callouts = described_class.with_dismissed_after(15.days.ago)

        expect(callouts).to match_array([])
      end

      it 'returns callouts dismissed after specified date' do
        callouts = described_class.with_dismissed_after(2.months.ago)

        expect(callouts).to match_array([callout_dismissed_month_ago])
      end
    end

    describe '.within_scope' do
      let_it_be(:scoped_user_callout) { create(:user_callout, callout_scope: 'something') }

      subject(:within_scope) { described_class.within_scope(callout_scope) }

      context 'when called with a non-existent callout_scope' do
        let(:callout_scope) { 'does not exist' }

        it { is_expected.to match_array([]) }
      end

      context 'when called with an existing callout_scope' do
        let(:callout_scope) { 'something' }

        it { is_expected.to match_array([scoped_user_callout]) }
      end

      context 'when called with the default callout_scope' do
        let(:callout_scope) { '' }

        it { is_expected.to match_array([callout]) }
      end
    end

    describe '.without_scope' do
      let_it_be(:scoped_user_callout) { create(:user_callout, callout_scope: 'something') }

      subject(:without_scope) { described_class.without_scope }

      it { is_expected.to match_array([callout]) }
    end
  end
end
