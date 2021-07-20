# frozen_string_literal: true

RSpec.shared_examples 'write access for a read-only GitLab (EE) instance' do
  include Rack::Test::Methods
  using RSpec::Parameterized::TableSyntax

  include_context 'with a mocked GitLab instance'

  context 'normal requests to a read-only GitLab instance' do
    let(:fake_app) { lambda { |env| [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }

    it_behaves_like 'allowlisted /admin/geo requests'

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
        'git-receive-pack'            | '/root/rouge.git/git-receive-pack'
      end

      with_them do
        it "expects a POST #{description} URL to be allowed" do
          response = request.post(path)

          expect(response).not_to be_redirect
          expect(subject).not_to disallow_request
        end

        it "expects a POST #{description} URL with a trailing slash to be allowed" do
          response = request.post("#{path}/")

          expect(response).not_to be_redirect
          expect(subject).not_to disallow_request
        end
      end
    end
  end
end
