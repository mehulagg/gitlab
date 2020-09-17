# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Project settings > Issues', :js do
  let(:project) { create(:project, :public) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)

    sign_in(user)
  end

  context 'when Issues are initially enabled' do
    context 'when Pipelines are initially enabled' do
      before do
        visit edit_project_path(project)
      end

      it 'shows the Issues settings' do
        expect(page).to have_content('Set a default template for issue descriptions.')

        within('.sharing-permissions-form') do
          find('.project-feature-controls[data-for="project[project_feature_attributes][issues_access_level]"] .project-feature-toggle').click
          click_on('Save changes')
        end

        expect(page).not_to have_content('Set a default template for issue descriptions.')
      end
    end
  end

  context 'when Issues are initially disabled' do
    before do
      project.project_feature.update_attribute('issues_access_level', ProjectFeature::DISABLED)
      visit edit_project_path(project)
    end

    it 'does not show the Issues settings' do
      expect(page).not_to have_content('Set a default template for issue descriptions.')

      within('.sharing-permissions-form') do
        find('.project-feature-controls[data-for="project[project_feature_attributes][issues_access_level]"] .project-feature-toggle').click
        click_on('Save changes')
      end

      expect(page).to have_content('Set a default template for issue descriptions.')
    end
  end

  context 'issuable default templates feature not available' do
    before do
      stub_licensed_features(issuable_default_templates: false)
    end

    it 'input to configure issue template is not shown' do
      visit edit_project_path(project)

      expect(page).not_to have_selector('#project_issues_template')
    end
  end

  context 'issuable default templates feature is available' do
    before do
      stub_licensed_features(issuable_default_templates: true)
    end

    it 'input to configure issue template is not shown' do
      visit edit_project_path(project)

      expect(page).to have_selector('#project_issues_template')
    end
  end

  context 'when viewing CVE request settings' do
    using RSpec::Parameterized::TableSyntax

    where(:gitlab_com, :project_visibility, :cve_enabled, :toggle_checked, :toggle_disabled, :has_toggle) do
      true  | :PUBLIC   | true | true | false | true
      true  | :INTERNAL | true | nil  | true  | true
      true  | :PRIVATE  | true | nil  | true  | true
      false | :PUBLIC   | true | nil  | nil   | false
    end

    with_them do
      before do
        allow(::Gitlab).to receive(:com?).and_return(gitlab_com)

        vis_val = Gitlab::VisibilityLevel.const_get(project_visibility, false)
        project.visibility_level = vis_val
        project.save!

        security_setting = ProjectSecuritySetting.safe_find_or_create_for(project)
        security_setting.cve_id_request_enabled = cve_enabled
        security_setting.save!

        visit edit_project_path(project)
      end

      it "CVE ID Request toggle should be correctly visible" do
        if has_toggle
          expect(page).to have_selector('#cve_id_request_toggle')
        else
          expect(page).not_to have_selector('#cve_id_request_toggle')
          next
        end

        toggle_btn = find('#cve_id_request_toggle button.project-feature-toggle')

        if toggle_disabled
          expect(toggle_btn).to match_css('.is-disabled', wait: 0)
        else
          expect(toggle_btn).not_to match_css('.is-disabled', wait: 0)
        end

        next if toggle_checked.nil?

        if toggle_checked
          expect(toggle_btn).to match_css('.is-checked', wait: 0)
        else
          expect(toggle_btn).not_to match_css('.is-checked', wait: 0)
        end
      end
    end
  end
end
