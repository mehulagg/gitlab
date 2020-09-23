# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Evidences::BuildArtifactEntity do
  include Gitlab::Routing

  let(:build) { create(:ci_build, :artifacts) }
  let(:entity) { described_class.new(build) }

  subject { entity.as_json }

  it 'exposes the artifacts url' do
    expect(subject[:url]).to eq(download_project_job_artifacts_url(build.project, build))
  end
end
