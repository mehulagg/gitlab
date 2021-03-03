# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Auth::ContainerRegistryAuthenticationService do
  include AdminModeHelper

  context 'in maintenance mode' do
    include_context 'container registry auth service context'

    let_it_be(:current_user) { create(:user) }
    let_it_be(:project) { create(:project) }

    let(:log_data) do
      {
        message: 'Write access denied in maintenance mode',
        write_access_denied_in_maintenance_mode: true
      }
    end

    before do
      stub_maintenance_mode_setting(true)
      project.add_developer(current_user)
    end

    context 'allows developer to pull images' do
      let(:current_params) do
        { scopes: ["repository:#{project.full_path}:pull"] }
      end

      it_behaves_like 'a pullable'
    end

    context 'does not allow developer to push images' do
      let(:current_params) do
        { scopes: ["repository:#{project.full_path}:push"] }
      end

      it_behaves_like 'not a container repository factory'
      it_behaves_like 'logs an auth warning', ['push']
    end

    context 'does not allow developer to delete images' do
      let(:current_params) do
        { scopes: ["repository:#{project.full_path}:delete"] }
      end

      it_behaves_like 'not a container repository factory'
      it_behaves_like 'logs an auth warning', ['delete']
    end
  end

  context 'when not in maintenance mode' do
    it_behaves_like 'a container registry auth service'
  end
end
