# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'layouts/header/_new_dropdown' do
  let_it_be(:user) { create(:user) }

  before do
    allow(view).to receive(:current_user).and_return(user)
  end

  context 'general menu links' do
    it "renders a 'New project/repository' link" do
      render

      expect(rendered).to have_link('New project/repository', href: new_project_path)
    end
  end

  context 'group-specific links' do
    let_it_be(:group) { create(:group) }

    before do
      assign(:group, group)
    end

    it 'does not have "New epic" link' do
      render

      expect(rendered).not_to have_link('New epic', href: new_group_epic_path(group))
    end

    context 'as a Group owner' do
      before do
        group.add_owner(user)
      end

      context 'with the epics license' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'has a "New epic" link' do
          render

          expect(rendered).to have_link('New epic', href: new_group_epic_path(group))
        end
      end
    end
  end
end
