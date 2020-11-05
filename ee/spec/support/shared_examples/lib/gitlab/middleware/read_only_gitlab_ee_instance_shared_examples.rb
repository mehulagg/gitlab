# frozen_string_literal: true

RSpec.shared_examples 'write access for a read-only GitLab (EE) instance' do
  include Rack::Test::Methods
  using RSpec::Parameterized::TableSyntax

  include_context 'with a mocked GitLab instance'

  context 'normal requests to a read-only GitLab instance' do
    let(:fake_app) { lambda { |env| [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

    shared_examples 'allowlisted request' do |request_type, request_url|
      it "expects a #{request_type.upcase} request to #{request_url} to be allowed" do
        expect(Rails.application.routes).to receive(:recognize_path).and_call_original
        response = request.send(request_type, request_url)

        expect(response).not_to be_redirect
        expect(subject).not_to disallow_request
      end
    end

    context 'allowlisted requests' do
      it_behaves_like 'allowlisted request', :patch, '/admin/geo/nodes/1'

      it_behaves_like 'allowlisted request', :delete, '/admin/geo/replication/projects/1'

      it_behaves_like 'allowlisted request', :post, '/admin/geo/replication/projects/1/resync'

      it_behaves_like 'allowlisted request', :post, '/admin/geo/replication/projects/1/reverify'

      it_behaves_like 'allowlisted request', :post, '/admin/geo/replication/projects/reverify_all'

      it_behaves_like 'allowlisted request', :post, '/admin/geo/replication/projects/resync_all'

      it_behaves_like 'allowlisted request', :post, '/admin/geo/replication/projects/1/force_redownload'

      it_behaves_like 'allowlisted request', :delete, '/admin/geo/replication/uploads/1'
    end

    it 'expects geo replication node api requests to be allowed' do
      response = request.post("/api/#{API::API.version}/geo_replication/designs/resync")

      expect(response).not_to be_redirect
      expect(subject).not_to disallow_request
    end
  end
end
