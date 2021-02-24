# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Banzai::Filter::SanitizationFilter do
  include FilterSpecHelper

  describe 'custom allowlist' do
    it 'sanitizes `class` attribute from a' do
      act = '<a class="k" href="http://example.com/url">Link</a>'

      expect(filter(act).to_html).to eq('<a href="http://example.com/url">Link</a>')
    end

    it 'allows `with-attachment-icon` class in `a` elements' do
      html = '<a class="with-attachment-icon" href="http://example.com/jira.png">http://example.com/jira.png</a>'

      doc = filter(html)

      expect(doc.at_css('a')['class']).to eq('with-attachment-icon')
    end
  end
end
