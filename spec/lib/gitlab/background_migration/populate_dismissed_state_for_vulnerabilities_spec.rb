# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Gitlab::BackgroundMigration::PopulateDismissedStateForVulnerabilities, schema: 2020_11_30_103926 do
  describe '#perform' do
    let_it_be(:users) { table(:users) }
    let_it_be(:namespaces) { table(:namespaces) }
    let_it_be(:projects) { table(:projects) }
    let_it_be(:vulnerabilities) { table(:vulnerabilities) }

    let_it_be(:namespace) { namespaces.create!(name: "foo", path: "bar") }
    let_it_be(:user) { users.create!(name: 'John Doe', email: 'test@example.com', projects_limit: 5) }
    let_it_be(:project) { projects.create!(namespace_id: namespace.id) }
    let_it_be(:vulnerability_params) do
      {
        project_id: project.id,
        author_id: user.id,
        title: 'Vulnerability',
        severity: 5,
        confidence: 5,
        report_type: 5
      }
    end

    let_it_be(:vulnerability_1) { vulnerabilities.create!(vulnerability_params.merge(state: 1)) }
    let_it_be(:vulnerability_2) { vulnerabilities.create!(vulnerability_params.merge(state: 3)) }

    it 'changes state of vulnerability to dismissed' do
      subject.perform([vulnerability_1.id, vulnerability_2.id])

      expect(vulnerability_1.reload.state).to eq(2)
      expect(vulnerability_2.reload.state).to eq(2)
    end

    it 'populates missing dismissal information' do
      expect_next_instance_of(::Gitlab::BackgroundMigration::PopulateMissingVulnerabilityDismissalInformation) do |migration|
        expect(migration).to receive(:perform).with(vulnerability_1.id, vulnerability_2.id)
      end

      subject.perform([vulnerability_1.id, vulnerability_2.id])
    end
  end
end
