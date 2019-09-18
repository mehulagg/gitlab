# frozen_string_literal: true

require 'spec_helper'

describe NpmPackagePresenter do
  set(:project) { create(:project) }
  set(:package) { create(:npm_package, version: '1.0.4', project: project) }
  set(:latest_package) { create(:npm_package, version: '1.0.11', project: project) }
  let(:presenter) { described_class.new(project, package.name, project.packages.all) }

  describe '#dist_tags' do
    it { expect(presenter.dist_tags).to be_a(Hash) }
    it { expect(presenter.dist_tags[:latest]).to eq(latest_package.version) }
  end

  describe '#versions' do
    it { expect(presenter.versions).to be_a(Hash) }
    it { expect(presenter.versions[package.version]).to match_schema('public_api/v4/packages/npm_package_version', dir: 'ee') }
    it { expect(presenter.versions[latest_package.version]).to match_schema('public_api/v4/packages/npm_package_version', dir: 'ee') }

    # For older packages without metadata
    context "Returns package if it doesn't have metadata as long as the package exists" do
      let(:older_package1) { create(:npm_package, version: '1.0.2', project: project) }
      set(:older_package2) { create(:npm_package, version: '1.1.3', project: project) }
      let(:packages) { [older_package1, older_package2] }
      let(:package_tags) { { "latest": "1.0.2" } }
      let(:versions) { { "#{older_package1.version}" => { dist: { shasum: "#{older_package1.package_files.last.file_sha1}", tarball: "#{expose_url api_v4_projects_path(id: older_package1.project_id)}/packages/npm/#{older_package1.name}/-/#{older_package1.package_files.last.file_name}" }, name: "#{older_package1.name}", version: "#{older_package1.version}" }, "#{older_package2.version}" => { dist: { shasum: "#{older_package1.package_files.last.file_sha1}", tarball: "#{expose_url api_v4_projects_path(id: older_package2.project_id)}/packages/npm/#{older_package2.name}/-/#{older_package2.package_files.last.file_name}" }, name: "#{older_package2.name}", version: "#{older_package2.version}" } } }

      subject {described_class.new(project, older_package1.name, packages, package_tags, 'tags')}

      it "Builds the package hash from package_files instead of the package_metadatum.metadata" do
        expect(older_package1.package_metadatum.metadata.empty?).to eq(true)
        expect(subject.versions).to be_a(Hash)
        expect(subject.versions).to eq(versions)
      end
    end
  end
end
