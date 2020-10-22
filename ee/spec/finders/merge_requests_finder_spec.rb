# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequestsFinder do
  describe '#execute' do
    include_context 'MergeRequestsFinder multiple projects with merge requests context'

    it 'ignores filtering by weight' do
      params = { project_id: project1.id, scope: 'authored', state: 'opened', weight: Issue::WEIGHT_ANY }

      merge_requests = described_class.new(user, params).execute

      expect(merge_requests).to contain_exactly(merge_request1)
    end
  end
end
