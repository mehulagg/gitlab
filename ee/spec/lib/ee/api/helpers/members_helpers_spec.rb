# frozen_string_literal: true
require 'spec_helper'

RSpec.describe EE::API::Helpers::MembersHelpers do
  subject(:members_helpers) { Class.new.include(described_class).new }

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
    it_behaves_like 'creates security_event', 'group' do
      let(:source) { create(:group) }
      let(:member) { create(:group_member, :owner, group: source, user: create(:user)) }
    end

    it_behaves_like 'creates security_event', 'project' do
      let(:source) { create(:project) }
      let(:member) { create(:project_member, project: source, user: create(:user)) }
    end
  end

  describe '#paginate_billable_from_user_ids' do
    subject(:members_helpers) { Class.new.include(described_class, API::Helpers::Pagination).new }

    let_it_be(:users) { create_list(:user, 3) }
    let(:user_ids) { users.map(&:id) }
    let(:page) { 1 }
    let(:per_page) { 2 }

    before do
      allow(members_helpers).to receive(:params).and_return({ page: page, per_page: per_page })
      allow(members_helpers).to receive(:header) { }
      allow(members_helpers).to receive(:request).and_return(double(:request, url: ''))
    end

    it 'returns paginated User array in asc order' do
      results = members_helpers.paginate_billable_from_user_ids(user_ids.reverse)

      expect(results).to all be_a(User)
      expect(results.size).to eq(per_page)
      expect(results.map { |result| result.id }).to eq(user_ids.first(2))
    end

    context 'when page is 2' do
      let(:page) { 2 }

      it 'returns User as paginated array' do
        results = members_helpers.paginate_billable_from_user_ids(user_ids.reverse)

        expect(results.size).to eq(1)
        expect(results.map { |result| result.id }).to contain_exactly(user_ids.last)
      end
    end
  end
end
