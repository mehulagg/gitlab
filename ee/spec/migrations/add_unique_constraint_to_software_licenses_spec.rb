# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe AddUniqueConstraintToSoftwareLicenses do
  let(:migration) { described_class.new }
  let(:projects) { table(:projects) }
  let(:licenses) { table(:software_licenses) }
  let(:policies) { table(:software_license_policies) }

  describe "#up" do
    it 'adds a unique constraint to the name column' do
      migrate!

      expect(migration.index_exists?(:software_licenses, :name, unique: true)).to be_truthy
    end

    it 'removes redundant software licenses' do
      project = projects.create!(name: 'project', namespace_id: 1)
      other_project = projects.create!(name: 'project', namespace_id: 1)

      apache = licenses.create!(name: 'Apache 2.0')
      bsd = licenses.create!(name: 'BSD')
      mit = licenses.create!(name: 'MIT')
      mit_duplicate = licenses.create!(name: 'MIT')

      apache_policy = policies.create!(software_license_id: apache.id, project_id: project.id)
      mit_policy = policies.create!(software_license_id: mit.id, project_id: project.id)
      other_mit_policy = policies.create!(software_license_id: mit_duplicate.id, project_id: other_project.id)

      migrate!

      expect(licenses.all).to contain_exactly(apache, bsd, mit)
      expect(policies.all).to contain_exactly(apache_policy, mit_policy, other_mit_policy)

      expect(apache_policy.reload.software_license_id).to eql(apache.id)
      expect(mit_policy.reload.software_license_id).to eql(mit.id)
      expect(other_mit_policy.reload.software_license_id).to eql(mit.id)
      expect { mit_duplicate.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when a duplicate record is inserted before adding the unique index" do
      let!(:mit) { licenses.create!(name: 'MIT') }
      let!(:mit_duplicate) { licenses.create!(name: 'MIT') }
      let!(:original_method) { migration.method(:remove_redundant_software_licenses!) }

      before do
        call_count = 0
        allow(migration).to receive(:remove_redundant_software_licenses!) do |_|
          call_count += 1
          if call_count.odd?
            raise ActiveRecord::RecordNotUnique
          else
            original_method.call
          end
        end

        migration.up(attempts: 2)
      end

      after do
        migration.down
      end

      it { expect(licenses.all).to contain_exactly(mit) }
    end
  end

  describe "#down" do
    it 'correctly migrates up and down' do
      reversible_migration do |x|
        x.before -> { expect(migration.index_exists?(:software_licenses, :name, unique: true)).to be_falsey }
        x.after -> { expect(migration.index_exists?(:software_licenses, :name, unique: true)).to be_truthy }
      end
    end
  end
end
