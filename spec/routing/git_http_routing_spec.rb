# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'git_http routing' do
  shared_examples 'git repository routes' do
    let(:params) { { repository_path: path.delete_prefix('/') } }

    it 'routes Git endpoints' do
      expect(get("#{path}/info/refs")).to route_to('repositories/git_http#info_refs', **params)
      expect(post("#{path}/git-upload-pack")).to route_to('repositories/git_http#git_upload_pack', **params)
      expect(post("#{path}/git-receive-pack")).to route_to('repositories/git_http#git_receive_pack', **params)
    end

    context 'requests without .git format' do
      let(:base_path) { path.delete_suffix('.git') }

      it 'redirects requests to /info/refs', type: :request do
        expect(get("#{base_path}/info/refs")).to redirect_to("#{base_path}.git/info/refs")
        expect(get("#{base_path}/info/refs?service=git-upload-pack")).to redirect_to("#{base_path}.git/info/refs?service=git-upload-pack")
        expect(get("#{base_path}/info/refs?service=git-receive-pack")).to redirect_to("#{base_path}.git/info/refs?service=git-receive-pack")
      end

      it 'does not redirect other requests' do
        expect(post("#{base_path}/git-upload-pack")).not_to be_routable
      end
    end

    it 'routes LFS endpoints' do
      oid = generate(:oid)

      expect(post("#{path}/info/lfs/objects/batch")).to route_to('repositories/lfs_api#batch', **params)
      expect(post("#{path}/info/lfs/objects")).to route_to('repositories/lfs_api#deprecated', **params)
      expect(get("#{path}/info/lfs/objects/#{oid}")).to route_to('repositories/lfs_api#deprecated', oid: oid, **params)

      expect(post("#{path}/info/lfs/locks/123/unlock")).to route_to('repositories/lfs_locks_api#unlock', id: '123', **params)
      expect(post("#{path}/info/lfs/locks/verify")).to route_to('repositories/lfs_locks_api#verify', **params)

      expect(get("#{path}/gitlab-lfs/objects/#{oid}")).to route_to('repositories/lfs_storage#download', oid: oid, **params)
      expect(put("#{path}/gitlab-lfs/objects/#{oid}/456/authorize")).to route_to('repositories/lfs_storage#upload_authorize', oid: oid, size: '456', **params)
      expect(put("#{path}/gitlab-lfs/objects/#{oid}/456")).to route_to('repositories/lfs_storage#upload_finalize', oid: oid, size: '456', **params)
    end
  end

  describe 'code repositories' do
    context 'in project' do
      let(:path) { '/gitlab-org/gitlab-test.git' }

      it_behaves_like 'git repository routes'
    end
  end

  describe 'wiki repositories' do
    context 'in project' do
      let(:path) { '/gitlab-org/gitlab-test.wiki.git' }

      it_behaves_like 'git repository routes'

      describe 'redirects', type: :request do
        let(:web_path) { '/gitlab-org/gitlab-test/-/wikis' }

        it 'redirects namespace/project.wiki.git to the project wiki' do
          expect(get(path)).to redirect_to(web_path)
        end

        it 'preserves query parameters' do
          expect(get("#{path}?foo=bar&baz=qux")).to redirect_to("#{web_path}?foo=bar&baz=qux")
        end

        it 'only redirects when the format is .git' do
          expect(get(path.delete_suffix('.git'))).not_to redirect_to(web_path)
          expect(get(path.delete_suffix('.git') + '.json')).not_to redirect_to(web_path)
        end
      end
    end

    context 'in toplevel group' do
      let(:path) { '/gitlab-org.wiki.git' }

      it_behaves_like 'git repository routes'
    end

    context 'in child group' do
      let(:path) { '/gitlab-org/child.wiki.git' }

      it_behaves_like 'git repository routes'
    end
  end

  describe 'snippet repositories' do
    context 'personal snippet' do
      let(:path) { '/snippets/123.git' }

      it_behaves_like 'git repository routes'
    end

    context 'project snippet' do
      let(:path) { '/gitlab-org/gitlab-test/snippets/123.git' }

      it_behaves_like 'git repository routes'
    end
  end
end
