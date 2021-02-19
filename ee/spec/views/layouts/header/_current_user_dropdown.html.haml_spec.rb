# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/header/_current_user_dropdown' do
  let_it_be(:user) { create(:user) }

  describe 'Upgrade link in user dropdown' do
    let(:on_upgradeable_plan) { true }

    before do
      allow(view).to receive(:current_user).and_return(user)
      allow(view).to receive(:show_upgrade_link?).and_return(on_upgradeable_plan)

      render
    end

    subject { rendered }

    context 'when user is on an upgradeable plan' do
      it 'displays the Upgrade link' do
        expect(subject).to have_link('Upgrade')
      end
    end

    context 'when user is not on an upgradeable plan' do
      let(:on_upgradeable_plan) { false }

      it 'does not display the Upgrade link' do
        expect(subject).not_to have_link('Upgrade')
      end
    end
  end
end
