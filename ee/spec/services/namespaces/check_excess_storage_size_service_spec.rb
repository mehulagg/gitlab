# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespaces::CheckExcessStorageSizeService, '#execute' do
  let(:namespace) { build(:namespace, additional_purchased_storage_size: additional_purchased_storage_size) }
  let(:user) { build(:user, namespace: namespace) }
  let(:service) { described_class.new(namespace, user) }
  let(:total_repository_size_excess) { 150.megabytes }
  let(:additional_purchased_storage_size) { 100 }
  let(:additional_repo_storage_by_namespace_enabled) { true }
  let(:actual_size_limit) { 10.gigabytes }
  let(:locked_project_count) { 1 }

  subject(:response) { service.execute }

  before do
    allow(namespace).to receive(:additional_repo_storage_by_namespace_enabled?).and_return(additional_repo_storage_by_namespace_enabled)
    allow(namespace).to receive(:root_ancestor).and_return(namespace)
    allow(namespace).to receive(:total_repository_size_excess).and_return(total_repository_size_excess)
    allow(namespace).to receive(:actual_size_limit).and_return(actual_size_limit)
    allow(namespace).to receive(:repository_size_excess_project_count).and_return(locked_project_count)
  end

  context 'when additional_repo_storage_by_namespace_enabled is false' do
    let(:additional_repo_storage_by_namespace_enabled) { false }

    it { is_expected.to be_success }
  end

  context 'when additional_purchased_storage_size is set to 0' do
    let(:additional_purchased_storage_size) { 0 }

    context 'when current size is greater than 0' do
      it 'is successful and has no payload' do
        expect(response).to be_error
        expect(response.message).to be_present
      end
    end

    context 'when current size is 0' do
      let(:total_repository_size_excess) { 0 }

      it 'is successful and has no payload' do
        expect(response).to be_success
        expect(response.payload).to be_empty
      end
    end
  end

  context 'when current size is below threshold' do
    let(:total_repository_size_excess) { 10.megabytes }

    it 'is successful and has no payload' do
      expect(response).to be_success
      expect(response.payload).to be_empty
    end
  end

  context 'when not admin of the namespace' do
    let(:user) { build(:user) }

    it 'errors and has no payload' do
      expect(response).to be_error
      expect(response.payload).to be_empty
    end
  end

  context 'when providing the child namespace' do
    let(:namespace) { build(:group) }
    let(:child_namespace) { build(:group, parent: namespace) }

    subject(:response) { described_class.new(child_namespace, user).execute }

    before do
      allow(child_namespace).to receive(:root_ancestor).and_return(namespace)
      namespace.add_owner(user)
    end

    it 'uses the root namespace' do
      expect(response).to be_error
    end
  end

  describe 'payload alert_level' do
    subject { service.execute.payload[:alert_level] }

    context 'when above info threshold' do
      let(:total_repository_size_excess) { 50.megabytes }

      it { is_expected.to eq(:info) }
    end

    context 'when above warning threshold' do
      let(:total_repository_size_excess) { 75.megabytes }

      it { is_expected.to eq(:warning) }
    end

    context 'when above alert threshold' do
      let(:total_repository_size_excess) { 95.megabytes }

      it { is_expected.to eq(:alert) }
    end

    context 'when above error threshold' do
      let(:total_repository_size_excess) { 100.megabytes }

      it { is_expected.to eq(:error) }
    end
  end

  describe 'payload explanation_message' do
    subject(:response) { service.execute.payload[:explanation_message] }

    context 'when above limit' do
      let(:total_repository_size_excess) { 110.megabytes }

      context 'when namespace purchased additional storage' do
        it 'returns message that the additional storage has been consumed' do
          expect(response).to include("You have consumed all of your additional storage")
        end
      end

      context 'when namespace did not purchase additional storage' do
        let(:additional_purchased_storage_size) { 0 }

        it 'returns message to purchase additional storage' do
          expect(response).to include("Please purchase additional storage")
        end
      end
    end

    context 'when below limit' do
      let(:total_repository_size_excess) { 60.megabytes }

      it { is_expected.to include('If you reach 100% storage capacity') }
    end
  end

  describe 'payload usage_message' do
    let(:total_repository_size_excess) { 60.megabytes }

    subject(:response) { service.execute.payload[:usage_message] }

    before do
      allow(namespace).to receive(:contains_locked_projects?).and_return(contains_locked_projects)
    end

    context 'when namespace contains locked projects' do
      let(:contains_locked_projects) { true }

      context 'when there is additional storage' do
        context 'with one locked project' do
          it 'returns message about containing a locked project' do
            expect(response).to include("#{locked_project_count} locked project")
          end
        end

        context 'with multiple projects' do
          let(:locked_project_count) { 3 }

          it 'returns a pluralized message about locked projects' do
            expect(response).to include("#{locked_project_count} locked projects")
          end
        end
      end

      context 'when there is no additional storage' do
        let(:additional_purchased_storage_size) { 0 }
        let(:locked_project_count) { 3 }

        it 'returns message to have reached the free storage limit' do
          expect(response).to include("You have reached the free storage limit of 10 GB")
          expect(response).to include("one or more projects")
        end
      end
    end

    context 'when namespace does not contain locked projects' do
      let(:contains_locked_projects) { false }

      it 'returns current usage information' do
        expect(response).to include("60 MB of 100 MB")
        expect(response).to include("60%")
      end
    end
  end

  describe 'payload root_namespace' do
    subject(:response) { service.execute.payload[:root_namespace] }

    it { is_expected.to eq(namespace) }
  end
end
