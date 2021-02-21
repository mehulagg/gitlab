# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::MergeRequests::Accept do
  let_it_be(:user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }

  subject(:mutation) { described_class.new(context: context, object: nil, field: nil) }

  let_it_be(:context) do
    GraphQL::Query::Context.new(
      query: OpenStruct.new(schema: GitlabSchema),
      values: { current_user: user },
      object: nil
    )
  end

  describe '#resolve' do
    before do
      project.add_maintainer(user)
    end

    it 'merges the merge request' do
      merge_request = create(:merge_request, source_project: project)

      result = mutation.resolve(
        project_path: project.full_path,
        iid: merge_request.iid.to_s,
        sha: merge_request.diff_head_sha,
        squash: false
      )

      expect(result).to include(merge_request: be_merged)
    end

    it "can use the MERGE_WHEN_PIPELINE_SUCCEEDS strategy" do
      enum = ::Types::MergeStrategyEnum.values['MERGE_WHEN_PIPELINE_SUCCEEDS']
      merge_request = create(:merge_request, :with_head_pipeline,
                             source_project: project)

      result = mutation.resolve(
        project_path: project.full_path,
        iid: merge_request.iid.to_s,
        sha: merge_request.diff_head_sha,
        squash: false,
        auto_merge_strategy: enum.value
      )

      expect(result).not_to include(merge_request: be_merged)
      expect(result).to include(merge_request: be_auto_merge_enabled)
    end
  end
end
