# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pages::MigrateLegacyStorageToDeploymentService do
  let(:project) { create(:project, :repository) }

  # TODO: simplify this setup
  before do
    pipeline = create(:ci_pipeline, project: project, sha: project.commit('HEAD').sha)
    build = create(:ci_build, pipeline: pipeline, ref: 'HEAD')
    file = fixture_file_upload("spec/fixtures/pages.zip")
    metadata = fixture_file_upload("spec/fixtures/pages.zip.meta")
    create(:ci_job_artifact, :correct_checksum, file: file, job: build)
    create(:ci_job_artifact, file_type: :metadata, file_format: :gzip, file: metadata, job: build)

    expect(Projects::UpdatePagesService.new(project, build).execute[:status]).to eq(:success)
  end

  it 'works' do
    expect do
      described_class.new(project).execute
    end.to change { project.reload.pages_deployments.count }.by(1)
  end
end
