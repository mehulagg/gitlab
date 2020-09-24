# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Mutations::Issues::SetWeight do
  let(:issue) { create(:issue) }
  let(:user) { create(:user) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    let(:weight) { 2 }
    let(:mutated_issue) { subject[:issue] }

    subject { mutation.resolve(project_path: issue.project.full_path, iid: issue.iid, weight: weight) }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can update the issue' do
      before do
        issue.project.add_developer(user)
      end

      it 'returns the issue with correct weight' do
        expect(mutated_issue).to eq(issue)
        expect(mutated_issue.weight).to eq(2)
        expect(subject[:errors]).to be_empty
      end
    end
  end
end
