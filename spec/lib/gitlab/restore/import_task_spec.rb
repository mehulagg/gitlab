# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Restore::ImportTask do
  describe '#execute' do
    subject(:service) { described_class.new(params) }

    let_it_be(:user) { create(:user) }

    let_it_be(:valid_file_path) { 'spec/features/import/valid_restore_bundle.tar.gz' }
    let_it_be(:storage_path) { "#{Dir.tmpdir}/restore_spec" }

    before do
      allow_any_instance_of(Gitlab::ImportExport).to receive(:storage_path).and_return(storage_path)
    end

    after do
      FileUtils.rm_rf(storage_path)
    end

    shared_examples_for 'a groups importer' do
      context 'when there is an existing group for the namespace' do
        let(:existing_group) { create(:group, path: group_path) }

        before do
          existing_group.add_owner(user)
        end

        it 'imports the data to the existing namespace' do
          expect { service.execute }
            .to change { existing_group.reload.description }
            .to eq 'A simple group, with sub-groups and projects that can be exported and imported for seed test data.'
        end

        it 'imports the entire group tree' do
          expected_subgroup_paths = %w[
            test-group/carrots
            test-group/bananas
            test-group/apples
            test-group/apples/cypress
            test-group/apples/birch
            test-group/apples/acacia
          ]

          expect { service.execute }
            .to change { Group.groups_including_descendants_by([existing_group.id]).count }
            .by expected_subgroup_paths.size

          expect(Group.where_full_path_in(expected_subgroup_paths).count).to eq expected_subgroup_paths.size
        end
      end

      context 'when there is an existing group that the user does not have permissions for' do
        let(:existing_group) { create(:group, path: group_path) }

        before do
          existing_group.add_guest(user)
        end

        it 'raises an error and does not import anything' do
          expect { service.execute }
            .to change { Group.count + Project.count }
            .by(0)
            .and raise_error(Gitlab::ImportExport::Error, /does not have required permissions/)
        end
      end

      context 'when there is no group at the supplied path' do
        it 'creates a new group at the given path' do
          expect { service.execute }
            .to change { Group.find_by(path: group_path) }
            .to be_present
        end

        it 'imports the entire group tree' do
          expected_group_paths = %w[
            test-group
            test-group/carrots
            test-group/bananas
            test-group/apples
            test-group/apples/cypress
            test-group/apples/birch
            test-group/apples/acacia
          ]

          expect { service.execute }
            .to change { Group.count }
              .by expected_group_paths.size

          expect(Group.where_full_path_in(expected_group_paths).count).to eq expected_group_paths.size
        end
      end
    end

    context 'when the export file does not exist' do
      let(:params) do
        {
          username: 'test',
          export_file: 'invalid/path/to/file.tar.gz',
          group_path: 'test-group',
          import_type: 'all',
          logger: instance_double(Logger)
        }
      end

      it 'raises an error and does not import or create anything' do
        expect { service.execute }
          .to change { Project.count + Group.count }
          .by(0)
          .and raise_error(described_class::Error, 'Bundle invalid/path/to/file.tar.gz does not exist')
      end
    end

    context 'when the user does not exist' do
      let(:params) do
        {
          username: 'not-a-real-user',
          export_file: valid_file_path,
          group_path: 'test-group',
          import_type: 'all',
          logger: instance_double(Logger)
        }
      end

      it 'raises an error and does not create anything' do
        expect { service.execute }
          .to change { Project.count + Group.count }
          .by(0)
          .and raise_error(ActiveRecord::RecordNotFound, /Couldn't find User/)
      end
    end

    context "when supplied the 'all' import type" do
      context 'when supplied valid params' do
        let_it_be(:group_path) { 'test-group' }

        let(:params) do
          {
            username: user.username,
            export_file: valid_file_path,
            group_path: group_path,
            import_type: 'all',
            logger: instance_double(Logger, info: true)
          }
        end

        it 'does not leave behind working files' do
          service.execute

          expect(Dir.exist?(File.join(storage_path, 'test-group-restore'))).to be_falsey
        end

        context 'when the groups are successfully imported' do
          it 'imports the projects at the correct level' do
            expect { service.execute }
              .to change { Project.count }
                .by 3

            expect(Project.find_by_full_path('test-group/acacia').name).to eq 'acacia'
            expect(Project.find_by_full_path('test-group/apples/buffalo').name).to eq 'buffalo'
            expect(Project.find_by_full_path('test-group/apples/cypress/citrine').name).to eq 'citrine'
          end
        end

        it_behaves_like 'a groups importer'
      end

      context 'when the bundle is not valid' do
        let(:params) do
          {
            username: user.username,
            export_file: 'spec/features/import/invalid_group_restore_bundle.tar.gz',
            group_path: 'test-group',
            import_type: 'all',
            logger: instance_double(Logger, info: true)
          }
        end

        it 'raises an error and does not import anything' do
          expect { service.execute }
            .to change { Project.count + Group.count }
            .by(0)
            .and raise_error(described_class::Error, 'Could not find tar.gz file in the root of the bundle')
        end
      end
    end

    context "when supplied the 'group' import type" do
      let_it_be(:group_path) { 'test-group' }

      let(:params) do
        {
          username: user.username,
          export_file: valid_file_path,
          group_path: group_path,
          import_type: 'group',
          logger: instance_double(Logger, info: true)
        }
      end

      it 'does not create any projects' do
        expect { service.execute }
          .not_to change { Project.count }
      end

      it 'does not leave behind working files' do
        service.execute

        expect(Dir.exist?(File.join(storage_path, 'test-group-restore'))).to be_falsey
      end

      it_behaves_like 'a groups importer'
    end

    context "when supplied the 'project' import type" do
      context 'when supplied a valid bundle' do
        let_it_be(:group_path) { 'test-group' }

        let(:params) do
          {
            username: user.username,
            export_file: valid_file_path,
            group_path: group_path,
            import_type: 'project',
            logger: instance_double(Logger, info: true)
          }
        end

        context 'when there is an existing group for the given path' do
          let(:existing_group) { create(:group, path: group_path) }

          before do
            create(:group, path: 'apples', parent: existing_group)

            existing_group.add_owner(user)
          end

          it 'does not create any groups' do
            expect { service.execute }
              .not_to change { Group.count }
          end

          it 'does not leave behind working files' do
            service.execute

            expect(Dir.exist?(File.join(storage_path, 'test-group-restore'))).to be_falsey
          end

          it 'imports the projects that have existing groups' do
            expect { service.execute }
              .to change { Project.count }
              .by 2

            expect(Project.find_by_full_path('test-group/acacia').name).to eq 'acacia'
            expect(Project.find_by_full_path('test-group/apples/buffalo').name).to eq 'buffalo'

            expect(Project.find_by_full_path('test-group/apples/cypress/citrine')).to be_nil
          end
        end
      end

      context 'when the bundle is missing the projects folder' do
        let(:params) do
          {
            username: user.username,
            export_file: 'spec/features/import/invalid_group_restore_bundle.tar.gz',
            group_path: 'test-group',
            import_type: 'project',
            logger: instance_double(Logger, info: true)
          }
        end

        before do
          create(:group, path: 'test-group')
        end

        it 'does not import anything' do
          expect { service.execute }
            .not_to change { Project.count + Group.count }
        end
      end

      context 'when there is no group for the given root path' do
        let(:params) do
          {
            username: user.username,
            export_file: valid_file_path,
            group_path: 'test-group',
            import_type: 'project',
            logger: instance_double(Logger, info: true)
          }
        end

        it 'raises an error and does not import anything' do
          expect { service.execute }
            .to change { Project.count + Group.count }
            .by(0)
            .and raise_error(described_class::Error, /there is no existing group with the path test-group/)
        end
      end
    end

    context 'when supplied an unrecognised import type' do
      let(:params) do
        {
          username: user.username,
          export_file: valid_file_path,
          group_path: 'test-group',
          import_type: 'invalid',
          logger: instance_double(Logger, info: true)
        }
      end

      it 'raises an error and does not import anything' do
        expect { service.execute }
          .to change { Project.count + Group.count }
          .by(0)
          .and raise_error(described_class::Error, 'Unrecognised import_type param')
      end

      it 'does not leave behind working files' do
        expect { service.execute }
          .to raise_error(described_class::Error, 'Unrecognised import_type param')

        expect(Dir.exist?(File.join(storage_path, 'test-group-restore'))).to be_falsey
      end
    end
  end
end
