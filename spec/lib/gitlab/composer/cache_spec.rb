# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Composer::Cache do
  let_it_be(:package_name) { 'sample-project' }
  let_it_be(:json) { { 'name' => package_name } }
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :custom_repo, files: { 'composer.json' => json.to_json }, group: group) }
  let_it_be(:package1) { create(:composer_package, :with_metadatum, project: project, name: package_name, version: '1.0.0', json: json) }
  let_it_be(:package2) { create(:composer_package, :with_metadatum, project: project, name: package_name, version: '2.0.0', json: json) }

  let(:branch) { project.repository.find_branch('master') }

  describe '#update' do
    subject { described_class.new.update(package2) } # rubocop: disable Rails/SaveBang

    it 'updates the cached SHA' do
      expect { subject }.to change { package2.composer_metadatum.version_cache_sha }.from(nil).to(/^[A-Fa-f0-9]{64}$/)
    end
  end
end
