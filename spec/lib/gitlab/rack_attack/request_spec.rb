# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::RackAttack::Request do
  using RSpec::Parameterized::TableSyntax

  def build_request(method:, path:, **params)
    Rack::Attack::Request.new(params.merge(Rack::PATH_INFO => path, Rack::REQUEST_METHOD => method))
  end

  describe "#git_http_request?" do
    where(:method, :path, :expected) do
      'GET'  | '/random/path' | false
      'GET'  | '/somthing/something.git/something' | false
      'GET'  | '/something/something.git/info/refs' | true
      'POST' | '/something/something.git/info/refs' | false
      'POST' | '/something/something.git/git-upload-pack' | true
      'GET'  | '/something/something.git/git-upload-pack' | false
      'GET'  | '/something/something.git/git-receive-pack' | false
      'POST' | '/something/something.git/git-receive-pack' | true
      'POST' | '/something/something.git/info/lfs/objects/batch' | true
      'POST' | '/something/something.git/info/lfs/objects' | true
      'GET' | '/something/something.git/info/lfs/objects/deadbeef' | true
      'GET' | '/something/something.git/info/lfs/locks' | true
      'PUT' | '/something/something.git/info/lfs/locks/id' | true
      'POST' | '/something/something.git/info/lfs/locks' | true
      'DELETE' | '/something/something.git/info/lfs/locks/id' | true
      'POST' | '/something/something.git/info/lfs/locks/id/unlock' | true
      'POST' | '/something/something.git/info/lfs/locks/verify' | true
      'PUT' | '/something/something.git/gitlab-lfs/objects/deadbeaf/123/authorize' | true
      'PUT' | '/something/something.git/gitlab-lfs/objects/deadbeaf/123' | true
    end

    with_them do
      it { expect(build_request(method: method, path: path).git_http_request?).to eq(expected) }
    end

    it 'does not try to match a request that does not contain .git in the url' do
      request = build_request(method: "GET", path: "/something/something/info/refs")

      expect(Gitlab::Application.routes).not_to receive(:recognize_path)

      request.git_http_request?
    end
  end

  describe '#possibly_authenticated_git_request?' do
    where(:headers, :git_request, :expected) do
      {} | false | false
      { 'HTTP_AUTHORIZATION' => 'Basic deadbeef' } | false | false
      { 'HTTP_AUTHORIZATION' => 'Basic deadbeef' } | true | true
    end

    with_them do
      it do
        request = build_request(path: "/stubbed/anyway", method: "GET", **headers)

        allow(request).to receive(:git_http_request?).and_return(git_request)

        expect(request.possibly_authenticated_git_request?).to eq(expected)
      end
    end
  end
end
