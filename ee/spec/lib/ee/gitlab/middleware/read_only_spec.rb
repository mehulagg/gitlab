# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Middleware::ReadOnly do
  include Rack::Test::Methods
  using RSpec::Parameterized::TableSyntax

  let(:rack_stack) do
    rack = Rack::Builder.new do
      use ActionDispatch::Session::CacheStore
      use ActionDispatch::Flash
    end

    rack.run(subject)
    rack.to_app
  end

  let(:observe_env) do
    Module.new do
      attr_reader :env

      def call(env)
        @env = env
        super
      end
    end
  end

  let(:request) { Rack::MockRequest.new(rack_stack) }

  subject do
    described_class.new(fake_app).tap do |app|
      app.extend(observe_env)
    end
  end

  context 'normal requests to a read-only GitLab instance' do
    let(:fake_app) { lambda { |env| [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

    before do
      allow(Gitlab::Database).to receive(:read_only?) { true }
    end

    shared_examples 'whitelisted request' do |request_type, request_url|
      it "expects a #{request_type.upcase} request to #{request_url} to be allowed" do
        expect(Rails.application.routes).to receive(:recognize_path).and_call_original
        response = request.send(request_type, request_url)

        expect(response).not_to be_redirect
        expect(subject).not_to disallow_request
      end
    end

    context 'whitelisted requests' do
      it_behaves_like 'whitelisted request', :patch, '/admin/geo/nodes/1'

      it_behaves_like 'whitelisted request', :delete, '/admin/geo/replication/projects/1'

      it_behaves_like 'whitelisted request', :post, '/admin/geo/replication/projects/1/resync'

      it_behaves_like 'whitelisted request', :post, '/admin/geo/replication/projects/1/reverify'

      it_behaves_like 'whitelisted request', :post, '/admin/geo/replication/projects/reverify_all'

      it_behaves_like 'whitelisted request', :post, '/admin/geo/replication/projects/resync_all'

      it_behaves_like 'whitelisted request', :post, '/admin/geo/replication/projects/1/force_redownload'

      it_behaves_like 'whitelisted request', :delete, '/admin/geo/replication/uploads/1'
    end

    it 'expects geo replication node api requests to be allowed' do
      response = request.post("/api/#{API::API.version}/geo_replication/designs/resync")

      expect(response).not_to be_redirect
      expect(subject).not_to disallow_request
    end
  end
end
