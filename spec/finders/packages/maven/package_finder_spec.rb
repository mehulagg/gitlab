# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Packages::Maven::PackageFinder do
  let_it_be(:user)    { create(:user) }
  let_it_be(:group)   { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:package) { create(:maven_package, project: project) }

  let(:param_path) { nil }
  let(:param_project) { nil }
  let(:param_group) { nil }
  let(:param_order_by_package_file) { false }
  let(:finder) { described_class.new(param_path, user, project: param_project, group: param_group, order_by_package_file: param_order_by_package_file) }

  before do
    group.add_developer(user)
  end

  shared_examples 'Packages::Maven::PackageFinder examples' do
    describe '#execute!' do
      subject { finder.execute! }

      shared_examples 'handling valid and invalid paths' do
        context 'with a valid path' do
          let(:param_path) { package.maven_metadatum.path }

          it { is_expected.to eq(package) }
        end

        context 'with an invalid path' do
          let(:param_path) { 'com/example/my-app/1.0-SNAPSHOT' }

          it 'raises an error' do
            expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end

      context 'within the project' do
        let(:param_project) { project }

        it_behaves_like 'handling valid and invalid paths'
      end

      context 'within a group' do
        let(:param_group) { group }

        context 'with maven_packages_group_level_improvements enabled' do
          before do
            stub_feature_flags(maven_packages_group_level_improvements: true)
            expect(finder).to receive(:packages_visible_to_user).with(user, within_group: group).and_call_original
          end

          it_behaves_like 'handling valid and invalid paths'
        end

        context 'with maven_packages_group_level_improvements disabled' do
          before do
            stub_feature_flags(maven_packages_group_level_improvements: false)
            expect(finder).not_to receive(:packages_visible_to_user)
          end

          it_behaves_like 'handling valid and invalid paths'
        end
      end

      context 'across all projects' do
        it 'raises an error' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'versionless maven-metadata.xml package' do
        let_it_be(:sub_group1) { create(:group, parent: group) }
        let_it_be(:sub_group2)   { create(:group, parent: group) }
        let_it_be(:project1) { create(:project, group: sub_group1) }
        let_it_be(:project2) { create(:project, group: sub_group2) }
        let_it_be(:project3) { create(:project, group: sub_group1) }
        let_it_be(:package_name) { 'foo' }
        let_it_be(:package1) { create(:maven_package, project: project1, name: package_name, version: nil) }
        let_it_be(:package2) { create(:maven_package, project: project2, name: package_name, version: nil) }
        let_it_be(:package3) { create(:maven_package, project: project3, name: package_name, version: nil) }

        let(:param_group) { group }
        let(:param_path) { package_name }

        before do
          sub_group1.add_developer(user)
          sub_group2.add_developer(user)
          # the package with the most recently published file should be returned
          create(:package_file, :xml, package: package2)
        end

        context 'with maven_packages_group_level_improvements enabled' do
          before do
            stub_feature_flags(maven_packages_group_level_improvements: true)
            expect(finder).not_to receive(:versionless_package?)
          end

          context 'without order by package file' do
            it { is_expected.to eq(package3) }
          end

          context 'with order by package file' do
            let(:param_order_by_package_file) { true }

            it { is_expected.to eq(package2) }
          end
        end

        context 'with maven_packages_group_level_improvements disabled' do
          before do
            stub_feature_flags(maven_packages_group_level_improvements: false)
            expect(finder).to receive(:versionless_package?).and_call_original
          end

          context 'without order by package file' do
            it { is_expected.to eq(package2) }
          end

          context 'with order by package file' do
            let(:param_order_by_package_file) { true }

            it { is_expected.to eq(package2) }
          end
        end
      end
    end
  end

  context 'when the maven_metadata_by_path_with_optimization_fence feature flag is off' do
    before do
      stub_feature_flags(maven_metadata_by_path_with_optimization_fence: false)
    end

    it_behaves_like 'Packages::Maven::PackageFinder examples'
  end

  context 'when the maven_metadata_by_path_with_optimization_fence feature flag is on' do
    before do
      stub_feature_flags(maven_metadata_by_path_with_optimization_fence: true)
    end

    it_behaves_like 'Packages::Maven::PackageFinder examples'

    it 'uses CTE in the query' do
      sql = described_class.new('some_path', user, group: group).send(:packages_with_path).to_sql

      expect(sql).to include('WITH "maven_metadata_by_path" AS')
    end
  end
end
