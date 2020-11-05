# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidationPolicy do
  it_behaves_like 'a dast on-demand scan policy' do
    let_it_be(:record) { create(:dast_site_validation, dast_site_token: create(:dast_site_token, project: project)) }
  end
end
