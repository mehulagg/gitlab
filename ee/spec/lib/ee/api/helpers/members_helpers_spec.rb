# frozen_string_literal: true
require 'spec_helper'

RSpec.describe EE::API::Helpers::MembersHelpers do
  let(:members_helpers) { Class.new.include(described_class).new }

  before do
    allow(members_helpers).to receive(:current_user).and_return(create(:user))
  end

  shared_examples 'creates security_event' do |source_type|
    context "with :source_type == #{source_type.pluralize}" do
      it 'creates security_event' do
        security_event = members_helpers.log_audit_event(member)

        expect(security_event.entity_id).to eq(source.id)
        expect(security_event.entity_type).to eq(source_type.capitalize)
        expect(security_event.details.fetch(:target_id)).to eq(member.id)
      end
    end
  end

  describe '#log_audit_event' do
    subject { members_helpers }

    it_behaves_like 'creates security_event', 'group' do
      let(:source) { create(:group) }
      let(:member) { create(:group_member, :owner, group: source, user: create(:user)) }
    end

    it_behaves_like 'creates security_event', 'project' do
      let(:source) { create(:project) }
      let(:member) { create(:project_member, project: source, user: create(:user)) }
    end
  end

  describe '#billed_users_for' do
    let_it_be(:group) { create(:group) }
    let_it_be(:maria) { create(:group_member, group: group, user: create(:user, name: 'Maria Gomez')) }
    let_it_be(:john_smith) { create(:group_member, group: group, user: create(:user, name: 'John Smith')) }
    let_it_be(:john_doe) { create(:group_member, group: group, user: create(:user, name: 'John Doe')) }
    let_it_be(:sophie) { create(:group_member, group: group, user: create(:user, name: 'Sophie Dupont')) }
    let(:search_term) { nil }
    let(:order_by) { nil }

    subject { members_helpers.billed_users_for(group, search_term, order_by) }

    context 'when a search parameter is present' do
      let(:search_term) { 'John' }

      context 'when a sorting parameter is provided (eg name descending)' do
        let(:order_by) { 'name_desc' }

        it 'sorts results accordingly' do
          expect(subject).to eq([john_smith, john_doe].map(&:user))
        end
      end

      context 'when a sorting parameter is not provided' do
        let(:order_by) { nil }

        it 'sorts results by name ascending' do
          expect(subject).to eq([john_doe, john_smith].map(&:user))
        end
      end
    end

    context 'when a search parameter is not present' do
      it 'returns expected users in name asc order' do
        allow(group).to receive(:billed_user_members).and_return([john_doe, john_smith, sophie, maria])

        expect(subject).to eq([john_doe, john_smith, maria, sophie].map(&:user))
      end

      context 'and when a sorting parameter is provided (eg name descending)' do
        let(:order_by) { 'name_desc' }

        it 'sorts results accordingly' do
          expect(subject).to eq([sophie, maria, john_smith, john_doe].map(&:user))
        end
      end
    end
  end
end
