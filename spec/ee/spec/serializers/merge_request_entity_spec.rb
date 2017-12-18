require 'spec_helper'

describe MergeRequestEntity do
  let(:user) { create(:user) }
  let(:project) { create :project, :repository }
  let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
  let(:request) { double('request', current_user: user) }

  subject do
    described_class.new(merge_request, request: request)
  end

  it 'has performance data' do
    build = create(:ci_build, name: 'job')

    allow(subject).to receive(:expose_performance_data?).and_return(true)
    allow(merge_request).to receive(:base_performance_artifact).and_return(build)
    allow(merge_request).to receive(:head_performance_artifact).and_return(build)

    expect(subject.as_json).to include(:performance)
  end

  it 'has sast data' do
    build = create(:ci_build, name: 'sast')

    allow(subject).to receive(:expose_sast_data?).and_return(true)
    allow(merge_request).to receive(:sast_artifact).and_return(build)

    expect(subject.as_json).to include(:sast)
  end

  it 'has clair data' do
    build = create(:ci_build, name: 'clair')

    allow(subject).to receive(:expose_clair_data?).and_return(true)
    allow(merge_request).to receive(:clair_artifact).and_return(build)

    expect(subject.as_json).to include(:clair)
  end
end
