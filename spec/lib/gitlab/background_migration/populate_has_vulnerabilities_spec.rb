# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::PopulateHasVulnerabilities, schema: 20201103192526 do
  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:project_settings) { table(:project_settings) }

  let(:user) { users.create!(name: 'test', email: 'test@example.com', projects_limit: 5) }
  let(:namespace) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }
  let(:project_1) { projects.create!(namespace_id: namespace.id, name: 'foo_1') }
  let(:project_2) { projects.create!(namespace_id: namespace.id, name: 'foo_2') }

  before do
    project_settings.create!(project_id: project_1.id)

    allow(::Gitlab::BackgroundMigration::Logger).to receive_messages(info: true, error: true)
  end

  describe '#perform' do
    it 'sets `has_vulnerabilities` attribute of project_settings' do
      expect { subject.perform(project_1.id, project_2.id) }.to change { project_settings.count }.from(1).to(2)
                                                            .and change { project_settings.where(has_vulnerabilities: true).count }.from(0).to(2)
    end

    it 'writes info log message' do
      subject.perform(project_1.id, project_2.id)

      expect(::Gitlab::BackgroundMigration::Logger).to have_received(:info)
    end

    context 'when an error happens' do
      before do
        allow_next_found_instance_of(described_class::ProjectSetting) do |project_setting|
          allow(project_setting).to receive(:update!).and_raise('foo')
        end
      end

      it 'does not entirely crash' do
        expect { subject.perform(project_1.id, project_2.id) }.to change { project_settings.where(has_vulnerabilities: true).count }.from(0).to(1)
      end

      it 'writes error log message' do
        subject.perform(project_1.id, project_2.id)

        expect(::Gitlab::BackgroundMigration::Logger).to have_received(:error)
      end
    end
  end
end
