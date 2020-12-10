# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BlockingMergeRequestEntity do
  let(:merge_request) { create(:merge_request) }
  let(:project) { merge_request.target_project }
  let(:user) { create(:user) }

  let(:web_url) { Gitlab::Routing.url_helpers.project_merge_request_path(project, merge_request) }
  let(:request) { double('request', current_user: user) }
  let(:extra_options) { {} }

  subject(:entity) do
    options = extra_options.merge(current_user: user, request: request)
    described_class.new(merge_request, options)
  end

  it 'exposes simple attributes' do
    expect(entity.as_json).to include(
      id: merge_request.id,
      iid: merge_request.iid,
      title: merge_request.title,
      state: merge_request.state,
      created_at: merge_request.created_at,
      merged_at: merge_request.merged_at,
      closed_at: merge_request.metrics.latest_closed_at,
      web_url: web_url
    )
  end

  it 'serializes a blocking MR that lacks metrics' do
    expect(merge_request).to receive(:metrics).and_return(nil)

    expect(entity.as_json).to include(id: merge_request.id, closed_at: nil)
  end

  describe '#head_pipeline' do
    subject { entity.as_json[:head_pipeline] }

    before do
      merge_request.head_pipeline = create(:ci_pipeline, project: project)
    end

    context 'visible pipeline' do
      before do
        project.team.add_developer(user)
      end

      it { is_expected.to include(id: merge_request.head_pipeline.id) }
    end

    context 'hidden pipeline' do
      it { is_expected.to be_nil }
    end
  end

  describe '#reference' do
    let(:other_project) { create(:project) }

    subject { entity.as_json[:reference] }

    it { is_expected.to eq(merge_request.to_reference) }

    context 'from another project' do
      let(:extra_options) { { from_project: other_project } }

      it 'includes the fully-qualified reference when needed' do
        is_expected.to eq(merge_request.to_reference(other_project))
      end
    end
  end
end
