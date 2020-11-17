# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Packages::Nuget::ServiceIndexPresenter do
  let_it_be(:project) { create(:project) }
  let_it_be(:group) { create(:group) }

  let(:presenter) { described_class.new(target) }

  describe '#version' do
    subject { presenter.version }

    context 'for a group' do
      let(:target) { group }

      it { is_expected.to eq '3.0.0' }
    end

    context 'for a project' do
      let(:target) { project }

      it { is_expected.to eq '3.0.0' }
    end
  end

  describe '#resources' do
    subject { presenter.resources }

    shared_examples 'returning valid resources' do |resources_count: 8, publish_service: true|
      it 'has valid resources' do
        expect(subject.size).to eq resources_count
        subject.each do |resource|
          %i[@id @type comment].each do |field|
            expect(resource).to have_key(field)
            expect(resource[field]).to be_a(String)
          end
        end
      end

      it 'returns or not a publish service url' do
        if publish_service
          expect(subject.map { |resource| resource[:comment] }).to include('Push and delete (or unlist) packages.')
        else
          expect(subject.map { |resource| resource[:comment] }).not_to include('Push and delete (or unlist) packages.')
        end
      end
    end

    context 'for a group' do
      let(:target) { group }

      # at the group level we don't have the publish service
      it_behaves_like 'returning valid resources', resources_count: 7, publish_service: false
    end

    context 'for a project' do
      let(:target) { project }

      it_behaves_like 'returning valid resources'
    end
  end
end
