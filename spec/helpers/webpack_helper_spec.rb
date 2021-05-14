# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebpackHelper do
  describe 'prefetch_link_tag' do
    it 'returns prefetch link tag' do
      source = '/foo.bar'

      expect(prefetch_link_tag(source)).to eq('<link rel="prefetch" href="/foo.bar">')
    end
  end
end
