# frozen_string_literal: true

if ENV.key?('BENCHMARK')
  require 'spec_helper'
  require 'erb'
  require 'benchmark/ips'

  # This benchmarks some of the Banzai pipelines and filters.
  # They are not definitive, but can be used by a developer to
  # get a rough idea how the changing or addition of a new filter
  # will effect performance.
  #
  # Run by:
  #   BENCHMARK=1 rspec spec/benchmarks/banzai_benchmark.rb
  #
  RSpec.describe 'GitLab Markdown Benchmark', :aggregate_failures do
    include MarkupHelper

    before do
      stub_application_setting(asset_proxy_enabled: true)
      stub_application_setting(asset_proxy_secret_key: 'shared-secret')
      stub_application_setting(asset_proxy_url: 'https://assets.example.com')
      stub_application_setting(asset_proxy_whitelist: %w(gitlab.com *.mydomain.com))

      Banzai::Filter::AssetProxyFilter.initialize_settings

      @feature = MarkdownFeature.new

      # `markdown` helper expects a `@project` and `@group` variable
      @project = @feature.project
      @group = @feature.group

      # @wiki = @feature.wiki
      # @wiki_page = @feature.wiki_page
      # path = 'images/example.jpg'
      # gitaly_wiki_file = Gitlab::GitalyClient::WikiFile.new(path: path)
      # allow(@wiki).to receive(:find_file).with(path).and_return(Gitlab::Git::WikiFile.new(gitaly_wiki_file))
      # allow(@wiki).to receive(:wiki_base_path) { '/namespace1/gitlabhq/wikis' }

      @markdown_text = @feature.raw_markdown
    end

    let!(:render_context) { Banzai::RenderContext.new(@project, current_user) }

    context 'pipelines' do
      before do
        @wiki = @feature.wiki
        @wiki_page = @feature.wiki_page
        path = 'images/example.jpg'
        gitaly_wiki_file = Gitlab::GitalyClient::WikiFile.new(path: path)
        allow(@wiki).to receive(:find_file).with(path).and_return(Gitlab::Git::WikiFile.new(gitaly_wiki_file))
        allow(@wiki).to receive(:wiki_base_path) { '/namespace1/gitlabhq/wikis' }
      end

      it 'benchmarks several pipelines' do
        Benchmark.ips do |x|
          x.config(time: 10, warmup: 2)

          x.report('Full pipeline') { markdown(@markdown_text, { pipeline: :full }) }
          x.report('Wiki pipeline') { markdown(@markdown_text, { pipeline: :wiki, wiki: @wiki, page_slug: @wiki_page.slug }) }
          x.report('Plain pipeline') { markdown(@markdown_text, { pipeline: :plain_markdown }) }

          x.compare!
        end
      end
    end

    context 'filters' do
      it 'benchmarks all filters in the FullPipeline' do
        pipeline       = Banzai::Pipeline[:full]
        context        = { project: @project, current_user: current_user, render_context: render_context }
        context        = Banzai::Filter::AssetProxyFilter.transform_context(context)
        filter_source  = {}
        input_text     = @markdown_text

        # build up the source text for each filter
        pipeline.filters.each do |filter_klass|
          filter_source[filter_klass] = input_text

          output = filter_klass.call(input_text, context)
          input_text = output
        end

        Benchmark.ips do |x|
          x.config(time: 10, warmup: 2)

          pipeline.filters.each do |filter_klass|
            x.report(filter_klass.name.demodulize) { filter_klass.call(filter_source[filter_klass], context) }
          end

          x.compare!
        end
      end

      it 'benchmarks all filters in the PlainMarkdownPipeline' do
        pipeline       = Banzai::Pipeline[:plain_markdown]
        context        = { project: @project, current_user: current_user, render_context: render_context }
        context        = Banzai::Filter::AssetProxyFilter.transform_context(context)
        filter_source  = {}
        input_text     = @markdown_text

        # build up the source text for each filter
        pipeline.filters.each do |filter_klass|
          filter_source[filter_klass] = input_text

          output = filter_klass.call(input_text, context)
          input_text = output
        end

        Benchmark.ips do |x|
          x.config(time: 10, warmup: 2)

          pipeline.filters.each do |filter_klass|
            x.report(filter_klass.name.demodulize) { filter_klass.call(filter_source[filter_klass], context) }
          end

          x.compare!
        end
      end
    end

    # Fake a `current_user` helper
    def current_user
      @feature.user
    end
  end
end
