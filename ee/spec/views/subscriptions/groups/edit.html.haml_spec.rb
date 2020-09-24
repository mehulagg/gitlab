# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'subscriptions/groups/edit' do
  before do
    assign(:group, Group.new)

    allow(view).to receive(:params).and_return(quantity: quantity)
    allow(view).to receive(:plan_title).and_return('Bronze')
    allow(view).to receive(:group_path).and_return('')
    allow(view).to receive(:subscriptions_groups_path).and_return('')
    allow(view).to receive(:current_user).and_return(User.new)
  end

  let(:quantity) { '1' }

  context 'a single user' do
    it 'displays the correct notification for 1 user' do
      render

      expect(rendered).to have_text('You have successfully purchased a Bronze plan subscription for 1 user. You’ll receive a receipt via email.')
    end
  end

  context 'multiple users' do
    let(:quantity) { '2' }

    it 'displays the correct notification for 2 users' do
      render

      expect(rendered).to have_text('You have successfully purchased a Bronze plan subscription for 2 users. You’ll receive a receipt via email.')
    end
  end

  context 'with new_user in the params' do
    before do
      allow(view).to receive(:params).and_return(new_user: 'true')
    end

    it 'displays the progress bar' do
      render

      expect(rendered).to have_selector('#progress-bar')
    end
  end

  context 'without new_user in the params' do
    it 'does not display the progress bar' do
      render

      expect(rendered).not_to have_selector('#progress-bar')
    end
  end
end
