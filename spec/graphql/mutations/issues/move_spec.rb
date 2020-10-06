# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Issues::Move do
  let_it_be(:issue) { create(:issue) }
  let_it_be(:user) { create(:user) }
  let_it_be(:target_project) { create(:project) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    subject { mutation.resolve(project_path: issue.project.full_path, iid: issue.iid, target_project_path: target_project.full_path) }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can admin source project' do
      before do
        issue.project.add_developer(user)
      end

      it 'returns error' do
        issue = subject[:issue]
        errors = subject[:error]

        puts errors
      end

      # it 'returns the issue as discussion locked' do
      #   expect(mutated_issue).to eq(issue)
      #   expect(mutated_issue).to be_discussion_locked
      #   expect(subject[:errors]).to be_empty
      # end

      # context 'when passing locked as false' do
      #   let(:locked) { false }

      #   it 'unlocks the discussion' do
      #     issue.update!(discussion_locked: true)

      #     expect(mutated_issue).not_to be_discussion_locked
      #   end
      # end
    end
  end
end
