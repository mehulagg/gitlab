# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NavHelper do
  describe '#iterations_sub_menu_controllers' do
    context 'when :iteration_cadences is turned on' do
      it 'includes iteration_cadences#index path in the list' do
        expect(helper.iterations_sub_menu_controllers).to include('iteration_cadences#index')
      end
    end

    context 'when :iteration_cadences is NOT turned on' do
      before do
        stub_feature_flags(iteration_cadences: false)
      end

      it 'includes iteration_cadences#index path in the list' do
        expect(helper.iterations_sub_menu_controllers).not_to include('iteration_cadences#index')
      end
    end
  end
end
