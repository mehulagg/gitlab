# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DastScannerProfilePolicy do
  let(:record) { create(:dast_scanner_profile, project: project) }

  it_behaves_like 'a dast on-demand scan policy'
end
