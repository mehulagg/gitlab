# frozen_string_literal: true
require 'spec_helper'

RSpec.describe RoadmapsHelper do
  before do
    allow(helper).to receive(:current_user) { user }
  end

  describe '#roadmap_layout' do
    context 'guest' do
      let(:user) { nil }

      it 'is sourced from params if exists' do
        allow(helper).to receive(:params).and_return(layout: 'WEEKS')

        expect(helper.roadmap_layout).to eq('WEEKS')
      end

      it 'returns default if params do not exist' do
        allow(helper).to receive(:params).and_return({})

        expect(helper.roadmap_layout).to eq('MONTHS')
      end
    end

    context 'logged in' do
      let(:user) { double(:user) }

      it 'is sourced from User#roadmap_layout' do
        allow(helper).to receive(:params).and_return(layout: 'WEEKS')
        expect(user).to receive(:roadmap_layout).and_return('quarters')

        expect(helper.roadmap_layout).to eq('QUARTERS')
      end
    end
  end

  describe '#roadmap_sort_order' do
    let(:user_preference) { double(:user_preference) }

    before do
      allow(user).to receive(:user_preference).and_return(user_preference)
    end

    context 'guest' do
      let(:user) { nil }

      it 'returns default sort order' do
        expect(helper.roadmap_sort_order).to eq('start_date_asc')
      end
    end

    context 'user without preferences set' do
      let(:user) { double(:user) }

      it 'returns default sort order' do
        expect(user_preference).to receive(:roadmaps_sort).and_return(nil)

        expect(helper.roadmap_sort_order).to eq('start_date_asc')
      end
    end

    context 'user with preference set' do
      let(:user) { double(:user) }

      it 'returns saved user preference' do
        expect(user_preference).to receive(:roadmaps_sort).and_return('end_date_asc')

        expect(helper.roadmap_sort_order).to eq('end_date_asc')
      end
    end
  end
end
