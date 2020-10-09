# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::CveRequestHelper do
  let(:project) { create(:project) }

  describe '#request_cve_enabled_for_user?' do
    where(
      maintainer: [true, false],
      request_cve_enabled: [true, false]
    )
    with_them do
      let(:user) { create_user(maintainer ? :maintainer : :developer) }
      let(:issue) do
        create(:issue, project: project, assignees: [user])
      end

      before do
        allow(helper).to receive(:can?) do |_user, perm, project|
          perm == :admin_project ? maintainer : false
        end
        allow(helper).to receive(:request_cve_enabled?).and_return(request_cve_enabled)
      end

      it "returns the correct value" do
        res = helper.request_cve_enabled_for_user?(issue, user)
        expected = maintainer && request_cve_enabled
        expect(res).to equal(expected)
      end
    end
  end

  describe '#request_cve_enabled?' do
    where(
      gitlab_com: [true, false],
      setting_enabled: [true, false],
      visibility: [:PUBLIC, :INTERNAL, :PRIVATE]
    )
    with_them do
      before do
        allow(::Gitlab).to receive(:com?).and_return(gitlab_com)
        vis_val = Gitlab::VisibilityLevel.const_get(visibility, false)
        project.visibility_level = vis_val
        project.save!

        security_setting = ProjectSecuritySetting.safe_find_or_create_for(project)
        security_setting.cve_id_request_enabled = setting_enabled
        security_setting.save!
      end

      it "returns the correct value" do
        expected = gitlab_com && setting_enabled && visibility == :PUBLIC
        expect(helper.request_cve_enabled?(project)).to equal(expected)
      end
    end
  end

  def create_user(access_level_trait)
    user = create(:user)
    create(:project_member, access_level_trait, user: user, project: project)
    user
  end
end
