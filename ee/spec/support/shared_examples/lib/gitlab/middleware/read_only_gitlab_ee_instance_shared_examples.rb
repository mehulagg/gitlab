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

      context 'on Geo secondary' do
        before do
          allow(::Gitlab::Geo).to receive(:secondary?).and_return(true)
        end

        where(:description, :path) do
          'LFS request to batch'        | '/root/rouge.git/info/lfs/objects/batch'
          'LFS request to locks verify' | '/root/rouge.git/info/lfs/locks/verify'
          'LFS request to locks create' | '/root/rouge.git/info/lfs/locks'
          'LFS request to locks unlock' | '/root/rouge.git/info/lfs/locks/1/unlock'
          'to geo replication node api' | "/api/#{API::API.version}/geo_replication/designs/resync"
        end

        with_them do
          it "expects a POST #{description} URL to be allowed" do
            response = request.post(path)

            expect(response).not_to be_redirect
            expect(subject).not_to disallow_request
          end
        end
      end

      context 'when not on Geo secondary' do
        before do
          allow(::Gitlab::Geo).to receive(:secondary?).and_return(false)
        end

        where(:description, :path) do
          'LFS request to locks verify' | '/root/rouge.git/info/lfs/locks/verify'
          'LFS request to locks create' | '/root/rouge.git/info/lfs/locks'
          'LFS request to locks unlock' | '/root/rouge.git/info/lfs/locks/1/unlock'
        end

        with_them do
          it "expects a POST #{description} URL not to be allowed" do
            response = request.post(path)

            expect(response).to be_redirect
            expect(subject).to disallow_request
          end
        end
      end
    end

    it 'expects a POST request to git-receive-pack URL to be allowed' do
      response = request.post('/root/rouge.git/git-receive-pack')

      expect(response).not_to be_redirect
      expect(subject).not_to disallow_request
    end
  end
end
