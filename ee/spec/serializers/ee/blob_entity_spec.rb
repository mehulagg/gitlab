# frozen_string_literal: true
require 'spec_helper'

RSpec.describe BlobEntity do
  let(:user) { create(:user) }
  let(:project) { create(:project, :repository) }
  let(:blob) { project.commit(project.default_branch).diffs.diff_files.first.blob }
  let(:request) { EntityRequest.new(project: project, ref: project.default_branch) }

  let(:entity) do
    described_class.new(blob, request: request)
  end

  context 'as json' do
    subject { entity.as_json }

    it 'exposes needed attributes' do
      expect(subject).to include(:file_lock)
    end
  end
end
