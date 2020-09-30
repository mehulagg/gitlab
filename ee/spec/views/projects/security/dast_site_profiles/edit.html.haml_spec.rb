# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "projects/security/dast_site_profiles/edit", type: :view do
  let_it_be(:site_profile) { create(:dast_site_profile) }
  let_it_be(:site_profile_gid) { ::URI::GID.parse("gid://gitlab/DastSiteProfile/#{site_profile.id}") }

  before do
    assign(:project, site_profile.project)
    assign(:site_profile, site_profile)
    assign(:site_profile_gid, site_profile_gid)
    render
  end

  it 'renders Vue app root' do
    expect(rendered).to have_selector('.js-dast-site-profile-form')
  end

  it 'passes project\'s full path' do
    expect(rendered).to include site_profile.project.path_with_namespace
  end

  it 'passes DAST profiles library URL' do
    expect(rendered).to include '/security/configuration/dast_profiles#site-profiles'
  end

  it 'passes DAST site profile\'s data' do
    expect(rendered).to include site_profile_gid.to_s
    expect(rendered).to include site_profile.name
    expect(rendered).to include site_profile.dast_site.url
  end
end
