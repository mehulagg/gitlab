# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project navbar' do
  include NavbarStructureHelper

  include_context 'project navbar structure'

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, :repository) }

  before do
    stub_feature_flags(sidebar_refactor: false)
    insert_package_nav(_('Operations'))
    insert_infrastructure_registry_nav
    stub_config(registry: { enabled: false })

    insert_after_nav_item(
      _('Snippets'),
      new_nav_item: {
        nav_item: _('Members'),
        nav_sub_items: []
      }
    )

    project.add_maintainer(user)
    sign_in(user)
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
      stub_feature_flags(sidebar_refactor: false)

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
    end

    context 'with flag disabled' do
      before do
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

    context 'with flag enabled' do
      let(:operations_menu_items) do
        [
          _('Metrics'),
          _('Logs'),
          _('Tracing'),
          _('Error Tracking'),
          _('Alerts'),
          _('Incidents'),
          _('Environments'),
          _('Feature Flags'),
          _('Product Analytics')
        ]
      end

      let(:project_information_nav_item) do
        {
          nav_item: _('Project information'),
          nav_sub_items: [
            _('Activity'),
            _('Releases'),
            _('Members')
          ]
        }
      end

      before do
        stub_feature_flags(sidebar_refactor: true)

        insert_after_nav_item(
          _('Merge requests'),
          new_nav_item: {
            nav_item: _('Requirements'),
            nav_sub_items: []
          }
        )

        insert_after_nav_item(
          _('Operations'),
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
    end
  end
end
