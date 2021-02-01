# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EnableSearchSettingsHelper do
  describe '#enable_search_settings' do
    def before_content
      helper.content_for(:before_content)
    end

    it 'sets content for before_content' do
      expect(before_content).to be_nil

      helper.enable_search_settings

      expect(before_content).to eql(helper.render("shared/search_settings"))
    end
  end
end
