# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Subscriptions::IssueUpdated do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :private) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:unauthorized_user) { create(:user) }

  it { expect(described_class).to have_graphql_arguments(:project_path, :iid) }
  it { expect(described_class.payload_type).to eq(Types::IssueType) }

  describe '#authorized?' do
    let(:project_path) { project.full_path }
    let(:iid) { issue.iid }

    subject { resolver.authorized?(project_path: project_path, iid: iid) }

    shared_examples 'checks issue permissions' do
      context 'unauthorized user' do
        let(:current_user) { unauthorized_user }

        it { is_expected.to be_falsey }
      end

      context 'authorized user' do
        let(:current_user) { issue.author }

        it { is_expected.to eq(true) }
      end
    end

    context 'on subscribe' do
      let(:resolver) { resolver_instance(described_class, ctx: { current_user: current_user }, subscription_update: false) }

      it_behaves_like 'checks issue permissions'

      context 'when project does not exist' do
        let(:current_user) { issue.author }
        let(:project_path) { 'non_existent_project_path' }

        it { is_expected.to be_falsey }
      end

      context 'when issue does not exist' do
        let(:current_user) { issue.author }
        let(:iid) { non_existing_record_id }

        it { is_expected.to be_falsey }
      end
    end

    context 'on update' do
      let(:resolver) { resolver_instance(described_class, obj: issue, ctx: { current_user: current_user }, subscription_update: true) }

      it_behaves_like 'checks issue permissions'
    end
  end
end
