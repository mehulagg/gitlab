require 'spec_helper'

describe ProjectPolicy do
  include ExternalAuthorizationServiceHelpers

  set(:owner) { create(:user) }
  set(:admin) { create(:admin) }
  set(:maintainer) { create(:user) }
  set(:developer) { create(:user) }
  set(:reporter) { create(:user) }
  set(:guest) { create(:user) }
  let(:project) { create(:project, :public, namespace: owner.namespace) }

  before do
    project.add_maintainer(maintainer)
    project.add_developer(developer)
    project.add_reporter(reporter)
    project.add_guest(guest)
  end

  context 'admin_mirror' do
    context 'with remote mirror setting enabled' do
      context 'with admin' do
        subject do
          described_class.new(admin, project)
        end

        it do
          is_expected.to be_allowed(:admin_mirror)
        end
      end

      context 'with owner' do
        subject do
          described_class.new(owner, project)
        end

        it do
          is_expected.to be_allowed(:admin_mirror)
        end
      end

      context 'with developer' do
        subject do
          described_class.new(developer, project)
        end

        it do
          is_expected.to be_disallowed(:admin_mirror)
        end
      end
    end

    context 'with remote mirror setting disabled' do
      before do
        stub_application_setting(mirror_available: false)
      end

      context 'with admin' do
        subject do
          described_class.new(admin, project)
        end

        it do
          is_expected.to be_allowed(:admin_mirror)
        end
      end

      context 'with owner' do
        subject do
          described_class.new(owner, project)
        end

        it do
          is_expected.to be_disallowed(:admin_mirror)
        end
      end
    end

    context 'with remote mirrors feature disabled' do
      before do
        stub_licensed_features(repository_mirrors: false)
      end

      context 'with admin' do
        subject do
          described_class.new(admin, project)
        end

        it do
          is_expected.to be_disallowed(:admin_mirror)
        end
      end

      context 'with owner' do
        subject do
          described_class.new(owner, project)
        end

        it do
          is_expected.to be_disallowed(:admin_mirror)
        end
      end
    end

    context 'with remote mirrors feature enabled' do
      before do
        stub_licensed_features(repository_mirrors: true)
      end

      context 'with admin' do
        subject do
          described_class.new(admin, project)
        end

        it do
          is_expected.to be_allowed(:admin_mirror)
        end
      end

      context 'with owner' do
        subject do
          described_class.new(owner, project)
        end

        it do
          is_expected.to be_allowed(:admin_mirror)
        end
      end
    end
  end

  context 'reading a project' do
    it 'allows access when a user has read access to the repo' do
      expect(described_class.new(owner, project)).to be_allowed(:read_project)
      expect(described_class.new(developer, project)).to be_allowed(:read_project)
      expect(described_class.new(admin, project)).to be_allowed(:read_project)
    end

    it 'never checks the external service' do
      expect(EE::Gitlab::ExternalAuthorization).not_to receive(:access_allowed?)

      expect(described_class.new(owner, project)).to be_allowed(:read_project)
    end

    context 'with an external authorization service' do
      before do
        enable_external_authorization_service_check
      end

      it 'allows access when the external service allows it' do
        external_service_allow_access(owner, project)
        external_service_allow_access(developer, project)

        expect(described_class.new(owner, project)).to be_allowed(:read_project)
        expect(described_class.new(developer, project)).to be_allowed(:read_project)
      end

      it 'does not check the external service for admins and allows access' do
        expect(EE::Gitlab::ExternalAuthorization).not_to receive(:access_allowed?)

        expect(described_class.new(admin, project)).to be_allowed(:read_project)
      end

      it 'allows auditors' do
        stub_licensed_features(auditor_user: true)
        auditor = create(:user, :auditor)

        expect(described_class.new(auditor, project)).to be_allowed(:read_project)
      end

      it 'prevents all but seeing a public project in a list when access is denied' do
        [developer, owner, build(:user), nil].each do |user|
          external_service_deny_access(user, project)
          policy = described_class.new(user, project)

          expect(policy).not_to be_allowed(:read_project)
          expect(policy).not_to be_allowed(:owner_access)
          expect(policy).not_to be_allowed(:change_namespace)
        end
      end

      it 'passes the full path to external authorization for logging purposes' do
        expect(EE::Gitlab::ExternalAuthorization)
          .to receive(:access_allowed?).with(owner, 'default_label', project.full_path).and_call_original

        described_class.new(owner, project).allowed?(:read_project)
      end
    end
  end

  describe 'read_vulnerability_feedback' do
    subject { described_class.new(current_user, project) }

    context 'with public project' do
      let(:current_user) { nil }

      it { is_expected.to be_allowed(:read_vulnerability_feedback) }
    end

    context 'with private project' do
      let(:current_user) { admin }
      let(:project) { create(:project, :private, namespace: owner.namespace) }

      context 'with admin' do
        let(:current_user) { admin }

        it { is_expected.to be_allowed(:read_vulnerability_feedback) }
      end

      context 'with owner' do
        let(:current_user) { owner }

        it { is_expected.to be_allowed(:read_vulnerability_feedback) }
      end

      context 'with maintainer' do
        let(:current_user) { maintainer }

        it { is_expected.to be_allowed(:read_vulnerability_feedback) }
      end

      context 'with developer' do
        let(:current_user) { developer }

        it { is_expected.to be_allowed(:read_vulnerability_feedback) }
      end

      context 'with reporter' do
        let(:current_user) { reporter }

        it { is_expected.to be_allowed(:read_vulnerability_feedback) }
      end

      context 'with guest' do
        let(:current_user) { guest }

        it { is_expected.to be_allowed(:read_vulnerability_feedback) }
      end

      context 'with non member' do
        let(:current_user) { create(:user) }

        it { is_expected.to be_disallowed(:read_vulnerability_feedback) }
      end

      context 'with anonymous' do
        let(:current_user) { nil }

        it { is_expected.to be_disallowed(:read_vulnerability_feedback) }
      end
    end
  end

  describe 'vulnerability feedback permissions' do
    subject { described_class.new(current_user, project) }

    where(permission: %i[
      admin_vulnerability_feedback
      create_vulnerability_feedback_issue
      create_vulnerability_feedback_dismissal
      create_vulnerability_feedback_merge_request
      destroy_vulnerability_feedback_dismissal
    ])

    with_them do
      context 'with admin' do
        let(:current_user) { admin }

        it { is_expected.to be_allowed(permission) }
      end

      context 'with owner' do
        let(:current_user) { owner }

        it { is_expected.to be_allowed(permission) }
      end

      context 'with maintainer' do
        let(:current_user) { maintainer }

        it { is_expected.to be_allowed(permission) }
      end

      context 'with developer' do
        let(:current_user) { developer }

        it { is_expected.to be_allowed(permission) }
      end

      context 'with reporter' do
        let(:current_user) { reporter }

        it { is_expected.to be_disallowed(permission) }
      end

      context 'with guest' do
        let(:current_user) { guest }

        it { is_expected.to be_disallowed(permission) }
      end

      context 'with non member' do
        let(:current_user) { create(:user) }

        it { is_expected.to be_disallowed(permission) }
      end

      context 'with anonymous' do
        let(:current_user) { nil }

        it { is_expected.to be_disallowed(permission) }
      end
    end

    context 'when issue cannot be created' do
      let(:current_user) { admin }

      it 'does not allow to create issue feedback' do
        project.issues_enabled = false
        project.save!

        is_expected.to be_disallowed(:create_vulnerability_feedback_issue)
      end
    end

    context 'when merge request cannot be created' do
      let(:current_user) { admin }

      it 'does not allow to create merge request feedback' do
        project.project_feature.update(merge_requests_access_level: ProjectFeature::DISABLED)

        is_expected.to be_disallowed(:create_vulnerability_feedback_merge_request)
      end
    end
  end

  describe 'read_project_security_dashboard' do
    before do
      stub_licensed_features(security_dashboard: true)
    end

    subject { described_class.new(current_user, project) }

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:read_project_security_dashboard) }
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:read_project_security_dashboard) }
    end

    context 'with maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_allowed(:read_project_security_dashboard) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.to be_allowed(:read_project_security_dashboard) }

      context 'when security dashboard features is not available' do
        before do
          stub_licensed_features(security_dashboard: false)
        end

        it { is_expected.to be_disallowed(:read_project_security_dashboard) }
      end
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_disallowed(:read_project_security_dashboard) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_disallowed(:read_project_security_dashboard) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_disallowed(:read_project_security_dashboard) }
    end

    context 'with anonymous' do
      let(:current_user) { nil }

      it { is_expected.to be_disallowed(:read_project_security_dashboard) }
    end
  end

  describe 'read_package' do
    subject { described_class.new(current_user, project) }

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:read_package) }

      context 'when repository is disabled' do
        before do
          project.project_feature.update(repository_access_level: ProjectFeature::DISABLED)
        end

        it { is_expected.to be_disallowed(:read_package) }
      end
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:read_package) }
    end

    context 'with maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_allowed(:read_package) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.to be_allowed(:read_package) }
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_allowed(:read_package) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_allowed(:read_package) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_allowed(:read_package) }
    end

    context 'with anonymous' do
      let(:current_user) { nil }

      it { is_expected.to be_allowed(:read_package) }
    end
  end

  describe 'read_feature_flag' do
    before do
      stub_licensed_features(feature_flags: true)
    end

    subject { described_class.new(current_user, project) }

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:read_feature_flag) }

      context 'when repository is disabled' do
        before do
          project.project_feature.update(repository_access_level: ProjectFeature::DISABLED)
        end

        it { is_expected.to be_disallowed(:read_feature_flag) }
      end
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:read_feature_flag) }
    end

    context 'with maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_allowed(:read_feature_flag) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.to be_allowed(:read_feature_flag) }

      context 'when feature flags features is not available' do
        before do
          stub_licensed_features(feature_flags: false)
        end

        it { is_expected.to be_disallowed(:read_feature_flag) }
      end
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_disallowed(:read_feature_flag) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_disallowed(:read_feature_flag) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_disallowed(:read_feature_flag) }
    end

    context 'with anonymous' do
      let(:current_user) { nil }

      it { is_expected.to be_disallowed(:read_feature_flag) }
    end
  end

  describe 'admin_license_management' do
    before do
      stub_licensed_features(license_management: true)
    end

    subject { described_class.new(current_user, project) }

    context 'without license management feature available' do
      before do
        stub_licensed_features(license_management: false)
      end

      let(:current_user) { admin }

      it { is_expected.to be_disallowed(:admin_software_license_policy) }
    end

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:admin_software_license_policy) }
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:admin_software_license_policy) }
    end

    context 'with maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_allowed(:admin_software_license_policy) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.to be_disallowed(:admin_software_license_policy) }
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_disallowed(:admin_software_license_policy) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_disallowed(:admin_software_license_policy) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_disallowed(:admin_software_license_policy) }
    end

    context 'with anonymous' do
      let(:current_user) { nil }

      it { is_expected.to be_disallowed(:admin_software_license_policy) }
    end
  end

  describe 'read_license_management' do
    before do
      stub_licensed_features(license_management: true)
    end

    subject { described_class.new(current_user, project) }

    context 'without license management feature available' do
      before do
        stub_licensed_features(license_management: false)
      end

      let(:current_user) { admin }

      it { is_expected.to be_disallowed(:read_software_license_policy) }
    end

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end

    context 'with maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end

    context 'with anonymous' do
      let(:current_user) { nil }

      it { is_expected.to be_allowed(:read_software_license_policy) }
    end
  end

  describe 'create_web_ide_terminal' do
    before do
      stub_licensed_features(web_ide_terminal: true)
    end

    subject { described_class.new(current_user, project) }

    context 'without ide terminal feature available' do
      before do
        stub_licensed_features(web_ide_terminal: false)
      end

      let(:current_user) { admin }

      it { is_expected.to be_disallowed(:create_web_ide_terminal) }
    end

    context 'with admin' do
      let(:current_user) { admin }

      it { is_expected.to be_allowed(:create_web_ide_terminal) }
    end

    context 'with owner' do
      let(:current_user) { owner }

      it { is_expected.to be_allowed(:create_web_ide_terminal) }
    end

    context 'with maintainer' do
      let(:current_user) { maintainer }

      it { is_expected.to be_allowed(:create_web_ide_terminal) }
    end

    context 'with developer' do
      let(:current_user) { developer }

      it { is_expected.to be_disallowed(:create_web_ide_terminal) }
    end

    context 'with reporter' do
      let(:current_user) { reporter }

      it { is_expected.to be_disallowed(:create_web_ide_terminal) }
    end

    context 'with guest' do
      let(:current_user) { guest }

      it { is_expected.to be_disallowed(:create_web_ide_terminal) }
    end

    context 'with non member' do
      let(:current_user) { create(:user) }

      it { is_expected.to be_disallowed(:create_web_ide_terminal) }
    end

    context 'with anonymous' do
      let(:current_user) { nil }

      it { is_expected.to be_disallowed(:create_web_ide_terminal) }
    end
  end

  it_behaves_like 'ee clusterable policies' do
    let(:clusterable) { create(:project, :repository) }

    let(:cluster) do
      create(:cluster,
             :provided_by_gcp,
             :project,
             projects: [clusterable])
    end
  end
end
