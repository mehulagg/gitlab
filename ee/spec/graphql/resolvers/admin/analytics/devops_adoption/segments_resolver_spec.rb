# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::Analytics::DevopsAdoption::SegmentsResolver do
  include GraphqlHelpers

  let_it_be(:admin_user) { create(:user, :admin) }

  def resolve_segments(args = {}, context = {})
    resolve(described_class, args: args, ctx: context)
  end

  before do
    stub_licensed_features(instance_level_devops_adoption: true, group_level_devops_adoption: true)
  end

  describe '#resolve' do
    let_it_be(:user) { create(:user) }
    let_it_be(:root_group_1) { create(:group, name: 'bbb') }
    let_it_be(:root_group_2) { create(:group, name: 'aaa') }
    let_it_be(:segment_1) { create(:devops_adoption_segment, namespace: root_group_1, display_namespace: root_group_1) }
    let_it_be(:segment_2) { create(:devops_adoption_segment, namespace: root_group_1, display_namespace: nil) }
    let_it_be(:segment_3) { create(:devops_adoption_segment, namespace: root_group_2, display_namespace: root_group_2) }
    let_it_be(:segment_4) { create(:devops_adoption_segment, namespace: root_group_2, display_namespace: nil) }

    subject(:resolved_segments) { resolve_segments(params, { current_user: current_user }) }

    let(:params) { {} }

    context 'for instance level', :enable_admin_mode do
      let(:current_user) { admin_user }

      context 'as an admin user' do
        it 'returns segments for all groups without display_namespace' do
          expect(resolved_segments).to match_array([segment_2, segment_4])
        end
      end

      context 'as a non-admin user' do
        let(:current_user) { user }

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the feature is not available' do
        before do
          stub_licensed_features(instance_level_devops_adoption: false)
        end

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end

    context 'for group level' do
      let(:params) { { display_namespace_id: root_group_1.to_gid.to_s } }
      let(:current_user) { user }

      context 'for reporter+' do
        before do
          root_group_1.add_reporter(user)
        end

        it 'returns segments for given parent group and its descendants' do
          expect(resolved_segments).to eq([segment_1])
        end
      end

      context 'for guests' do
        before do
          root_group_1.add_guest(user)
        end

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the feature is not available' do
        before do
          stub_licensed_features(instance_level_devops_adoption: false)
        end

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end
  end
end
