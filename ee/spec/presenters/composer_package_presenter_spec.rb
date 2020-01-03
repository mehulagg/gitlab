# frozen_string_literal: true

require 'spec_helper'

describe ComposerPackagePresenter do
  set(:project) { create(:project) }
  set(:package) { create(:composer_package, version: '1.0.4', project: project) }
  set(:latest_package) { create(:composer_package, version: '2.0.0', project: project) }
  let(:presenter) { described_class.new(project.packages.all) }

  describe '#versions' do
    it { expect(package.composer_metadatum.json).to be_a(Hash) }
    it { expect(presenter.versions).to be_a(Hash) }
    it { expect(presenter.versions).to match_schema('public_api/v4/packages/composer_repository_schema', dir: 'ee') }
  end

  describe '#packages_root' do
    it { expect(presenter.packages_root('myHash')).to be_a(Hash) }
    it { expect(presenter.packages_root('myHash')).to match_schema('public_api/v4/packages/composer_repository_schema', dir: 'ee') }
  end
end
