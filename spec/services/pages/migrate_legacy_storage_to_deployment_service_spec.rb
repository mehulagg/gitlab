# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Pages::MigrateLegacyStorageToDeploymentService do
  let(:project) { create(:project, :repository) }
  let(:service) { described_class.new(project) }

  it 'marks pages as not deployed if public directory is absent' do
    project.mark_pages_as_deployed

    expect(project.pages_metadatum.reload.deployed).to eq(true)

    expect(service.execute).to eq(false)

    expect(project.pages_metadatum.reload.deployed).to eq(false)
  end

  it 'does not mark pages as not deployed if public directory is absent but pages_deployment exists' do
    deployment = create(:pages_deployment, project: project)
    project.update_pages_deployment!(deployment)
    project.mark_pages_as_deployed

    expect(project.pages_metadatum.reload.deployed).to eq(true)

    expect(service.execute).to eq(false)

    expect(project.pages_metadatum.reload.deployed).to eq(true)
  end

  it 'does not mark pages as not deployed if public directory is absent but feature is disabled' do
    stub_feature_flags(pages_migration_mark_as_not_deployed: false)

    project.mark_pages_as_deployed

    expect(project.pages_metadatum.reload.deployed).to eq(true)

    expect(service.execute).to eq(false)

    expect(project.pages_metadatum.reload.deployed).to eq(true)
  end

  it 'removes pages archive when can not save deployment' do
    archive = fixture_file_upload("spec/fixtures/pages.zip")
    expect_next_instance_of(::Pages::ZipDirectoryService) do |zip_service|
      expect(zip_service).to receive(:execute).and_return([archive.path, 3])
    end

    expect_next_instance_of(PagesDeployment) do |deployment|
      expect(deployment).to receive(:save!).and_raise("Something")
    end

    expect do
      service.execute
    end.to raise_error("Something")

    expect(File.exist?(archive.path)).to eq(false)
  end

  context 'when pages site is deployed to legacy storage' do
    before do
      FileUtils.mkdir_p File.join(project.pages_path, "public")
      File.open(File.join(project.pages_path, "public/index.html"), "w") do |f|
        f.write("Hello!")
      end
    end

    it 'creates pages deployment' do
      expect do
        expect(described_class.new(project).execute).to eq(true)
      end.to change { project.reload.pages_deployments.count }.by(1)

      deployment = project.pages_metadatum.pages_deployment

      Zip::File.open(deployment.file.path) do |zip_file|
        expect(zip_file.glob("public").first.ftype).to eq(:directory)
        expect(zip_file.glob("public/index.html").first.get_input_stream.read).to eq("Hello!")
      end

      expect(deployment.file_count).to eq(2)
      expect(deployment.file_sha256).to eq(Digest::SHA256.file(deployment.file.path).hexdigest)
    end

    it 'removes tmp pages archive' do
      described_class.new(project).execute

      expect(File.exist?(File.join(project.pages_path, '@migrated.zip'))).to eq(false)
    end

    it 'does not change pages deployment if it is set' do
      old_deployment = create(:pages_deployment, project: project)
      project.update_pages_deployment!(old_deployment)

      expect do
        described_class.new(project).execute
      end.not_to change { project.pages_metadatum.reload.pages_deployment_id }.from(old_deployment.id)
    end

    it 'raises exception if exclusive lease is taken' do
      described_class.new(project).try_obtain_lease do
        expect do
          described_class.new(project).execute
        end.to raise_error(described_class::ExclusiveLeaseTakenError)
      end
    end
  end
end
