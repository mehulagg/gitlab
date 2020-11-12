# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RequirementsManagement::Requirement do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  describe 'associations' do
    subject { build(:requirement) }

    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    subject { build(:requirement) }

    it { is_expected.to validate_presence_of(:project) }
    it { is_expected.to validate_presence_of(:author) }
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_length_of(:title).is_at_most(::Issuable::TITLE_LENGTH_MAX) }
    it { is_expected.to validate_length_of(:title_html).is_at_most(::Issuable::TITLE_HTML_LENGTH_MAX) }
  end

  describe 'scopes' do
    describe '.counts_by_state' do
      let_it_be(:opened) { create(:requirement, project: project, state: :opened) }
      let_it_be(:archived) { create(:requirement, project: project, state: :archived) }

      subject { described_class.counts_by_state }

      it { is_expected.to contain_exactly(['archived', 1], ['opened', 1]) }
    end

    describe '.with_author' do
      let_it_be(:other_user) { create(:user) }
      let_it_be(:my_requirement) { create(:requirement, project: project, author: user) }
      let_it_be(:other_requirement) { create(:requirement, project: project, author: other_user) }

      context 'with one author' do
        subject { described_class.with_author(user) }

        it { is_expected.to contain_exactly(my_requirement) }
      end

      context 'with multiple authors' do
        subject { described_class.with_author([user, other_user]) }

        it { is_expected.to contain_exactly(my_requirement, other_requirement) }
      end
    end

    describe '.search' do
      let_it_be(:requirement_one) { create(:requirement, project: project, title: "it needs to do the thing") }
      let_it_be(:requirement_two) { create(:requirement, project: project, title: "it needs to not break") }

      subject { described_class.search(query) }

      context 'with a query that covers both' do
        let(:query) { 'it needs to' }

        it { is_expected.to contain_exactly(requirement_one, requirement_two) }
      end

      context 'with a query that covers neither' do
        let(:query) { 'break often' }

        it { is_expected.to be_empty }
      end

      context 'with a query that covers one' do
        let(:query) { 'do the thing' }

        it { is_expected.to contain_exactly(requirement_one) }
      end
    end
  end

  describe '#last_test_report_state' do
    let_it_be(:requirement) { create(:requirement) }

    context 'when latest test report is passing' do
      it 'returns passing' do
        create(:test_report, requirement: requirement, state: :passed, build: nil)

        expect(requirement.last_test_report_state).to eq('passed')
      end
    end

    context 'when latest test report is failing' do
      it 'returns failing' do
        create(:test_report, requirement: requirement, state: :failed, build: nil)

        expect(requirement.last_test_report_state).to eq('failed')
      end
    end

    context 'when there are no test reports' do
      it 'returns nil' do
        expect(requirement.last_test_report_state).to eq(nil)
      end
    end
  end

  describe '#status_manually_updated' do
    let_it_be(:requirement) { create(:requirement) }

    context 'when latest test report has a build' do
      it 'returns false' do
        create(:test_report, requirement: requirement, state: :passed)

        expect(requirement.last_test_report_manually_created?).to eq(false)
      end
    end

    context 'when latest test report does not have a build' do
      it 'returns true' do
        create(:test_report, requirement: requirement, state: :passed, build: nil)

        expect(requirement.last_test_report_manually_created?).to eq(true)
      end
    end
  end
end
