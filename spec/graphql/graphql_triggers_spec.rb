# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GraphqlTriggers do
  describe '.issue_updated' do
    it 'triggers the issueUpdated subscription' do
      issue = create(:issue)

      expect(GitlabSchema.subscriptions).to receive(:trigger).with('issueUpdated', { project_path: issue.project.full_path, iid: issue.iid }, issue)

      GraphqlTriggers.issue_updated(issue)
    end
  end
end
