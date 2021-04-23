# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/nav/sidebar/_project' do
  let_it_be_with_refind(:project) { create(:project, :repository) }

  let(:user) { project.owner }

  before do
    assign(:project, project)
    assign(:repository, project.repository)

    allow(view).to receive(:current_ref).and_return('master')
  end

  describe 'Repository' do
    describe 'Files' do
      it 'has a link to the project file locks path' do
        allow(view).to receive(:current_user).and_return(user)

        render

        expect(rendered).to have_link('Locked Files', href: project_path_locks_path(project))
      end
    end
  end

  describe 'issue boards' do
    it 'has boards tab' do
      allow(view).to receive(:can?).and_return(true)
      allow(License).to receive(:feature_available?).and_call_original

      render

      expect(rendered).to have_css('a[title="Boards"]')
    end
  end

  describe 'Operations main link' do
    let(:user) { create(:user) }

    before do
      project.project_feature.update!(builds_access_level: feature)

      project.team.add_developer(user)
      sign_in(user)
    end

    context 'when ci/cd is disabled' do
      let(:feature) { ProjectFeature::DISABLED }

      it 'links to feature flags page' do
        render

        expect(rendered).to have_link('Operations', href: project_feature_flags_path(project))
      end
    end

    context 'when ci/cd is enabled' do
      let(:feature) { ProjectFeature::ENABLED }

      it 'links to metrics page' do
        render

        expect(rendered).to have_link('Operations', href: metrics_project_environments_path(project))
      end
    end
  end

  describe 'Operations > Pod logs' do
    before do
      allow(view).to receive(:can?).with(nil, :read_environment, project).and_return(can_read_environment)
      allow(view).to receive(:can?).with(nil, :read_pod_logs, project).and_return(can_read_pod_logs)
      render
    end

    describe 'when the user can read environments and logs' do
      let(:can_read_environment) { true }
      let(:can_read_pod_logs) { true }

      it 'link is visible' do
        expect(rendered).to have_link('Logs', href: project_logs_path(project))
      end
    end

    describe 'when the user cannot read environment or logs' do
      let(:can_read_environment) { false }
      let(:can_read_pod_logs) { false }

      it 'link is not visible' do
        expect(rendered).not_to have_link 'Logs'
      end
    end

    describe 'when the user can read environment but not logs' do
      let(:can_read_environment) { true }
      let(:can_read_pod_logs) { false }

      it 'link is not visible' do
        expect(rendered).not_to have_link 'Logs'
      end
    end
  end

  describe 'Security and Compliance' do
    before do
      allow(view).to receive(:can?).with(nil, :read_dependencies, project).and_return(can_read_dependencies)
      allow(view).to receive(:can?).with(nil, :read_project_security_dashboard, project).and_return(can_read_dashboard)
      allow(view).to receive(:can?).with(nil, :read_project_audit_events, project).and_return(can_read_project_audit_events)
      allow(view).to receive(:can?).with(nil, :read_security_configuration, project).and_return(can_read_security_configuration)
      allow(view).to receive(:can?).with(nil, :access_security_and_compliance, project).and_return(can_access_security_and_compliance)

      render
    end

    describe 'when the "Security & Compliance" is not available' do
      let(:can_access_security_and_compliance) { false }

      describe 'when the user has full permissions' do
        let(:can_read_dashboard) { true }
        let(:can_read_dependencies) { true }
        let(:can_read_project_audit_events) { true }
        let(:can_read_security_configuration) { true }

        it 'top level navigation link is not visible' do
          expect(rendered).not_to have_link('Security & Compliance', href: project_security_dashboard_index_path(project))
        end

        it 'security dashboard link is not visible' do
          expect(rendered).not_to have_link('Security Dashboard', href: project_security_dashboard_index_path(project))
        end

        it 'security configuration link is not visible' do
          expect(rendered).not_to have_link('Configuration', href: project_security_configuration_path(project))
        end

        it 'dependency list link is not visible' do
          expect(rendered).not_to have_link('Dependency List', href: project_dependencies_path(project))
        end

        it 'audit events link is not visible' do
          expect(rendered).not_to have_link('Audit Events', href: project_audit_events_path(project))
        end
      end
    end

    describe 'when the "Security & Compliance" is available' do
      let(:can_access_security_and_compliance) { true }

      describe 'when the user has full permissions' do
        let(:can_read_dashboard) { true }
        let(:can_read_dependencies) { true }
        let(:can_read_project_audit_events) { true }
        let(:can_read_security_configuration) { true }

        it 'top level navigation link is visible' do
          expect(rendered).to have_link('Security & Compliance', href: project_security_dashboard_index_path(project))
        end

        it 'security dashboard link is visible' do
          expect(rendered).to have_link('Security Dashboard', href: project_security_dashboard_index_path(project))
        end

        it 'security configuration link is visible' do
          expect(rendered).to have_link('Configuration', href: project_security_configuration_path(project))
        end

        it 'dependency list link is visible' do
          expect(rendered).to have_link('Dependency List', href: project_dependencies_path(project))
        end

        it 'audit events link is visible' do
          expect(rendered).to have_link('Audit Events', href: project_audit_events_path(project))
        end
      end

      describe 'when the user can view only security dashboard' do
        let(:can_read_dashboard) { true }
        let(:can_read_dependencies) { false }
        let(:can_read_project_audit_events) { false }
        let(:can_read_security_configuration) { true }

        it 'top level navigation link is visible' do
          expect(rendered).to have_link('Security & Compliance', href: project_security_dashboard_index_path(project))
        end

        it 'security dashboard link is visible' do
          expect(rendered).to have_link('Security Dashboard', href: project_security_dashboard_index_path(project))
        end

        it 'security configuration link is visible' do
          expect(rendered).to have_link('Configuration', href: project_security_configuration_path(project))
        end

        it 'dependency list link is not visible' do
          expect(rendered).not_to have_link('Dependency List', href: project_dependencies_path(project))
        end

        it 'audit events link is not visible' do
          expect(rendered).not_to have_link('Audit Events', href: project_audit_events_path(project))
        end
      end

      describe 'when the user can view only dependency list' do
        let(:can_read_dashboard) { false }
        let(:can_read_dependencies) { true }
        let(:can_read_project_audit_events) { false }
        let(:can_read_security_configuration) { false }

        it 'top level navigation link is visible' do
          expect(rendered).to have_link('Security & Compliance', href: project_dependencies_path(project))
        end

        it 'security dashboard link is not visible' do
          expect(rendered).not_to have_link('Security Dashboard', href: project_security_dashboard_index_path(project))
        end

        it 'security configuration link is not visible' do
          expect(rendered).not_to have_link('Configuration', href: project_security_configuration_path(project))
        end

        it 'dependency list link is visible' do
          expect(rendered).to have_link('Dependency List', href: project_dependencies_path(project))
        end

        it 'audit events link is not visible' do
          expect(rendered).not_to have_link('Audit Events', href: project_audit_events_path(project))
        end
      end

      describe 'when the user can view only audit events' do
        let(:can_read_dashboard) { false }
        let(:can_read_dependencies) { false }
        let(:can_read_project_audit_events) { true }
        let(:can_read_security_configuration) { false }

        it 'top level navigation link is visible' do
          expect(rendered).to have_link('Security & Compliance', href: project_audit_events_path(project))
        end

        it 'security dashboard link is not visible' do
          expect(rendered).not_to have_link('Security Dashboard', href: project_security_dashboard_index_path(project))
        end

        it 'security configuration link is not visible' do
          expect(rendered).not_to have_link('Configuration', href: project_security_configuration_path(project))
        end

        it 'dependency list link is not visible' do
          expect(rendered).not_to have_link('Dependency List', href: project_dependencies_path(project))
        end

        it 'audit events link is visible' do
          expect(rendered).to have_link('Audit Events', href: project_audit_events_path(project))
        end
      end

      describe 'when the user has no permissions' do
        let(:can_read_dependencies) { false }
        let(:can_read_dashboard) { false }
        let(:can_read_project_audit_events) { false }
        let(:can_read_security_configuration) { false }

        it 'top level navigation link is visible' do
          expect(rendered).not_to have_link('Security & Compliance', href: project_security_dashboard_index_path(project))
        end

        it 'security dashboard link is not visible' do
          expect(rendered).not_to have_link('Security Dashboard', href: project_security_dashboard_index_path(project))
        end

        it 'security configuration link is not visible' do
          expect(rendered).not_to have_link('Configuration', href: project_security_configuration_path(project))
        end

        it 'dependency list link is not visible' do
          expect(rendered).not_to have_link('Dependency List', href: project_dependencies_path(project))
        end

        it 'audit events link is not visible' do
          expect(rendered).not_to have_link('Audit Events', href: project_audit_events_path(project))
        end
      end
    end
  end

  describe 'Settings > Operations' do
    it 'is not visible when no valid license' do
      allow(view).to receive(:can?).and_return(true)

      render

      expect(rendered).not_to have_link project_settings_operations_path(project)
    end

    it 'is not visible to unauthorized user' do
      render

      expect(rendered).not_to have_link project_settings_operations_path(project)
    end

    it 'links to settings page' do
      allow(view).to receive(:can?).and_return(true)

      render

      expect(rendered).to have_link('Operations', href: project_settings_operations_path(project))
    end
  end

  describe 'iterations link' do
    context 'with authorized user' do
      let_it_be(:current_user) { create(:user) }

      before do
        project.add_guest(current_user)

        allow(view).to receive(:current_user).and_return(current_user)
      end

      context 'with iterations licensed feature available' do
        before do
          stub_licensed_features(iterations: true)
        end

        it 'is visible' do
          render

          expect(rendered).to have_text 'Iterations'
        end
      end

      context 'with iterations licensed feature disabled' do
        before do
          stub_licensed_features(iterations: false)
        end

        it 'is not visible' do
          render

          expect(rendered).not_to have_text 'Iterations'
        end
      end
    end

    context 'with unauthorized user' do
      context 'with iterations licensed feature available' do
        before do
          stub_licensed_features(iterations: true)
        end

        it 'is not visible' do
          render

          expect(rendered).not_to have_text 'Iterations'
        end
      end

      context 'with iterations licensed feature disabled' do
        before do
          stub_licensed_features(iterations: false)
        end

        it 'is not visible' do
          render

          expect(rendered).not_to have_text 'Iterations'
        end
      end
    end
  end
end
