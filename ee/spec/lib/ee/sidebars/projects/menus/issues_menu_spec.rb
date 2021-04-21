# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::IssuesMenu do
  let(:project) { build(:project) }
  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  subject { described_class.new(context) }

  describe 'Iterations' do
    context 'when licensed feature iterations is not enabled' do
      it 'does not include iterations menu item' do
        stub_licensed_features(iterations: false)

        expect(subject.items.index { |e| e.item_id == :iterations}).to be_nil
      end
    end

    context 'when licensed feature iterations is enabled' do
      before do
        stub_licensed_features(iterations: true)
      end
      context 'when user can read iterations' do
        it 'includes iterations menu item' do
          expect(subject.items.index { |e| e.item_id == :iterations}).to be_present
        end
      end

      context 'when user cannot read iterations' do
        let(:user) { nil }

        it 'does not include iterations menu item' do
          expect(subject.items.index { |e| e.item_id == :iterations}).to be_nil
        end
      end
    end
  end
end
