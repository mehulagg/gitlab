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
        security_event = subject.log_audit_event(member)

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
end
