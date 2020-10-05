# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Update a DAST Scanner Profile' do
  include GraphqlHelpers

  let!(:dast_scanner_profile) { create(:dast_scanner_profile, project: project, target_timeout: 200, spider_timeout: 5000) }
  let!(:dast_scanner_profile_1) { create(:dast_scanner_profile, project: project) }

  let_it_be(:new_profile_name) { SecureRandom.hex }
  let(:new_target_timeout) { dast_scanner_profile.target_timeout + 1 }
  let(:new_spider_timeout) { dast_scanner_profile.spider_timeout + 1 }

  let(:mutation_name) { :dast_scanner_profile_update }
  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: full_path,
      id: dast_scanner_profile.to_global_id.to_s,
      profile_name: new_profile_name,
      target_timeout: new_target_timeout,
      spider_timeout: new_spider_timeout
    )
  end

  def mutation_response
    graphql_mutation_response(:dast_scanner_profile_update)
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'

  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'updates the dast_scanner_profile' do
      subject

      dast_scanner_profile = GlobalID.parse(mutation_response['id']).find

      aggregate_failures do
        expect(dast_scanner_profile.name).to eq(new_profile_name)
        expect(dast_scanner_profile.target_timeout).to eq(new_target_timeout)
        expect(dast_scanner_profile.spider_timeout).to eq(new_spider_timeout)
      end
    end

    context 'when there is an issue updating the dast_scanner_profile' do
      let(:new_profile_name) { dast_scanner_profile_1.name }

      it_behaves_like 'a mutation that returns errors in the response', errors: ['Name has already been taken']
    end

    context 'when the dast_scanner_profile does not exist' do
      before do
        dast_scanner_profile.destroy!
      end

      it_behaves_like 'a mutation that returns errors in the response', errors: ['Scanner profile not found for given parameters']
    end

    context 'when the dast_scanner_profile belongs to a different project' do
      let(:mutation) do
        graphql_mutation(
          mutation_name,
          full_path: create(:project).full_path,
          id: dast_scanner_profile.to_global_id.to_s,
          profile_name: new_profile_name,
          target_timeout: new_target_timeout,
          spider_timeout: new_spider_timeout
        )
      end

      it_behaves_like 'a mutation that returns a top-level access error'
    end
  end
end
