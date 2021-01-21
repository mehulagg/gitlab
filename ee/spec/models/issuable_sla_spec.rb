# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuableSla do
  describe 'associations' do
    it { is_expected.to belong_to(:issue).required }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:due_at) }
  end

  describe 'scopes' do
    describe '.exceeded_for_issues' do
      subject { described_class.exceeded_for_issues }

      let_it_be(:project) { create(:project) }
      let_it_be_with_reload(:issue) { create(:issue, project: project) }
      let_it_be_with_reload(:issuable_sla) { create(:issuable_sla, issue: issue, due_at: 1.hour.ago) }

      context 'issue closed' do
        before do
          issue.close!
        end

        it { is_expected.to be_empty }
      end

      context 'issue opened' do
        context 'due_at has not passed' do
          before do
            issuable_sla.update!(due_at: 1.hour.from_now)
          end

          it { is_expected.to be_empty }
        end

        context 'when due date has passed' do
          it { is_expected.to contain_exactly(issuable_sla) }
        end
      end
    end
  end
end
