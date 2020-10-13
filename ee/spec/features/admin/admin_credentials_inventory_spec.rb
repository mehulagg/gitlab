# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Admin::CredentialsInventory' do
  include Spec::Support::Helpers::Features::ResponsiveTableHelpers

  before do
    sign_in(create(:admin))
  end

  context 'unlicensed' do
    before do
      stub_licensed_features(credentials_inventory: false)
    end

    it 'returns 404' do
      visit admin_credentials_path

      expect(page.status_code).to eq(404)
    end
  end

  context 'licensed' do
    before do
      stub_licensed_features(credentials_inventory: true)
    end

    context 'links' do
      before do
        visit admin_credentials_path
      end

      it 'has Credentials Inventory link in sidebar' do
        expect(page).to have_link('Credentials', href: admin_credentials_path)
      end

      context 'tabs' do
        it 'contains the relevant filter tabs' do
          expect(page).to have_link('Personal Access Tokens', href: admin_credentials_path(filter: 'personal_access_tokens'))
          expect(page).to have_link('SSH Keys', href: admin_credentials_path(filter: 'ssh_keys'))
        end
      end
    end

    context 'filtering' do
      context 'by Personal Access Tokens' do
        let(:credentials_path) { admin_credentials_path(filter: 'personal_access_tokens') }

        it_behaves_like 'credentials inventory personal access tokens'
      end

      context 'by SSH Keys' do
        let(:credentials_path) { admin_credentials_path(filter: 'ssh_keys') }

        it_behaves_like 'credentials inventory SSH keys'
      end
    end
  end
end
