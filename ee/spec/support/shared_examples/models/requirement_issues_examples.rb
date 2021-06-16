# frozen_string_literal: true

shared_examples 'a model with a requirement issue association' do
  describe 'requirement issue association' do
    subject { build(:requirement, requirement_issue: requirement_issue_arg) }

    let(:requirement_issue) { build(:requirement_issue) }

    context 'when the requirement issue is of type requirement' do
      let(:requirement_issue_arg) { requirement_issue }

      specify { expect(subject).to be_valid }
    end

    context 'when requirement issue is non-requirement issue' do
      let(:invalid_issue) { build(:issue) }
      let(:requirement_issue_arg) { invalid_issue }

      specify do
        expect(subject).not_to be_valid
        expect(subject.errors.messages[:requirement_issue]).to include(/must be an issue of type `Requirement`/)
      end
    end
  end
end
