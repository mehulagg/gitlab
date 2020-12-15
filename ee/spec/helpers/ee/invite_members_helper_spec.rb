# frozen_string_literal: true

require "spec_helper"

RSpec.describe InviteMembersHelper do
  describe '#dropdown_invite_members_link' do
    shared_examples_for 'dropdown invite members link' do
      let(:link_regex) do
        /data-track-event="click_link".*data-track-label="invite_members_new_dropdown".*Invite members/
      end

      context 'with experiment enabled' do
        before do
          allow(helper).to receive(:experiment_enabled?).with(:invite_members_new_dropdown) { true }
        end

        it 'returns link' do
          link = helper.dropdown_invite_members_link(form_model)

          expect(link).to match(link_regex)
          expect(link).to include(link_href)
          expect(link).to include('gl-emoji')
        end
      end

      context 'with no experiment enabled' do
        before do
          allow(helper).to receive(:experiment_enabled?).with(:invite_members_new_dropdown) { false }
        end

        it 'returns link' do
          link = helper.dropdown_invite_members_link(form_model)

          expect(link).to match(link_regex)
          expect(link).to include(link_href)
          expect(link).not_to include('gl-emoji')
        end
      end
    end

    context 'with a project' do
      let_it_be(:form_model) { create(:project) }
      let(:link_href) { "href=\"#{project_project_members_path(form_model)}\"" }

      it_behaves_like 'dropdown invite members link'
    end

    context 'with a group' do
      let_it_be(:form_model) { create(:group) }
      let(:link_href) { "href=\"#{group_group_members_path(form_model)}\"" }

      it_behaves_like 'dropdown invite members link'
    end
  end
end
