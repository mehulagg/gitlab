# frozen_string_literal: true

require 'spec_helper'

require 'tempfile'

RSpec.describe Gitlab::Middleware::Multipart do
  include_context 'multipart middleware context'

  RSpec.shared_examples_for 'multipart upload files' do
    it 'opens top-level files' do
      Tempfile.open('top-level') do |tempfile|
        rewritten = { 'file' => tempfile.path }
        in_params = { 'file.name' => original_filename, 'file.path' => file_path, 'file.remote_id' => remote_id, 'file.size' => file_size }
        env = post_env(rewritten, in_params, Gitlab::Workhorse.secret, 'gitlab-workhorse')

        expect_uploaded_file(tempfile, %w(file))

        middleware.call(env)
      end
    end

    it 'opens files one level deep' do
      Tempfile.open('one-level') do |tempfile|
        rewritten = { 'user[avatar]' => tempfile.path }
        in_params = { 'user' => { 'avatar' => { '.name' => original_filename, '.path' => file_path, '.remote_id' => remote_id, '.size' => file_size } } }
        env = post_env(rewritten, in_params, Gitlab::Workhorse.secret, 'gitlab-workhorse')

        expect_uploaded_file(tempfile, %w(user avatar))

        middleware.call(env)
      end
    end

    it 'opens files two levels deep' do
      Tempfile.open('two-levels') do |tempfile|
        in_params = { 'project' => { 'milestone' => { 'themesong' => { '.name' => original_filename, '.path' => file_path, '.remote_id' => remote_id, '.size' => file_size } } } }
        rewritten = { 'project[milestone][themesong]' => tempfile.path }
        env = post_env(rewritten, in_params, Gitlab::Workhorse.secret, 'gitlab-workhorse')

        expect_uploaded_file(tempfile, %w(project milestone themesong))

        middleware.call(env)
      end
    end

    def expect_uploaded_file(tempfile, path)
      expect(app).to receive(:call) do |env|
        file = get_params(env).dig(*path)
        expect(file).to be_a(::UploadedFile)
        expect(file.original_filename).to eq(original_filename)

        if remote_id
          expect(file.remote_id).to eq(remote_id)
          expect(file.path).to be_nil
        else
          expect(file.path).to eq(File.realpath(tempfile.path))
          expect(file.remote_id).to be_nil
        end
      end
    end
  end

  RSpec.shared_examples_for 'handling CI artifact upload' do
    it 'uploads both file and metadata' do
      Tempfile.open('file') do |file|
        Tempfile.open('metadata') do |metadata|
          rewritten = { 'file' => file.path, 'metadata' => metadata.path }
          in_params = { 'file.name' => 'file.txt', 'file.path' => file_path, 'file.remote_id' => file_remote_id, 'file.size' => file_size, 'metadata.name' => 'metadata.gz' }
          env = post_env(rewritten, in_params, Gitlab::Workhorse.secret, 'gitlab-workhorse')

          with_expected_uploaded_artifact_files(file, metadata) do |uploaded_file, uploaded_metadata|
            expect(uploaded_file).to be_a(::UploadedFile)
            expect(uploaded_file.original_filename).to eq('file.txt')

            if file_remote_id
              expect(uploaded_file.remote_id).to eq(file_remote_id)
              expect(uploaded_file.size).to eq(file_size)
              expect(uploaded_file.path).to be_nil
            else
              expect(uploaded_file.path).to eq(File.realpath(file.path))
              expect(uploaded_file.remote_id).to be_nil
            end

            expect(uploaded_metadata).to be_a(::UploadedFile)
            expect(uploaded_metadata.original_filename).to eq('metadata.gz')
            expect(uploaded_metadata.path).to eq(File.realpath(metadata.path))
            expect(uploaded_metadata.remote_id).to be_nil
          end

          middleware.call(env)
        end
      end
    end

    def with_expected_uploaded_artifact_files(file, metadata)
      expect(app).to receive(:call) do |env|
        file = get_params(env).dig('file')
        metadata = get_params(env).dig('metadata')

        yield file, metadata
      end
    end
  end

  it 'rejects headers signed with the wrong secret' do
    env = post_env({ 'file' => '/var/empty/nonesuch' }, {}, 'x' * 32, 'gitlab-workhorse')

    expect { middleware.call(env) }.to raise_error(JWT::VerificationError)
  end

  it 'rejects headers signed with the wrong issuer' do
    env = post_env({ 'file' => '/var/empty/nonesuch' }, {}, Gitlab::Workhorse.secret, 'acme-inc')

    expect { middleware.call(env) }.to raise_error(JWT::InvalidIssuerError)
  end

  context 'with invalid rewritten field' do
    invalid_field_names = [
      '[file]',
      ';file',
      'file]',
      ';file]',
      'file]]',
      'file;;',
      'user[avatar',
      '[user]avatar',
      'user[]avatar',
      'user[avatar[image[url]]]',
      '[]',
      'x' * 11000
    ]

    invalid_field_names.each do |invalid_field_name|
      it "rejects invalid rewritten field name #{invalid_field_name}" do
        env = post_env({ invalid_field_name => nil }, {}, Gitlab::Workhorse.secret, 'gitlab-workhorse')

        expect { middleware.call(env) }.to raise_error(RuntimeError, "invalid field: \"#{invalid_field_name}\"")
      end
    end
  end

  context 'with remote file' do
    let(:remote_id) { 'someid' }
    let(:file_size) { 300 }
    let(:file_path) { '' }

    it_behaves_like 'multipart upload files'
  end

  context 'with remote file and a file path set' do
    let(:remote_id) { 'someid' }
    let(:file_size) { 300 }
    let(:file_path) { 'not_a_valid_file_path' } # file path will come from the rewritten_fields

    it_behaves_like 'multipart upload files'
  end

  context 'with local file' do
    let(:remote_id) { nil }
    let(:file_size) { nil }
    let(:file_path) { 'not_a_valid_file_path' } # file path will come from the rewritten_fields

    it_behaves_like 'multipart upload files'
  end

  context 'with remote CI artifact upload' do
    let(:file_remote_id) { 'someid' }
    let(:file_size) { 300 }
    let(:file_path) { 'not_a_valid_file_path' } # file path will come from the rewritten_fields

    it_behaves_like 'handling CI artifact upload'
  end

  context 'with local CI artifact upload' do
    let(:file_remote_id) { nil }
    let(:file_size) { nil }
    let(:file_path) { 'not_a_valid_file_path' } # file path will come from the rewritten_fields

    it_behaves_like 'handling CI artifact upload'
  end

  it 'allows files in uploads/tmp directory' do
    with_tmp_dir('public/uploads/tmp') do |dir, env|
      expect(app).to receive(:call) do |env|
        expect(get_params(env)['file']).to be_a(::UploadedFile)
      end

      middleware.call(env)
    end
  end

  it 'allows files in the job artifact upload path' do
    with_tmp_dir('artifacts') do |dir, env|
      expect(JobArtifactUploader).to receive(:workhorse_upload_path).and_return(File.join(dir, 'artifacts'))
      expect(app).to receive(:call) do |env|
        expect(get_params(env)['file']).to be_a(::UploadedFile)
      end

      middleware.call(env)
    end
  end

  it 'allows files in the lfs upload path' do
    with_tmp_dir('lfs-objects') do |dir, env|
      expect(LfsObjectUploader).to receive(:workhorse_upload_path).and_return(File.join(dir, 'lfs-objects'))
      expect(app).to receive(:call) do |env|
        expect(get_params(env)['file']).to be_a(::UploadedFile)
      end

      middleware.call(env)
    end
  end

  it 'allows symlinks for uploads dir' do
    Tempfile.open('two-levels') do |tempfile|
      symlinked_dir = '/some/dir/uploads'
      symlinked_path = File.join(symlinked_dir, File.basename(tempfile.path))
      env = post_env({ 'file' => symlinked_path }, { 'file.name' => original_filename, 'file.path' => symlinked_path }, Gitlab::Workhorse.secret, 'gitlab-workhorse')

      allow(FileUploader).to receive(:root).and_return(symlinked_dir)
      allow(UploadedFile).to receive(:allowed_paths).and_return([symlinked_dir, Gitlab.config.uploads.storage_path])
      allow(File).to receive(:realpath).and_call_original
      allow(File).to receive(:realpath).with(symlinked_dir).and_return(Dir.tmpdir)
      allow(File).to receive(:realpath).with(symlinked_path).and_return(tempfile.path)
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(symlinked_dir).and_return(true)

      # override Dir.tmpdir because this dir is in the list of allowed paths
      # and it would match FileUploader.root path (which in this test is linked
      # to /tmp too)
      allow(Dir).to receive(:tmpdir).and_return(File.join(Dir.tmpdir, 'tmpsubdir'))

      expect(app).to receive(:call) do |env|
        expect(get_params(env)['file']).to be_a(::UploadedFile)
      end

      middleware.call(env)
    end
  end

  describe '#call' do
    context 'with packages storage' do
      using RSpec::Parameterized::TableSyntax

      let(:storage_path) { 'shared/packages' }

      RSpec.shared_examples 'allowing the multipart upload' do
        it 'allows files to be uploaded' do
          with_tmp_dir('tmp/uploads', storage_path) do |dir, env|
            allow(Packages::PackageFileUploader).to receive(:root).and_return(File.join(dir, storage_path))

            expect(app).to receive(:call) do |env|
              expect(get_params(env)['file']).to be_a(::UploadedFile)
            end

            middleware.call(env)
          end
        end
      end

      RSpec.shared_examples 'not allowing the multipart upload when package upload path is used' do
        it 'does not allow files to be uploaded' do
          with_tmp_dir('tmp/uploads', storage_path) do |dir, env|
            # with_tmp_dir sets the same workhorse_upload_path for all Uploaders,
            # so we have to prevent JobArtifactUploader and LfsObjectUploader to
            # allow the tested path
            allow(JobArtifactUploader).to receive(:workhorse_upload_path).and_return(Dir.tmpdir)
            allow(LfsObjectUploader).to receive(:workhorse_upload_path).and_return(Dir.tmpdir)

            status, headers, body = middleware.call(env)

            expect(status).to eq(400)
            expect(headers).to eq({ 'Content-Type' => 'text/plain' })
            expect(body).to start_with('insecure path used')
          end
        end
      end

      RSpec.shared_examples 'adding package storage to multipart allowed paths' do
        before do
          expect(::Packages::PackageFileUploader).to receive(:workhorse_upload_path).and_call_original
        end

        it_behaves_like 'allowing the multipart upload'
      end

      RSpec.shared_examples 'not adding package storage to multipart allowed paths' do
        before do
          expect(::Packages::PackageFileUploader).not_to receive(:workhorse_upload_path)
        end

        it_behaves_like 'not allowing the multipart upload when package upload path is used'
      end

      where(:object_storage_enabled, :direct_upload_enabled, :example_name) do
        false | true  | 'adding package storage to multipart allowed paths'
        false | false | 'adding package storage to multipart allowed paths'
        true  | true  | 'not adding package storage to multipart allowed paths'
        true  | false | 'adding package storage to multipart allowed paths'
      end

      with_them do
        before do
          stub_config(packages: {
            enabled: true,
            object_store: {
              enabled: object_storage_enabled,
              direct_upload: direct_upload_enabled
            },
            storage_path: storage_path
          })
        end

        it_behaves_like params[:example_name]
      end
    end
  end
end
