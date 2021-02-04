# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Deleting a DAST Profile' do
  include GraphqlHelpers

  let!(:dast_profile) { create(:dast_profile, project: project) }

  let(:mutation_name) { :dast_profile_delete }

  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: project.full_path,
      id: global_id_of(dast_profile)
    )
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'

  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'deletes the dast_profile' do
      expect { subject }.to change { Dast::Profile.count }.from(1).to(0)
    end
  end
end
