# frozen_string_literal: true

require 'spec_helper'

describe Project do
  include ProjectForksHelper
  include ::EE::GeoHelpers
  using RSpec::Parameterized::TableSyntax

  describe 'associations' do
    it { is_expected.to delegate_method(:shared_runners_minutes).to(:statistics) }
    it { is_expected.to delegate_method(:shared_runners_seconds).to(:statistics) }
    it { is_expected.to delegate_method(:shared_runners_seconds_last_reset).to(:statistics) }

    it { is_expected.to delegate_method(:actual_shared_runners_minutes_limit).to(:shared_runners_limit_namespace) }
    it { is_expected.to delegate_method(:shared_runners_minutes_limit_enabled?).to(:shared_runners_limit_namespace) }
    it { is_expected.to delegate_method(:shared_runners_minutes_used?).to(:shared_runners_limit_namespace) }

    it { is_expected.to have_one(:import_state).class_name('ProjectImportState') }
    it { is_expected.to have_one(:repository_state).class_name('ProjectRepositoryState').inverse_of(:project) }
    it { is_expected.to have_one(:alerting_setting).class_name('Alerting::ProjectAlertingSetting') }

    it { is_expected.to have_many(:reviews).inverse_of(:project) }
    it { is_expected.to have_many(:path_locks) }
    it { is_expected.to have_many(:vulnerability_feedback) }
    it { is_expected.to have_many(:sourced_pipelines) }
    it { is_expected.to have_many(:source_pipelines) }
    it { is_expected.to have_many(:audit_events).dependent(false) }
    it { is_expected.to have_many(:protected_environments) }
    it { is_expected.to have_many(:approvers).dependent(:destroy) }
    it { is_expected.to have_many(:approver_users).through(:approvers) }
    it { is_expected.to have_many(:approver_groups).dependent(:destroy) }
    it { is_expected.to have_many(:packages).class_name('Packages::Package') }
    it { is_expected.to have_many(:package_files).class_name('Packages::PackageFile') }

    it { is_expected.to have_one(:github_service) }
    it { is_expected.to have_many(:project_aliases) }
  end

  context 'scopes' do
    describe '.requiring_code_owner_approval' do
      it 'only includes the right projects' do
        create(:project)
        expected_project = create(:project, merge_requests_require_code_owner_approval: true)

        expect(described_class.requiring_code_owner_approval).to contain_exactly(expected_project)
      end
    end

    describe '.with_wiki_enabled' do
      it 'returns a project' do
        project = create(:project_empty_repo, wiki_access_level: ProjectFeature::ENABLED)
        project1 = create(:project, wiki_access_level: ProjectFeature::DISABLED)

        expect(described_class.with_wiki_enabled).to include(project)
        expect(described_class.with_wiki_enabled).not_to include(project1)
      end
    end
  end

  describe 'validations' do
    let(:project) { build(:project) }

    describe 'variables' do
      let(:first_variable) { build(:ci_variable, key: 'test_key', value: 'first', environment_scope: 'prod', project: project) }
      let(:second_variable) { build(:ci_variable, key: 'test_key', value: 'other', environment_scope: 'other', project: project) }

      before do
        project.variables << first_variable
        project.variables << second_variable
      end

      context 'with duplicate variables with same environment scope' do
        before do
          project.variables.last.environment_scope = project.variables.first.environment_scope
        end

        it { expect(project).not_to be_valid }
      end

      context 'with same variable keys and different environment scope' do
        it { expect(project).to be_valid }
      end
    end

    context '#mark_stuck_remote_mirrors_as_failed!' do
      it 'fails stuck remote mirrors' do
        project = create(:project, :repository, :remote_mirror)

        project.remote_mirrors.first.update(
          update_status: :started,
          last_update_at: 2.days.ago
        )

        expect do
          project.mark_stuck_remote_mirrors_as_failed!
        end.to change { project.remote_mirrors.stuck.count }.from(1).to(0)
      end
    end

    context 'mirror' do
      subject { build(:project, mirror: true) }

      it { is_expected.to validate_presence_of(:import_url) }
      it { is_expected.to validate_presence_of(:mirror_user) }
    end

    it 'creates import state when mirror gets enabled' do
      project2 = create(:project)

      expect do
        project2.update(mirror: true, import_url: generate(:url), mirror_user: project.creator)
      end.to change { ProjectImportState.where(project: project2).count }.from(0).to(1)
    end
  end

  describe 'setting up a mirror' do
    context 'when new project' do
      it 'creates import_state and sets next_execution_timestamp to now' do
        project = build(:project, :mirror)

        Timecop.freeze do
          expect do
            project.save
          end.to change { ProjectImportState.count }.by(1)

          expect(project.import_state.next_execution_timestamp).to be_like_time(Time.now)
        end
      end
    end

    context 'when project already exists' do
      context 'when project is not import' do
        it 'creates import_state and sets next_execution_timestamp to now' do
          project = create(:project)

          Timecop.freeze do
            expect do
              project.update(mirror: true, mirror_user_id: project.creator.id, import_url: generate(:url))
            end.to change { ProjectImportState.count }.by(1)

            expect(project.import_state.next_execution_timestamp).to be_like_time(Time.now)
          end
        end
      end

      context 'when project is import' do
        it 'sets current import_state next_execution_timestamp to now' do
          project = create(:project, import_url: generate(:url))

          Timecop.freeze do
            expect do
              project.update(mirror: true, mirror_user_id: project.creator.id)
            end.not_to change { ProjectImportState.count }

            expect(project.import_state.next_execution_timestamp).to be_like_time(Time.now)
          end
        end
      end
    end
  end

  describe '.mirrors_to_sync' do
    let(:timestamp) { Time.now }

    context 'when mirror is scheduled' do
      it 'returns empty' do
        create(:project, :mirror, :import_scheduled)

        expect(described_class.mirrors_to_sync(timestamp)).to be_empty
      end
    end

    context 'when mirror is started' do
      it 'returns empty' do
        create(:project, :mirror, :import_scheduled)

        expect(described_class.mirrors_to_sync(timestamp)).to be_empty
      end
    end

    context 'when mirror is finished' do
      let!(:project) { create(:project) }
      let!(:import_state) { create(:import_state, :mirror, :finished, project: project) }

      it 'returns project if next_execution_timestamp is not in the future' do
        expect(described_class.mirrors_to_sync(timestamp)).to match_array(project)
      end

      it 'returns empty if next_execution_timestamp is in the future' do
        import_state.update(next_execution_timestamp: timestamp + 2.minutes)

        expect(described_class.mirrors_to_sync(timestamp)).to be_empty
      end

      context 'when a limit is applied' do
        before do
          another_project = create(:project)
          create(:import_state, :mirror, :finished, project: another_project)
        end

        it 'returns project if next_execution_timestamp is not in the future' do
          expect(described_class.mirrors_to_sync(timestamp, limit: 1)).to match_array(project)
        end
      end
    end

    context 'when project is failed' do
      let!(:project) { create(:project, :mirror, :import_failed) }

      it 'returns project if next_execution_timestamp is not in the future' do
        expect(described_class.mirrors_to_sync(timestamp)).to match_array(project)
      end

      it 'returns empty if next_execution_timestamp is in the future' do
        project.import_state.update(next_execution_timestamp: timestamp + 2.minutes)

        expect(described_class.mirrors_to_sync(timestamp)).to be_empty
      end

      context 'with retry limit exceeded' do
        let!(:project) { create(:project, :mirror, :import_hard_failed) }

        it 'returns empty' do
          expect(described_class.mirrors_to_sync(timestamp)).to be_empty
        end
      end
    end
  end

  describe '#deployment_variables' do
    context 'when project has a deployment platforms' do
      context 'when multiple clusters (EEP) is enabled' do
        before do
          stub_licensed_features(multiple_clusters: true)
        end

        let(:project) { create(:project) }

        let!(:default_cluster) do
          create(:cluster,
                 :not_managed,
                 platform_type: :kubernetes,
                 projects: [project],
                 environment_scope: '*',
                 platform_kubernetes: default_cluster_kubernetes)
        end

        let!(:review_env_cluster) do
          create(:cluster,
                 :not_managed,
                 platform_type: :kubernetes,
                 projects: [project],
                 environment_scope: 'review/*',
                 platform_kubernetes: review_env_cluster_kubernetes)
        end

        let(:default_cluster_kubernetes) { create(:cluster_platform_kubernetes, token: 'default-AAA') }
        let(:review_env_cluster_kubernetes) { create(:cluster_platform_kubernetes, token: 'review-AAA') }

        context 'when environment name is review/name' do
          let!(:environment) { create(:environment, project: project, name: 'review/name') }

          it 'returns variables from this service' do
            expect(project.deployment_variables(environment: 'review/name'))
              .to include(key: 'KUBE_TOKEN', value: 'review-AAA', public: false, masked: true)
          end
        end

        context 'when environment name is other' do
          let!(:environment) { create(:environment, project: project, name: 'staging/name') }

          it 'returns variables from this service' do
            expect(project.deployment_variables(environment: 'staging/name'))
              .to include(key: 'KUBE_TOKEN', value: 'default-AAA', public: false, masked: true)
          end
        end
      end
    end
  end

  describe '#environments_for_scope' do
    set(:project) { create(:project) }

    before do
      create_list(:environment, 2, project: project)
    end

    it 'retrieves all project environments when using the * wildcard' do
      expect(project.environments_for_scope("*")).to eq(project.environments)
    end

    it 'retrieves a specific project environment when using the name of that environment' do
      environment = project.environments.first

      expect(project.environments_for_scope(environment.name)).to eq([environment])
    end
  end

  describe '#ensure_external_webhook_token' do
    let(:project) { create(:project, :repository) }

    it "sets external_webhook_token when it's missing" do
      project.update_attribute(:external_webhook_token, nil)
      expect(project.external_webhook_token).to be_blank

      project.ensure_external_webhook_token
      expect(project.external_webhook_token).to be_present
    end
  end

  describe '#push_rule' do
    let(:project) { create(:project, push_rule: create(:push_rule)) }

    subject(:push_rule) { project.reload_push_rule }

    it { is_expected.not_to be_nil }

    context 'push rules unlicensed' do
      before do
        stub_licensed_features(push_rules: false)
      end

      it { is_expected.to be_nil }
    end
  end

  describe "#execute_hooks" do
    context "group hooks" do
      let(:group) { create(:group) }
      let(:project) { create(:project, namespace: group) }
      let(:group_hook) { create(:group_hook, group: group, push_events: true) }

      it 'executes the hook when the feature is enabled' do
        stub_licensed_features(group_webhooks: true)

        fake_service = double
        expect(WebHookService).to receive(:new)
                                    .with(group_hook, { some: 'info' }, 'push_hooks') { fake_service }
        expect(fake_service).to receive(:async_execute)

        project.execute_hooks(some: 'info')
      end

      it 'does not execute the hook when the feature is disabled' do
        stub_licensed_features(group_webhooks: false)

        expect(WebHookService).not_to receive(:new)
                                        .with(group_hook, { some: 'info' }, 'push_hooks')

        project.execute_hooks(some: 'info')
      end
    end
  end

  describe '#execute_hooks' do
    it "triggers project and group hooks" do
      group = create :group, name: 'gitlab'
      project = create(:project, name: 'gitlabhq', namespace: group)
      project_hook = create(:project_hook, push_events: true, project: project)
      group_hook = create(:group_hook, push_events: true, group: group)

      stub_request(:post, project_hook.url)
      stub_request(:post, group_hook.url)

      expect_any_instance_of(GroupHook).to receive(:async_execute).and_return(true)
      expect_any_instance_of(ProjectHook).to receive(:async_execute).and_return(true)

      project.execute_hooks({}, :push_hooks)
    end
  end

  describe '#allowed_to_share_with_group?' do
    let(:project) { create(:project) }

    it "returns true" do
      expect(project.allowed_to_share_with_group?).to be_truthy
    end

    it "returns false" do
      project.namespace.update(share_with_group_lock: true)
      expect(project.allowed_to_share_with_group?).to be_falsey
    end
  end

  describe '#beta_feature_available?' do
    it_behaves_like 'an entity with beta feature support' do
      let(:entity) { create(:project) }
    end
  end

  describe '#feature_available?' do
    let(:namespace) { build(:namespace) }
    let(:plan_license) { nil }
    let(:project) { build(:project, namespace: namespace) }
    let(:user) { build(:user) }

    subject { project.feature_available?(feature, user) }

    context 'when feature symbol is included on Namespace features code' do
      before do
        stub_application_setting('check_namespace_plan?' => check_namespace_plan)
        allow(Gitlab).to receive(:com?) { true }
        stub_licensed_features(feature => allowed_on_global_license)
        allow(namespace).to receive(:plan) { plan_license }
      end

      License::EEU_FEATURES.each do |feature_sym|
        let(:feature) { feature_sym }

        context feature_sym.to_s do
          unless License::GLOBAL_FEATURES.include?(feature_sym)
            context "checking #{feature_sym} availability both on Global and Namespace license" do
              let(:check_namespace_plan) { true }

              context 'allowed by Plan License AND Global License' do
                let(:allowed_on_global_license) { true }
                let(:plan_license) { build(:gold_plan) }

                before do
                  allow(namespace).to receive(:plans) { [plan_license] }
                end

                it 'returns true' do
                  is_expected.to eq(true)
                end

                context 'when feature is disabled by a feature flag' do
                  it 'returns false' do
                    stub_feature_flags(feature => false)

                    is_expected.to eq(false)
                  end
                end
              end

              context 'not allowed by Plan License but project and namespace are public' do
                let(:allowed_on_global_license) { true }
                let(:plan_license) { build(:bronze_plan) }

                it 'returns true' do
                  allow(namespace).to receive(:public?) { true }
                  allow(project).to receive(:public?) { true }

                  is_expected.to eq(true)
                end
              end

              unless License.plan_includes_feature?(License::STARTER_PLAN, feature_sym)
                context 'not allowed by Plan License' do
                  let(:allowed_on_global_license) { true }
                  let(:plan_license) { build(:bronze_plan) }

                  it 'returns false' do
                    is_expected.to eq(false)
                  end
                end
              end

              context 'not allowed by Global License' do
                let(:allowed_on_global_license) { false }
                let(:plan_license) { build(:gold_plan) }

                it 'returns false' do
                  is_expected.to eq(false)
                end
              end
            end
          end

          context "when checking #{feature_sym} only for Global license" do
            let(:check_namespace_plan) { false }

            context 'allowed by Global License' do
              let(:allowed_on_global_license) { true }

              it 'returns true' do
                is_expected.to eq(true)
              end
            end

            context 'not allowed by Global License' do
              let(:allowed_on_global_license) { false }

              it 'returns false' do
                is_expected.to eq(false)
              end
            end
          end
        end
      end
    end

    it 'only loads licensed availability once' do
      expect(project).to receive(:load_licensed_feature_available)
                             .once.and_call_original

      2.times { project.feature_available?(:service_desk) }
    end

    context 'when feature symbol is not included on Namespace features code' do
      let(:feature) { :issues }

      it 'checks availability of licensed feature' do
        expect(project.project_feature).to receive(:feature_available?).with(feature, user)

        subject
      end
    end
  end

  describe '#fetch_mirror' do
    where(:import_url, :auth_method, :expected) do
      'http://foo:bar@example.com' | 'password'       | 'http://foo:bar@example.com'
      'ssh://foo:bar@example.com'  | 'password'       | 'ssh://foo:bar@example.com'
      'ssh://foo:bar@example.com'  | 'ssh_public_key' | 'ssh://foo@example.com'
    end

    with_them do
      let(:project) { build(:project, :mirror, import_url: import_url, import_data_attributes: { auth_method: auth_method } ) }

      it do
        expect(project.repository).to receive(:fetch_upstream).with(expected, forced: false)

        project.fetch_mirror
      end
    end
  end

  describe 'updating import_url' do
    it 'removes previous remote' do
      project = create(:project, :repository, :mirror)

      expect(RepositoryRemoveRemoteWorker).to receive(:perform_async).with(project.id, ::Repository::MIRROR_REMOTE).and_call_original

      project.update(import_url: "http://test.com")
    end
  end

  describe '#any_runners_limit' do
    let(:project) { create(:project, shared_runners_enabled: shared_runners_enabled) }
    let(:specific_runner) { create(:ci_runner, :project) }
    let(:shared_runner) { create(:ci_runner, :instance) }

    context 'for shared runners enabled' do
      let(:shared_runners_enabled) { true }

      before do
        shared_runner
      end

      it 'has a shared runner' do
        expect(project.any_runners?).to be_truthy
      end

      it 'checks the presence of shared runner' do
        expect(project.any_runners? { |runner| runner == shared_runner }).to be_truthy
      end

      context 'with used pipeline minutes' do
        let(:namespace) { create(:namespace, :with_used_build_minutes_limit) }
        let(:project) do
          create(:project,
            namespace: namespace,
            shared_runners_enabled: shared_runners_enabled)
        end

        it 'does not have a shared runner' do
          expect(project.any_runners?).to be_falsey
        end
      end
    end
  end

  describe '#shared_runners_available?' do
    subject { project.shared_runners_available? }

    context 'with used pipeline minutes' do
      let(:namespace) { create(:namespace, :with_used_build_minutes_limit) }
      let(:project) do
        create(:project,
          namespace: namespace,
          shared_runners_enabled: true)
      end

      before do
        expect(namespace).to receive(:shared_runners_minutes_used?).and_call_original
      end

      it 'shared runners are not available' do
        expect(project.shared_runners_available?).to be_falsey
      end
    end
  end

  describe '#root_namespace' do
    let(:project) { build(:project, namespace: parent) }

    subject { project.root_namespace }

    context 'when namespace has parent group', :nested_groups do
      let(:root_ancestor) { create(:group) }
      let(:parent) { create(:group, parent: root_ancestor) }

      it 'returns root ancestor' do
        is_expected.to eq(root_ancestor)
      end
    end

    context 'when namespace is root ancestor' do
      let(:parent) { create(:group) }

      it 'returns current namespace' do
        is_expected.to eq(parent)
      end
    end
  end

  describe '#shared_runners_limit_namespace', :nested_groups do
    set(:root_ancestor) { create(:group) }
    set(:group) { create(:group, parent: root_ancestor) }
    let(:project) { create(:project, namespace: group) }

    subject { project.shared_runners_limit_namespace }

    it 'returns root namespace' do
      is_expected.to eq(root_ancestor)
    end
  end

  describe '#shared_runners_minutes_limit_enabled?' do
    let(:project) { create(:project) }

    subject { project.shared_runners_minutes_limit_enabled? }

    before do
      allow(project.namespace).to receive(:shared_runners_minutes_limit_enabled?)
        .and_return(true)
    end

    context 'with shared runners enabled' do
      before do
        project.shared_runners_enabled = true
      end

      context 'for public project' do
        before do
          project.visibility_level = Project::PUBLIC
        end

        it { is_expected.to be_falsey }
      end

      context 'for internal project' do
        before do
          project.visibility_level = Project::INTERNAL
        end

        it { is_expected.to be_truthy }
      end

      context 'for private project' do
        before do
          project.visibility_level = Project::INTERNAL
        end

        it { is_expected.to be_truthy }
      end
    end

    context 'without shared runners' do
      before do
        project.shared_runners_enabled = false
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '#size_limit_enabled?' do
    let(:project) { create(:project) }

    context 'when repository_size_limit is not configured' do
      it 'is disabled' do
        expect(project.size_limit_enabled?).to be_falsey
      end
    end

    context 'when repository_size_limit is configured' do
      before do
        project.update(repository_size_limit: 1024)
      end

      context 'with an EES license' do
        let!(:license) { create(:license, plan: License::STARTER_PLAN) }

        it 'is enabled' do
          expect(project.size_limit_enabled?).to be_truthy
        end
      end

      context 'with an EEP license' do
        let!(:license) { create(:license, plan: License::PREMIUM_PLAN) }

        it 'is enabled' do
          expect(project.size_limit_enabled?).to be_truthy
        end
      end

      context 'without a License' do
        before do
          License.destroy_all # rubocop: disable DestroyAll
        end

        it 'is disabled' do
          expect(project.size_limit_enabled?).to be_falsey
        end
      end
    end
  end

  describe '#service_desk_enabled?' do
    let!(:license) { create(:license, plan: License::PREMIUM_PLAN) }
    let(:namespace) { create(:namespace) }

    subject(:project) { build(:project, :private, namespace: namespace, service_desk_enabled: true) }

    before do
      allow(::Gitlab).to receive(:com?).and_return(true)
      allow(::Gitlab::IncomingEmail).to receive(:enabled?).and_return(true)
      allow(::Gitlab::IncomingEmail).to receive(:supports_wildcard?).and_return(true)
    end

    it 'is enabled' do
      expect(project.service_desk_enabled?).to be_truthy
      expect(project.service_desk_enabled).to be_truthy
    end

    context 'namespace plans active' do
      before do
        stub_application_setting(check_namespace_plan: true)
      end

      it 'is disabled' do
        expect(project.service_desk_enabled?).to be_falsy
        expect(project.service_desk_enabled).to be_falsy
      end

      context 'Service Desk available in namespace plan' do
        let!(:gitlab_subscription) { create(:gitlab_subscription, :silver, namespace: namespace) }

        it 'is enabled' do
          expect(project.service_desk_enabled?).to be_truthy
          expect(project.service_desk_enabled).to be_truthy
        end
      end
    end
  end

  describe '#service_desk_address' do
    let(:project) { create(:project, service_desk_enabled: true) }

    before do
      allow(::EE::Gitlab::ServiceDesk).to receive(:enabled?).and_return(true)
      allow(Gitlab.config.incoming_email).to receive(:enabled).and_return(true)
      allow(Gitlab.config.incoming_email).to receive(:address).and_return("test+%{key}@mail.com")
    end

    it 'uses project full path as service desk address key' do
      expect(project.service_desk_address).to eq("test+#{project.full_path_slug}-#{project.project_id}-issue-@mail.com")
    end
  end

  describe '#ci_variables_for' do
    let(:project) { create(:project) }

    let!(:ci_variable) do
      create(:ci_variable, value: 'secret', project: project)
    end

    let!(:protected_variable) do
      create(:ci_variable, :protected, value: 'protected', project: project)
    end

    subject { project.ci_variables_for(ref: 'ref') }

    before do
      stub_application_setting(
        default_branch_protection: Gitlab::Access::PROTECTION_NONE)
    end

    context 'when environment name is specified' do
      let(:environment) { 'review/name' }

      subject do
        project.ci_variables_for(ref: 'ref', environment: environment)
      end

      shared_examples 'matching environment scope' do
        context 'when variable environment scope is available' do
          before do
            stub_licensed_features(variable_environment_scope: true)
          end

          it 'contains the ci variable' do
            is_expected.to contain_exactly(ci_variable)
          end
        end

        context 'when variable environment scope is unavailable' do
          before do
            stub_licensed_features(variable_environment_scope: false)
          end

          it 'does not contain the ci variable' do
            is_expected.not_to contain_exactly(ci_variable)
          end
        end
      end

      shared_examples 'not matching environment scope' do
        context 'when variable environment scope is available' do
          before do
            stub_licensed_features(variable_environment_scope: true)
          end

          it 'does not contain the ci variable' do
            is_expected.not_to contain_exactly(ci_variable)
          end
        end

        context 'when variable environment scope is unavailable' do
          before do
            stub_licensed_features(variable_environment_scope: false)
          end

          it 'does not contain the ci variable' do
            is_expected.not_to contain_exactly(ci_variable)
          end
        end
      end

      context 'when environment scope is exactly matched' do
        before do
          ci_variable.update(environment_scope: 'review/name')
        end

        it_behaves_like 'matching environment scope'
      end

      context 'when environment scope is matched by wildcard' do
        before do
          ci_variable.update(environment_scope: 'review/*')
        end

        it_behaves_like 'matching environment scope'
      end

      context 'when environment scope does not match' do
        before do
          ci_variable.update(environment_scope: 'review/*/special')
        end

        it_behaves_like 'not matching environment scope'
      end

      context 'when environment scope has _' do
        before do
          stub_licensed_features(variable_environment_scope: true)
        end

        it 'does not treat it as wildcard' do
          ci_variable.update(environment_scope: '*_*')

          is_expected.not_to contain_exactly(ci_variable)
        end

        context 'when environment name contains underscore' do
          let(:environment) { 'foo_bar/test' }

          it 'matches literally for _' do
            ci_variable.update(environment_scope: 'foo_bar/*')

            is_expected.to contain_exactly(ci_variable)
          end
        end
      end

      # The environment name and scope cannot have % at the moment,
      # but we're considering relaxing it and we should also make sure
      # it doesn't break in case some data sneaked in somehow as we're
      # not checking this integrity in database level.
      context 'when environment scope has %' do
        before do
          stub_licensed_features(variable_environment_scope: true)
        end

        it 'does not treat it as wildcard' do
          ci_variable.update_attribute(:environment_scope, '*%*')

          is_expected.not_to contain_exactly(ci_variable)
        end

        context 'when environment name contains a percent' do
          let(:environment) { 'foo%bar/test' }

          it 'matches literally for _' do
            ci_variable.update(environment_scope: 'foo%bar/*')

            is_expected.to contain_exactly(ci_variable)
          end
        end
      end

      context 'when variables with the same name have different environment scopes' do
        let!(:partially_matched_variable) do
          create(:ci_variable,
                 key: ci_variable.key,
                 value: 'partial',
                 environment_scope: 'review/*',
                 project: project)
        end

        let!(:perfectly_matched_variable) do
          create(:ci_variable,
                 key: ci_variable.key,
                 value: 'prefect',
                 environment_scope: 'review/name',
                 project: project)
        end

        before do
          stub_licensed_features(variable_environment_scope: true)
        end

        it 'puts variables matching environment scope more in the end' do
          is_expected.to eq(
            [ci_variable,
             partially_matched_variable,
             perfectly_matched_variable])
        end
      end
    end
  end

  describe '#approvals_before_merge' do
    where(:license_value, :db_value, :expected) do
      true  | 5 | 5
      true  | 0 | 0
      false | 5 | 0
      false | 0 | 0
    end

    with_them do
      let(:project) { build(:project, approvals_before_merge: db_value) }

      subject { project.approvals_before_merge }

      before do
        stub_licensed_features(merge_request_approvers: license_value)
      end

      it { is_expected.to eq(expected) }
    end
  end

  describe "#reset_approvals_on_push?" do
    where(:license_value, :db_value, :expected) do
      true  | true  | true
      true  | false | false
      false | true  | false
      false | false | false
    end

    with_them do
      let(:project) { build(:project, reset_approvals_on_push: db_value) }

      subject { project.reset_approvals_on_push? }

      before do
        stub_licensed_features(merge_request_approvers: license_value)
      end

      it { is_expected.to eq(expected) }
    end
  end

  describe '#approvals_before_merge' do
    where(:license_value, :db_value, :expected) do
      true  | 5 | 5
      true  | 0 | 0
      false | 5 | 0
      false | 0 | 0
    end

    with_them do
      let(:project) { build(:project, approvals_before_merge: db_value) }

      subject { project.approvals_before_merge }

      before do
        stub_licensed_features(merge_request_approvers: license_value)
      end

      it { is_expected.to eq(expected) }
    end
  end

  describe '#visible_regular_approval_rules' do
    let(:project) { create(:project) }
    let!(:approval_rules) { create_list(:approval_project_rule, 2, project: project) }

    before do
      stub_licensed_features(multiple_approval_rules: true)
    end

    it 'returns all approval rules' do
      expect(project.visible_regular_approval_rules).to contain_exactly(*approval_rules)
    end

    context 'when multiple approval rules is not available' do
      before do
        stub_licensed_features(multiple_approval_rules: false)
      end

      it 'returns the first approval rule' do
        expect(project.visible_regular_approval_rules).to contain_exactly(approval_rules.first)
      end
    end
  end

  describe '#min_fallback_approvals' do
    let(:project) { create(:project, approvals_before_merge: 1) }

    it 'returns approvals before merge if there are no rules' do
      expect(project.min_fallback_approvals).to eq(1)
    end

    context 'when approval rules are present' do
      before do
        create(:approval_project_rule, project: project, approvals_required: 2)
        create(:approval_project_rule, project: project, approvals_required: 3)

        stub_licensed_features(multiple_approval_rules: true)
      end

      it 'returns the maximum requirement' do
        expect(project.min_fallback_approvals).to eq(3)
      end

      it 'returns the first rule requirement if there is a rule' do
        stub_licensed_features(multiple_approval_rules: false)

        expect(project.min_fallback_approvals).to eq(2)
      end
    end
  end

  describe '#merge_requests_require_code_owner_approval?' do
    let(:project) { build(:project) }

    where(:feature_available, :feature_enabled, :approval_required) do
      true  | true  | true
      false | true  | false
      true  | false | false
      true  | nil   | false
    end

    with_them do
      before do
        stub_licensed_features(code_owner_approval_required: feature_available)
        project.merge_requests_require_code_owner_approval = feature_enabled
      end

      it 'requires code owner approval when needed' do
        expect(project.merge_requests_require_code_owner_approval?).to eq(approval_required)
      end
    end
  end

  shared_examples 'project with disabled services' do
    it 'has some disabled services' do
      stub_const('License::ANY_PLAN_FEATURES', [])

      expect(project.disabled_services).to match_array(disabled_services)
    end
  end

  shared_examples 'project without disabled services' do
    it 'has some disabled services' do
      expect(project.disabled_services).to be_empty
    end
  end

  describe '#disabled_services' do
    let(:namespace) { create(:group, :private) }
    let(:project) { create(:project, :private, namespace: namespace) }
    let(:disabled_services) { %w(jenkins jenkins_deprecated github) }

    context 'without a license key' do
      before do
        License.destroy_all # rubocop: disable DestroyAll
      end

      it_behaves_like 'project with disabled services'
    end

    context 'with a license key' do
      before do
        allow_any_instance_of(License).to receive(:plan).and_return(License::PREMIUM_PLAN)
      end

      context 'when checking of namespace plan is enabled' do
        before do
          stub_application_setting_on_object(project, should_check_namespace_plan: true)
        end

        context 'and namespace does not have a plan' do
          it_behaves_like 'project with disabled services'
        end

        context 'and namespace has a plan' do
          let(:namespace) { create(:group, :private, plan: :silver_plan) }
          let!(:gitlab_subscription) { create(:gitlab_subscription, :silver, namespace: namespace) }

          it_behaves_like 'project without disabled services'
        end
      end

      context 'when checking of namespace plan is not enabled' do
        before do
          stub_application_setting_on_object(project, should_check_namespace_plan: false)
        end

        it_behaves_like 'project without disabled services'
      end
    end
  end

  describe '#pull_mirror_available?' do
    let(:project) { create(:project) }

    context 'when mirror global setting is enabled' do
      it 'returns true' do
        expect(project.pull_mirror_available?).to be(true)
      end
    end

    context 'when mirror global setting is disabled' do
      before do
        stub_application_setting(mirror_available: false)
      end

      it 'returns true when overridden' do
        project.pull_mirror_available_overridden = true

        expect(project.pull_mirror_available?).to be(true)
      end

      it 'returns false when not overridden' do
        expect(project.pull_mirror_available?).to be(false)
      end
    end
  end

  describe '#username_only_import_url' do
    where(:import_url, :username, :expected_import_url) do
      '' | 'foo' | ''
      '' | ''    | ''
      '' | nil   | ''

      nil | 'foo' | nil
      nil | ''    | nil
      nil | nil   | nil

      'http://example.com' | 'foo' | 'http://foo@example.com'
      'http://example.com' | ''    | 'http://example.com'
      'http://example.com' | nil   | 'http://example.com'
    end

    with_them do
      let(:project) { build(:project, import_url: import_url, import_data_attributes: { user: username, password: 'password' }) }

      it { expect(project.username_only_import_url).to eq(expected_import_url) }
    end
  end

  describe '#username_only_import_url=' do
    it 'sets the import url and username' do
      project = build(:project, import_url: 'http://user@example.com')

      expect(project.import_url).to eq('http://user@example.com')
      expect(project.import_data.user).to eq('user')
    end

    it 'does not unset the password' do
      project = build(:project, import_url: 'http://olduser:pass@old.example.com')
      project.username_only_import_url = 'http://user@example.com'

      expect(project.username_only_import_url).to eq('http://user@example.com')
      expect(project.import_url).to eq('http://user:pass@example.com')
      expect(project.import_data.password).to eq('pass')
    end

    it 'clears the username if passed the empty string' do
      project = build(:project, import_url: 'http://olduser:pass@old.example.com')
      project.username_only_import_url = ''

      expect(project.username_only_import_url).to eq('')
      expect(project.import_url).to eq('')
      expect(project.import_data.user).to be_nil
      expect(project.import_data.password).to eq('pass')
    end
  end

  describe '#with_slack_application_disabled' do
    it 'returns projects where Slack application is disabled' do
      project1 = create(:project)
      project2 = create(:project)
      create(:gitlab_slack_application_service, project: project2)

      projects = described_class.with_slack_application_disabled

      expect(projects).to include(project1)
      expect(projects).not_to include(project2)
    end
  end

  describe '#licensed_features' do
    let(:plan_license) { :free }
    let(:global_license) { create(:license) }
    let(:group) { create(:group) }
    let!(:gitlab_subscription) { create(:gitlab_subscription, plan_license, namespace: group) }
    let(:project) { create(:project, group: group) }

    before do
      allow(License).to receive(:current).and_return(global_license)
      allow(global_license).to receive(:features).and_return([
        :epics, # Gold only
        :service_desk, # Silver and up
        :audit_events, # Bronze and up
        :geo, # Global feature, should not be checked at namespace level
      ])
    end

    subject { project.licensed_features }

    context 'when the namespace should be checked' do
      before do
        enable_namespace_license_check!
      end

      context 'when bronze' do
        let(:plan_license) { :bronze }

        it 'filters for bronze features' do
          is_expected.to contain_exactly(:audit_events, :geo)
        end
      end

      context 'when silver' do
        let(:plan_license) { :silver }

        it 'filters for silver features' do
          is_expected.to contain_exactly(:service_desk, :audit_events, :geo)
        end
      end

      context 'when gold' do
        let(:plan_license) { :gold }

        it 'filters for gold features' do
          is_expected.to contain_exactly(:epics, :service_desk, :audit_events, :geo)
        end
      end

      context 'when free plan' do
        let(:plan_license) { :free }

        it 'filters out paid features' do
          is_expected.to contain_exactly(:geo)
        end

        context 'when public project and namespace' do
          let(:group) { create(:group, :public) }
          let!(:gitlab_subscription) { create(:gitlab_subscription, :free, namespace: group) }
          let(:project) { create(:project, :public, group: group) }

          it 'includes all features in global license' do
            is_expected.to contain_exactly(:epics, :service_desk, :audit_events, :geo)
          end
        end
      end
    end

    context 'when namespace should not be checked' do
      it 'includes all features in global license' do
        is_expected.to contain_exactly(:epics, :service_desk, :audit_events, :geo)
      end
    end

    context 'when there is no license' do
      before do
        allow(License).to receive(:current).and_return(nil)
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#find_path_lock' do
    let(:project) { create :project }
    let(:path_lock) { create :path_lock, project: project }
    let(:path) { path_lock.path }

    it 'returns path_lock' do
      expect(project.find_path_lock(path)).to eq(path_lock)
    end

    it 'returns nil' do
      expect(project.find_path_lock('app/controllers')).to be_falsey
    end
  end

  describe '#any_path_locks?', :request_store do
    let(:project) { create :project }

    it 'returns false when there are no path locks' do
      expect(project.any_path_locks?).to be_falsey
    end

    it 'returns a cached true when there are path locks' do
      create(:path_lock, project: project)

      expect(project.path_locks).to receive(:any?).once.and_call_original

      2.times { expect(project.any_path_locks?).to be_truthy }
    end
  end

  describe '#latest_pipeline_with_security_reports' do
    let(:project) { create(:project) }
    let!(:pipeline_1) { create(:ci_pipeline_without_jobs, project: project) }
    let!(:pipeline_2) { create(:ci_pipeline_without_jobs, project: project) }
    let!(:pipeline_3) { create(:ci_pipeline_without_jobs, project: project) }

    subject { project.latest_pipeline_with_security_reports }

    context 'when legacy reports are used' do
      before do
        create(:ee_ci_build, :legacy_sast, pipeline: pipeline_1)
        create(:ee_ci_build, :legacy_sast, pipeline: pipeline_2)
      end

      it "returns the latest pipeline with security reports" do
        is_expected.to eq(pipeline_2)
      end
    end

    context 'when new reports are used' do
      before do
        create(:ee_ci_build, :sast, pipeline: pipeline_1)
        create(:ee_ci_build, :sast, pipeline: pipeline_2)
      end

      it "returns the latest pipeline with security reports" do
        is_expected.to eq(pipeline_2)
      end

      context 'when legacy used' do
        before do
          create(:ee_ci_build, :legacy_sast, pipeline: pipeline_3)
        end

        it "prefers the new reports" do
          is_expected.to eq(pipeline_2)
        end
      end
    end
  end

  describe '#protected_environment_by_name' do
    let(:project) { create(:project) }

    subject { project.protected_environment_by_name('production') }

    before do
      allow(project).to receive(:feature_available?)
        .with(:protected_environments).and_return(feature_available)
    end

    context 'when Protected Environments feature is not available on the project' do
      let(:feature_available) { false }

      it { is_expected.to be_nil }
    end

    context 'when Protected Environments feature is available on the project' do
      let(:feature_available) { true }
      let(:environment) { create(:environment, name: 'production') }
      let(:protected_environment) { create(:protected_environment, name: environment.name, project: project) }

      context 'when the project environment exists' do
        before do
          protected_environment
        end

        it { is_expected.to eq(protected_environment) }
      end

      context 'when the project environment does not exists' do
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#protected_environment_accessible_to?' do
    let(:project) { create(:project) }
    let(:user) { create(:user) }
    let(:environment) { create(:environment, project: project) }
    let(:protected_environment) { create(:protected_environment, project: project, name: environment.name) }

    subject { project.protected_environment_accessible_to?(environment.name, user) }

    before do
      allow(project).to receive(:feature_available?)
        .with(:protected_environments).and_return(feature_available)
    end

    context 'when Protected Environments feature is not available on the project' do
      let(:feature_available) { false }

      it { is_expected.to be_truthy }
    end

    context 'when Protected Environments feature is available on the project' do
      let(:feature_available) { true }

      context 'when project does not have protected environments' do
        it { is_expected.to be_truthy }
      end

      context 'when project has protected environments' do
        context 'when user has the right access' do
          before do
            protected_environment.deploy_access_levels.create(user_id: user.id)
          end

          it { is_expected.to be_truthy }
        end

        context 'when user does not have the right access' do
          before do
            protected_environment.deploy_access_levels.create
          end

          it { is_expected.to be_falsy }
        end
      end
    end
  end

  describe '#after_import' do
    let(:project) { create(:project) }
    let(:repository_updated_service) { instance_double('::Geo::RepositoryUpdatedService') }
    let(:wiki_updated_service) { instance_double('::Geo::RepositoryUpdatedService') }

    before do
      create(:import_state, project: project)

      allow(::Geo::RepositoryUpdatedService)
        .to receive(:new)
        .with(project.repository)
        .and_return(repository_updated_service)

      allow(::Geo::RepositoryUpdatedService)
        .to receive(:new)
        .with(project.wiki.repository)
        .and_return(wiki_updated_service)
    end

    it 'calls Geo::RepositoryUpdatedService when running on a Geo primary node' do
      allow(Gitlab::Geo).to receive(:primary?).and_return(true)

      expect(repository_updated_service).to receive(:execute).once
      expect(wiki_updated_service).to receive(:execute).once

      project.after_import
    end

    it 'does not call Geo::RepositoryUpdatedService when not running on a Geo primary node' do
      allow(Gitlab::Geo).to receive(:primary?).and_return(false)

      expect(repository_updated_service).not_to receive(:execute)
      expect(wiki_updated_service).not_to receive(:execute)

      project.after_import
    end
  end

  describe '#lfs_http_url_to_repo' do
    let(:project) { create(:project) }
    let(:project_path) { "#{Gitlab::Routing.url_helpers.project_path(project)}.git" }

    let(:primary_base_host) { 'primary.geo' }
    let(:primary_base_url) { "http://#{primary_base_host}" }
    let(:primary_url) { "#{primary_base_url}#{project_path}" }

    context 'with a Geo setup that is a primary' do
      let(:primary_node) { create(:geo_node, url: primary_base_url) }

      before do
        stub_current_geo_node(primary_node)
        stub_default_url_options(primary_base_host)
      end

      context 'for an upload operation' do
        it 'returns the project HTTP URL for the primary' do
          expect(project.lfs_http_url_to_repo('upload')).to eq(primary_url)
        end
      end
    end

    context 'with a Geo setup that is a secondary' do
      let(:secondary_base_host) { 'secondary.geo' }
      let(:secondary_base_url) { "http://#{secondary_base_host}" }
      let(:secondary_node) { create(:geo_node, url: secondary_base_url) }
      let(:secondary_url) { "#{secondary_base_url}#{project_path}" }

      before do
        stub_current_geo_node(secondary_node)
        stub_default_url_options(current_rails_hostname)
      end

      context 'and has a primary' do
        let(:primary_node) { create(:geo_node, url: primary_base_url) }

        context 'for an upload operation' do
          let(:current_rails_hostname) { primary_base_host }

          it 'returns the project HTTP URL for the primary' do
            expect(project.lfs_http_url_to_repo('upload')).to eq(primary_url)
          end
        end

        context 'for a download operation' do
          let(:current_rails_hostname) { secondary_base_host }

          it 'returns the project HTTP URL for the secondary' do
            expect(project.lfs_http_url_to_repo('download')).to eq(secondary_url)
          end
        end
      end

      context 'without a primary' do
        let(:current_rails_hostname) { secondary_base_host }

        it 'returns the project HTTP URL for the secondary' do
          expect(project.lfs_http_url_to_repo('operation_that_doesnt_matter')).to eq(secondary_url)
        end
      end
    end

    context 'without a Geo setup' do
      it 'returns the project HTTP URL for the main node' do
        project_url = "#{Gitlab::Routing.url_helpers.project_url(project)}.git"

        expect(project.lfs_http_url_to_repo('operation_that_doesnt_matter')).to eq(project_url)
      end
    end
  end

  describe '#add_import_job' do
    let(:project) { create(:project) }

    context 'when import_type is gitlab_custom_project_template_import' do
      it 'does not create import job' do
        project.import_type = 'gitlab_custom_project_template_import'

        expect(project.add_import_job).to be_nil
      end
    end
  end

  describe '#gitlab_custom_project_template_import?' do
    let(:project) { create(:project, import_type: 'gitlab_custom_project_template') }

    context 'when licensed' do
      before do
        stub_licensed_features(custom_project_templates: true)
      end

      it 'returns true' do
        expect(project.gitlab_custom_project_template_import?).to be true
      end
    end

    context 'when unlicensed' do
      it 'returns false' do
        expect(project.gitlab_custom_project_template_import?).to be false
      end
    end
  end

  describe '#packages_enabled' do
    subject { create(:project).packages_enabled }

    it { is_expected.to be true }
  end

  describe '#update_root_ref' do
    let(:project) { create(:project, :repository) }

    it 'updates the default branch when HEAD has changed' do
      stub_find_remote_root_ref(project, ref: 'feature')

      expect { project.update_root_ref('origin') }
        .to change { project.default_branch }
        .from('master')
        .to('feature')
    end

    it 'always updates the default branch even when HEAD does not change' do
      stub_find_remote_root_ref(project, ref: 'master')

      expect(project).to receive(:change_head).with('master').and_call_original

      project.update_root_ref('origin')

      # For good measure, expunge the root ref cache and reload.
      project.repository.expire_all_method_caches
      expect(project.reload.default_branch).to eq('master')
    end

    it 'does not update the default branch when HEAD does not exist' do
      stub_find_remote_root_ref(project, ref: 'foo')

      expect { project.update_root_ref('origin') }
        .not_to change { project.default_branch }
    end

    def stub_find_remote_root_ref(project, ref:)
      allow(project.repository)
        .to receive(:find_remote_root_ref)
        .with('origin')
        .and_return(ref)
    end
  end

  describe '#feature_flags_client_token' do
    let(:project) { create(:project) }

    subject { project.feature_flags_client_token }

    context 'when there is no access token' do
      it "creates a new one" do
        is_expected.not_to be_empty
      end
    end

    context 'when there is access token' do
      let!(:instance) { create(:operations_feature_flags_client, project: project, token: 'token') }

      it "provides an existing one" do
        is_expected.to eq('token')
      end
    end
  end

  describe '#store_security_reports_available?' do
    let(:project) { create(:project) }

    subject { project.store_security_reports_available? }

    it 'delegates to namespace' do
      expect(project.namespace).to receive(:store_security_reports_available?).once.and_call_original

      subject
    end
  end

  describe '#has_pool_repository?' do
    it 'returns false when there is no pool repository' do
      project = create(:project)

      expect(project.has_pool_repository?).to be false
    end

    it 'returns true when there is a pool repository' do
      pool = create(:pool_repository, :ready)
      project = create(:project, pool_repository: pool)

      expect(project.has_pool_repository?).to be true
    end
  end

  describe '#link_pool_repository' do
    let(:project) { create(:project, :repository) }

    subject  { project.link_pool_repository }

    it 'logs geo event' do
      expect(project.repository).to receive(:log_geo_updated_event)

      subject
    end
  end

  describe '#object_pool_missing?' do
    let(:pool) { create(:pool_repository, :ready) }
    subject { create(:project, :repository, pool_repository: pool) }

    it 'returns true when object pool is missing' do
      allow(pool.object_pool).to receive(:exists?).and_return(false)

      expect(subject.object_pool_missing?).to be true
    end

    it "returns false when pool repository doesnt't exist" do
      allow(subject).to receive(:has_pool_repository?).and_return(false)

      expect(subject.object_pool_missing?).to be false
    end

    it 'returns false when object pool exists' do
      expect(subject.object_pool_missing?).to be false
    end
  end

  describe "#insights_config" do
    context 'when project has no Insights config file' do
      let(:project) { create(:project) }

      it 'returns the project default config' do
        expect(project.insights_config).to eq(project.default_insights_config)
      end

      context 'when the project is inside a group' do
        let(:group) { create(:group) }
        let(:project) { create(:project, group: group) }

        context 'when the group has no Insights config' do
          it 'returns the group default config' do
            expect(project.insights_config).to eq(group.default_insights_config)
          end
        end

        context 'when the group has an Insights config from another project' do
          let(:config_project) do
            create(:project, :custom_repo, group: group, files: { ::Gitlab::Insights::CONFIG_FILE_PATH => insights_file_content })
          end

          before do
            group.create_insight!(project: config_project)
          end

          context 'with a valid config file' do
            let(:insights_file_content) { 'key: monthlyBugsCreated' }

            it 'returns the group config data from the other project' do
              expect(project.insights_config).to eq(config_project.insights_config)
              expect(project.insights_config).to eq(group.insights_config)
            end

            context 'when the project is inside a nested group' do
              let(:nested_group) { create(:group, parent: group) }
              let(:project) { create(:project, group: nested_group) }

              # The following expectaction should be changed to
              # expect(project.insights_config).to eq(config_project.insights_config)
              # once https://gitlab.com/gitlab-org/gitlab-ee/issues/11340 is implemented.
              it 'returns the project default config' do
                expect(project.insights_config).to eq(project.default_insights_config)
              end
            end
          end

          context 'with an invalid config file' do
            let(:insights_file_content) { ': foo bar' }

            it 'returns nil' do
              expect(project.insights_config).to be_nil
            end
          end
        end
      end
    end

    context 'when project has an Insights config file' do
      let(:project) do
        create(:project, :custom_repo, files: { ::Gitlab::Insights::CONFIG_FILE_PATH => insights_file_content })
      end

      context 'with a valid config file' do
        let(:insights_file_content) { 'key: monthlyBugsCreated' }

        it 'returns the insights config data' do
          expect(project.insights_config).to eq(key: 'monthlyBugsCreated')
        end

        context 'when the project is inside a group having another config' do
          let(:group) { create(:group) }
          let(:config_project) do
            create(:project, :custom_repo, group: group, files: { ::Gitlab::Insights::CONFIG_FILE_PATH => ': foo bar' })
          end

          before do
            project.group = group
            project.group.create_insight!(project: config_project)
          end

          it 'returns the project insights config data' do
            expect(project.insights_config).to eq(key: 'monthlyBugsCreated')
          end
        end
      end

      context 'with an invalid config file' do
        let(:insights_file_content) { ': foo bar' }

        it 'returns nil' do
          expect(project.insights_config).to be_nil
        end

        context 'when the project is inside a group having another config' do
          let(:group) { create(:group) }
          let(:config_project) do
            create(:project, :custom_repo, group: group, files: { ::Gitlab::Insights::CONFIG_FILE_PATH => 'key: monthlyBugsCreated' })
          end

          before do
            project.group = group
            project.group.create_insight!(project: config_project)
          end

          it 'returns nil' do
            expect(project.insights_config).to be_nil
          end
        end
      end
    end
  end

  describe "#design_management_enabled?" do
    let(:project) { build(:project) }

    where(
      feature_enabled: [false, true],
      license_enabled: [false, true],
      lfs_enabled: [false, true]
    )

    with_them do
      before do
        stub_licensed_features(design_management: license_enabled)
        stub_feature_flags(design_management_flag: feature_enabled)
        expect(project).to receive(:lfs_enabled?).and_return(lfs_enabled)
      end

      # Design management is only available if all dependencies are enabled
      let(:expected) { feature_enabled && license_enabled && lfs_enabled }

      it "knows if design management is available" do
        expect(project.design_management_enabled?).to be(expected)
      end
    end
  end

  describe "#kerberos_url_to_repo" do
    let(:project) { create(:project, path: "somewhere") }

    it 'returns valid kerberos url for this repo' do
      expect(project.kerberos_url_to_repo).to eq("#{Gitlab.config.build_gitlab_kerberos_url}/#{project.namespace.path}/somewhere.git")
    end
  end

  describe 'repository size restrictions' do
    let(:project) { build(:project) }

    before do
      allow_any_instance_of(ApplicationSetting).to receive(:repository_size_limit).and_return(50)
    end

    describe '#changes_will_exceed_size_limit?' do
      before do
        allow(project).to receive(:repository_and_lfs_size).and_return(49)
      end
      it 'returns true when changes go over' do
        expect(project.changes_will_exceed_size_limit?(5)).to be_truthy
      end
    end

    describe '#actual_size_limit' do
      it 'returns the limit set in the application settings' do
        expect(project.actual_size_limit).to eq(50)
      end

      it 'returns the value set in the group' do
        group = create(:group, repository_size_limit: 100)
        project.update_attribute(:namespace_id, group.id)

        expect(project.actual_size_limit).to eq(100)
      end

      it 'returns the value set locally' do
        project.update_attribute(:repository_size_limit, 75)

        expect(project.actual_size_limit).to eq(75)
      end
    end

    describe '#size_limit_enabled?' do
      it 'returns false when disabled' do
        project.update_attribute(:repository_size_limit, 0)

        expect(project.size_limit_enabled?).to be_falsey
      end

      it 'returns true when a limit is set' do
        project.update_attribute(:repository_size_limit, 75)

        expect(project.size_limit_enabled?).to be_truthy
      end
    end

    describe '#above_size_limit?' do
      let(:project) do
        create(:project,
               statistics: build(:project_statistics))
      end

      it 'returns true when above the limit' do
        allow(project).to receive(:repository_and_lfs_size).and_return(100)

        expect(project.above_size_limit?).to be_truthy
      end

      it 'returns false when not over the limit' do
        expect(project.above_size_limit?).to be_falsey
      end
    end

    describe '#size_to_remove' do
      it 'returns the correct value' do
        allow(project).to receive(:repository_and_lfs_size).and_return(100)

        expect(project.size_to_remove).to eq(50)
      end
    end
  end

  describe '#repository_size_limit column' do
    it 'support values up to 8 exabytes' do
      project = create(:project)
      project.update_column(:repository_size_limit, 8.exabytes - 1)

      project.reload

      expect(project.repository_size_limit).to eql(8.exabytes - 1)
    end
  end

  describe 'handling import URL' do
    context 'when project is a mirror' do
      it 'returns the full URL' do
        project = create(:project, :mirror, import_url: 'http://user:pass@test.com')

        project.import_state.finish

        expect(project.reload.import_url).to eq('http://user:pass@test.com')
      end
    end
  end

  describe '#add_import_job' do
    let(:import_jid) { '123' }

    context 'forked' do
      let(:forked_from_project) { create(:project, :repository) }
      let(:project) { create(:project) }

      before do
        fork_project(forked_from_project, nil, target_project: project)
      end

      context 'without mirror' do
        it 'returns nil' do
          project = create(:project)

          expect(project.add_import_job).to be nil
        end
      end

      context 'with mirror' do
        it 'schedules RepositoryUpdateMirrorWorker' do
          project = create(:project, :mirror, :repository)

          expect(RepositoryUpdateMirrorWorker).to receive(:perform_async).with(project.id).and_return(import_jid)
          expect(project.add_import_job).to eq(import_jid)
        end
      end
    end
  end

  describe '.where_full_path_in' do
    context 'without any paths' do
      it 'returns an empty relation' do
        expect(described_class.where_full_path_in([])).to eq([])
      end
    end

    context 'without any valid paths' do
      it 'returns an empty relation' do
        expect(described_class.where_full_path_in(%w[foo])).to eq([])
      end
    end

    context 'with valid paths' do
      let!(:project1) { create(:project) }
      let!(:project2) { create(:project) }

      it 'returns the projects matching the paths' do
        projects = described_class.where_full_path_in([project1.full_path,
                                                       project2.full_path])

        expect(projects).to contain_exactly(project1, project2)
      end

      it 'returns projects regardless of the casing of paths' do
        projects = described_class.where_full_path_in([project1.full_path.upcase,
                                                       project2.full_path.upcase])

        expect(projects).to contain_exactly(project1, project2)
      end
    end
  end

  describe '#change_repository_storage' do
    let(:project) { create(:project, :repository) }
    let(:read_only_project) { create(:project, :repository, repository_read_only: true) }

    before do
      FileUtils.mkdir('tmp/tests/extra_storage')
      stub_storage_settings('extra' => { 'path' => 'tmp/tests/extra_storage' })
    end

    after do
      FileUtils.rm_rf('tmp/tests/extra_storage')
    end

    it 'schedule the transfer of the repository to the new storage and locks the project' do
      expect(ProjectUpdateRepositoryStorageWorker).to receive(:perform_async).with(project.id, 'extra')

      project.change_repository_storage('extra')
      project.save

      expect(project).to be_repository_read_only
    end

    it "doesn't schedule the transfer if the repository is already read-only" do
      expect(ProjectUpdateRepositoryStorageWorker).not_to receive(:perform_async)

      read_only_project.change_repository_storage('extra')
      read_only_project.save
    end

    it "doesn't lock or schedule the transfer if the storage hasn't changed" do
      expect(ProjectUpdateRepositoryStorageWorker).not_to receive(:perform_async)

      project.change_repository_storage(project.repository_storage)
      project.save

      expect(project).not_to be_repository_read_only
    end

    it 'throws an error if an invalid repository storage is provided' do
      expect { project.change_repository_storage('unknown') }.to raise_error(ArgumentError)
    end
  end

  describe '#repository_and_lfs_size' do
    let(:project) { create(:project, :repository) }
    let(:size) { 50 }

    before do
      allow(project.statistics).to receive(:total_repository_size).and_return(size)
    end

    it 'returns the total repository and lfs size' do
      expect(project.repository_and_lfs_size).to eq(size)
    end
  end

  describe '#approver_group_ids=' do
    let(:project) { create(:project) }

    it 'create approver_groups' do
      group = create :group
      group1 = create :group

      project = create :project

      project.approver_group_ids = "#{group.id}, #{group1.id}"
      project.save!

      expect(project.approver_groups.map(&:group)).to match_array([group, group1])
    end
  end

  describe '#create_import_state' do
    it 'is called after save' do
      project = create(:project)

      expect(project).to receive(:create_import_state)

      project.update(mirror: true, mirror_user: project.owner, import_url: 'http://foo.com')
    end
  end

  describe '#allowed_to_share_with_group?' do
    context 'for group related project' do
      subject(:project) { build_stubbed(:project, namespace: group, group: group) }
      let(:group) { build_stubbed :group }

      context 'with lock_memberships_to_ldap application setting enabled' do
        before do
          stub_application_setting(lock_memberships_to_ldap: true)
        end

        it { is_expected.not_to be_allowed_to_share_with_group }
      end
    end

    context 'personal project' do
      subject(:project) { build_stubbed(:project, namespace: namespace) }
      let(:namespace) { build_stubbed :namespace }

      context 'with lock_memberships_to_ldap application setting enabled' do
        before do
          stub_application_setting(lock_memberships_to_ldap: true)
        end

        it { is_expected.to be_allowed_to_share_with_group }
      end
    end
  end

  # Despite stubbing the current node as the primary or secondary, the
  # behaviour for EE::Project#lfs_http_url_to_repo() is to call
  # Project#lfs_http_url_to_repo() which does not have a Geo context.
  def stub_default_url_options(host)
    allow(Rails.application.routes)
      .to receive(:default_url_options)
      .and_return(host: host)
  end

  describe '#package_already_taken?' do
    let(:namespace) { create(:namespace) }
    let(:project) { create(:project, :public, namespace: namespace) }
    let!(:package) { create(:npm_package, project: project, name: "@#{namespace.path}/foo") }

    context 'no package exists with the same name' do
      it 'returns false' do
        result = project.package_already_taken?("@#{namespace.path}/bar")
        expect(result).to be false
      end

      it 'returns false if it is the project that the package belongs to' do
        result = project.package_already_taken?("@#{namespace.path}/foo")
        expect(result).to be false
      end
    end

    context 'a package already exists with the same name' do
      let(:alt_project) { create(:project, :public, namespace: namespace) }

      it 'returns true' do
        result = alt_project.package_already_taken?("@#{namespace.path}/foo")
        expect(result).to be true
      end
    end
  end
end
