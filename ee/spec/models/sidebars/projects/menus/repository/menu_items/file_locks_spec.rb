# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::Repository::MenuItems::FileLocks do
  let(:project) { build(:project) }
  let(:context) { Sidebars::Projects::Context.new(current_user: nil, container: project) }

  subject { described_class.new(context) }

  describe '#render?' do
    before do
      stub_licensed_features(file_locks: license_feature_status)
    end

    context 'when project has the licensed feature' do
      let(:license_feature_status) { true }

      it 'returns true' do
        expect(subject.render?).to eq true
      end
    end

    context 'when project does not have the licensed feature' do
      let(:license_feature_status) { false }

      it 'returns false' do
        expect(subject.render?).to eq false
      end
    end
  end
end
