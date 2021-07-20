# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::RequirementsMenu do
  let(:project) { build(:project) }
  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  subject { described_class.new(context) }

  before do
    stub_licensed_features(requirements: true)
  end

  describe '#render?' do
    context 'when user cannot read requirements' do
      let(:user) { nil }

      it 'returns false' do
        expect(subject.render?).to eq false
      end
    end

    context 'when user can read requirements' do
      it 'returns true' do
        expect(subject.render?).to eq true
      end

      it 'does not contain any menu item' do
        expect(subject.renderable_items).to be_empty
      end
    end
  end
end
