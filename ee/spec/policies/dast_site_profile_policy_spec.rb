# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteProfilePolicy do
  describe 'create_on_demand_dast_scan' do
    let(:record) { create(:dast_site_profile, project: project) }

    it_behaves_like 'a dast on-demand scan policy'
  end
end
