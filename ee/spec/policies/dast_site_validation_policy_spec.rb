# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastSiteValidationPolicy do
  let(:record) { create(:dast_site_validation, dast_site_token: create(:dast_site_token, project: project)) }

  it_behaves_like 'a dast on-demand scan policy'
end
