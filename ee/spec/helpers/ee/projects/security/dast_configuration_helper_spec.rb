# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::DastConfigurationHelper do
  let_it_be(:project) { create(:project) }

  let(:security_configuration_path) { project_security_configuration_path(project) }
  let(:full_path) { project.full_path }
  let(:dast_documentation_path) { help_page_path('user/application_security/dast/index') }

  describe '#dast_configuration_data' do
    subject { helper.dast_configuration_data(project) }

    it {
      is_expected.to eq({
        security_configuration_path: security_configuration_path,
        full_path: full_path,
        dast_documentation_path: dast_documentation_path
      })
    }
  end
end
