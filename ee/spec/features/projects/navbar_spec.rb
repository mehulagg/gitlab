# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project navbar' do
  include NavbarStructureHelper

  include_context 'project navbar structure'

  let_it_be(:project) { create(:project, :repository) }

  let(:user) { project.owner }

  before do
    sign_in(user)
  end

  context 'when sidebar refactor feature flag is disabled' do
    let(:project_context_nav_item) do
      nil
    end

    before do
      stub_feature_flags(sidebar_refactor: false)
      insert_package_nav(_('Operations'))
      insert_infrastructure_registry_nav
      stub_config(registry: { enabled: false })

      insert_after_sub_nav_item(
        _('Boards'),
        within: _('Issues'),
        new_sub_nav_item_name: _('Labels')
      )

      insert_after_nav_item(
        _('Snippets'),
        new_nav_item: {
          nav_item: _('Members'),
          nav_sub_items: []
        }
      )
    end

    context 'when issue analytics is available' do
      before do
        stub_licensed_features(issues_analytics: true)

        insert_after_sub_nav_item(
          _('Code Review'),
          within: _('Analytics'),
          new_sub_nav_item_name: _('Issue')
        )

        visit project_path(project)
      end

      it_behaves_like 'verified navigation bar'
    end

    context 'when security dashboard is available' do
      let(:security_and_compliance_nav_item) do
        {
          nav_item: _('Security & Compliance'),
          nav_sub_items: [
            _('Security Dashboard'),
            _('Vulnerability Report'),
            s_('OnDemandScans|On-demand Scans'),
            _('Configuration'),
            _('Audit Events')
          ]
        }
      end

      before do
        stub_licensed_features(security_dashboard: true, security_on_demand_scans: true)

        visit project_path(project)
      end

      it_behaves_like 'verified navigation bar'
    end

    context 'when packages are available' do
      before do
        stub_config(packages: { enabled: true }, registry: { enabled: false })

        visit project_path(project)
      end

      context 'when container registry is available' do
        before do
          stub_config(registry: { enabled: true })

          insert_container_nav

          visit project_path(project)
        end

        it_behaves_like 'verified navigation bar'
      end
    end

    context 'when requirements is available' do
      before do
        stub_licensed_features(requirements: true)
        insert_after_nav_item(
          _('Merge requests'),
          new_nav_item: {
            nav_item: _('Requirements'),
            nav_sub_items: [_('List')]
          }
        )

        visit project_path(project)
      end

      it_behaves_like 'verified navigation bar'
    end
  end

  context 'when sidebar refactor feature flag is enabled' do
    let(:monitor_menu_items) do
      [
        _('Metrics'),
        _('Logs'),
        _('Tracing'),
        _('Error Tracking'),
        _('Alerts'),
        _('Incidents'),
        _('Product Analytics')
      ]
    end

    let(:monitor_nav_item) do
      {
        nav_item: _('Monitor'),
        nav_sub_items: monitor_menu_items
      }
    end

    let(:project_information_nav_item) do
      {
        nav_item: _('Project information'),
        nav_sub_items: [
          _('Activity'),
          _('Labels'),
          _('Members')
        ]
      }
    end

    let(:settings_menu_items) do
      [
        _('General'),
        _('Integrations'),
        _('Webhooks'),
        _('Access Tokens'),
        _('Repository'),
        _('CI/CD'),
        _('Monitor')
      ]
    end

    before do
      stub_feature_flags(sidebar_refactor: true)
      insert_package_nav(_('Monitor'))
      insert_infrastructure_registry_nav

      insert_after_nav_item(
        _('Security & Compliance'),
        new_nav_item: {
          nav_item: _('Deployments'),
          nav_sub_items: [
            _('Feature Flags'),
            _('Environments'),
            _('Releases')
          ]
        }
      )

      insert_after_nav_item(
        _('Monitor'),
        new_nav_item: {
          nav_item: _('Infrastructure'),
          nav_sub_items: [
            _('Kubernetes clusters'),
            _('Serverless platform'),
            _('Terraform')
          ]
        }
      )

      visit project_path(project)
    end

    it_behaves_like 'verified navigation bar'

    context 'when requirements is available' do
      before do
        stub_licensed_features(requirements: true)

        insert_after_nav_item(
          _('Merge requests'),
          new_nav_item: {
            nav_item: _('Requirements'),
            nav_sub_items: []
          }
        )

        visit project_path(project)
      end

      it_behaves_like 'verified navigation bar'
    end
  end
end
