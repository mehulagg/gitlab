# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebpackHelper do
  source = 'foo.js'
  asset_path = "/assets/webpack/#{source}"

  describe '#prefetch_link_tag' do
    before do
      allow(request).to receive(:send_early_hints).and_return(nil)
    end

    it 'returns prefetch link tag' do
      expect(prefetch_link_tag(source)).to eq('<link rel="prefetch" href="/foo.js">')
    end
  end

  describe '#webpack_preload_asset_tag' do

    before do
      allow(Gitlab::Webpack::Manifest).to receive(:asset_paths) { ["#{asset_path}"] }
    end

    it 'preloads by default' do
      expect(helper).to receive(:preload_link_tag).with(asset_path, {}).and_call_original

      output = helper.webpack_preload_asset_tag(source)

      expect(output).to eq('<link rel="preload" href="/assets/webpack/foo.js" as="script" type="text/javascript">')
    end

    it 'prefetches if explcitely asked' do
      expect(helper).to receive(:prefetch_link_tag).with(asset_path).and_call_original

      output = helper.webpack_preload_asset_tag(source, prefetch: true)

      expect(output).to eq('<link rel="prefetch" href="/assets/webpack/foo.js">')
    end
  end
end
