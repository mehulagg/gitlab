# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::Security::ApiFuzzingConfigurationHelper do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let(:full_path) { project.full_path }
  let(:api_fuzzing_documentation_path) { help_page_path('user/application_security/api_fuzzing/index') }
  let(:api_fuzzing_authentication_documentation_path) { help_page_path('user/application_security/api_fuzzing/index', anchor: 'authentication') }
  let(:ci_variables_documentation_path) { help_page_path('ci/variables/README') }
  let(:project_ci_settings_path) { project_settings_ci_cd_path(project) }

  subject { helper.api_fuzzing_configuration_data(project) }

  before do
    allow(helper).to receive(:current_user).and_return(user)
  end

  describe '#api_fuzzing_configuration_data' do
    context 'user with set_pipeline_variables permissions' do
      before do
        allow(helper).to receive(:can?).with(user, :set_pipeline_variables, project).and_return(true)
      end

      it {
        is_expected.to eq(
          full_path: full_path,
          api_fuzzing_documentation_path: api_fuzzing_documentation_path,
          api_fuzzing_authentication_documentation_path: api_fuzzing_authentication_documentation_path,
          ci_variables_documentation_path: ci_variables_documentation_path,
          project_ci_settings_path: project_ci_settings_path,
          can_set_project_ci_variables: 'true'
        )
      }
    end

    context 'user without set_pipeline_variables permissions' do
      before do
        allow(helper).to receive(:can?).with(user, :set_pipeline_variables, project).and_return(false)
      end

      it {
        is_expected.to eq(
          full_path: full_path,
          api_fuzzing_documentation_path: api_fuzzing_documentation_path,
          api_fuzzing_authentication_documentation_path: api_fuzzing_authentication_documentation_path,
          ci_variables_documentation_path: ci_variables_documentation_path,
          project_ci_settings_path: project_ci_settings_path,
          can_set_project_ci_variables: 'false'
        )
      }
    end
  end
end
