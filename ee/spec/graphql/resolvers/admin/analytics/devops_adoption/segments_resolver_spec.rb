# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::Analytics::DevopsAdoption::SegmentsResolver do
  include GraphqlHelpers

  let_it_be(:admin_user) { create(:user, :admin) }
  let(:current_user) { admin_user }

  def resolve_segments(args = {}, context = {})
    resolve(described_class, args: args, ctx: context)
  end

  describe '#resolve' do
    let_it_be(:user) { create(:user) }
    let_it_be(:segment_1) { create(:devops_adoption_segment, namespace: create(:group, name: 'bbb')) }
    let_it_be(:segment_2) { create(:devops_adoption_segment, namespace: create(:group, name: 'aaa')) }

    subject { resolve_segments({}, { current_user: current_user }) }

    before do
      stub_licensed_features(instance_level_devops_adoption: true)
    end

    context 'when requesting project count measurements' do
      context 'as an admin user' do
        let(:current_user) { admin_user }

        it 'returns the records, ordered by name' do
          expect(subject).to eq([segment_2, segment_1])
        end
      end

      context 'when the feature is not available' do
        let(:current_user) { admin_user }

        before do
          stub_licensed_features(instance_level_devops_adoption: false)
        end

        it 'returns the records, ordered by name' do
          expect(subject).to be_empty
        end
      end

      context 'as a non-admin user' do
        let(:current_user) { user }

        it 'raises ResourceNotAvailable error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'as an unauthenticated user' do
        let(:current_user) { nil }

        it 'raises ResourceNotAvailable error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end
  end
end
