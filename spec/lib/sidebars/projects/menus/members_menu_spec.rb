# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::MembersMenu do
  let(:project) { create(:project) }
  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project) }

  subject { described_class.new(context) }

  describe '#render?' do
    context 'when user cannot access members' do
      let(:user) { nil }

      it 'returns false' do
        expect(subject.render?).to eq false
      end
    end

    context 'when user can access members' do
      it 'returns true' do
        expect(subject.render?).to eq true
      end
    end
  end
end
