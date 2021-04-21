# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'admin/dev_ops_report/show.html.haml' do
  include Devise::Test::ControllerHelpers

  before do
    stub_licensed_features(devops_adoption: true)
  end

  context 'when show_adoption? returns false' do
    before do
      controller.singleton_class.class_eval do
        protected

        def show_adoption?
          false
        end

        helper_method :show_adoption?
      end
    end

    it 'disables the feature' do
      render

      expect(rendered).not_to have_selector('#devops-adoption')
    end
  end

  context 'when show_adoption? returns true' do
    before do
      controller.singleton_class.class_eval do
        protected

        def show_adoption?
          true
        end

        helper_method :show_adoption?
      end
    end

    it 'enables the feature' do
      render

      expect(rendered).to have_selector('#devops-adoption')
    end
  end
end
