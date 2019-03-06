# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Config::External::Processor do
  set(:project) { create(:project, :repository) }
  set(:another_project) { create(:project, :repository) }
  set(:user) { create(:user) }

  let(:expandset) { Set.new }
  let(:sha) { '12345' }
  let(:processor) { described_class.new(values, project: project, sha: '12345', user: user, expandset: expandset) }

  before do
    project.add_developer(user)
  end

  describe "#perform" do
    subject { processor.perform }

    context 'when no external files defined' do
      let(:values) { { image: 'ruby:2.2' } }

      it 'should return the same values' do
        expect(processor.perform).to eq(values)
      end
    end

    context 'when an invalid local file is defined' do
      let(:values) { { include: '/lib/gitlab/ci/templates/non-existent-file.yml', image: 'ruby:2.2' } }

      it 'should raise an error' do
        expect { processor.perform }.to raise_error(
          described_class::IncludeError,
          "Local file `/lib/gitlab/ci/templates/non-existent-file.yml` does not exist!"
        )
      end
    end

    context 'when an invalid remote file is defined' do
      let(:remote_file) { 'http://doesntexist.com/.gitlab-ci-1.yml' }
      let(:values) { { include: remote_file, image: 'ruby:2.2' } }

      before do
        WebMock.stub_request(:get, remote_file).to_raise(SocketError.new('Some HTTP error'))
      end

      it 'should raise an error' do
        expect { processor.perform }.to raise_error(
          described_class::IncludeError,
          "Remote file `#{remote_file}` could not be fetched because of a socket error!"
        )
      end
    end

    context 'with a valid remote external file is defined' do
      let(:remote_file) { 'https://gitlab.com/gitlab-org/gitlab-ce/blob/1234/.gitlab-ci-1.yml' }
      let(:values) { { include: remote_file, image: 'ruby:2.2' } }
      let(:external_file_content) do
        <<-HEREDOC
        before_script:
          - apt-get update -qq && apt-get install -y -qq sqlite3 libsqlite3-dev nodejs
          - ruby -v
          - which ruby
          - bundle install --jobs $(nproc)  "${FLAGS[@]}"

        rspec:
          script:
            - bundle exec rspec

        rubocop:
          script:
            - bundle exec rubocop
        HEREDOC
      end

      before do
        WebMock.stub_request(:get, remote_file).to_return(body: external_file_content)
      end

      it 'should append the file to the values' do
        output = processor.perform
        expect(output.keys).to match_array([:image, :before_script, :rspec, :rubocop])
      end

      it "should remove the 'include' keyword" do
        expect(processor.perform[:include]).to be_nil
      end
    end

    context 'with a valid local external file is defined' do
      let(:values) { { include: '/lib/gitlab/ci/templates/template.yml', image: 'ruby:2.2' } }
      let(:local_file_content) do
        <<-HEREDOC
        before_script:
          - apt-get update -qq && apt-get install -y -qq sqlite3 libsqlite3-dev nodejs
          - ruby -v
          - which ruby
          - bundle install --jobs $(nproc)  "${FLAGS[@]}"
        HEREDOC
      end

      before do
        allow_any_instance_of(Gitlab::Ci::Config::External::File::Local)
          .to receive(:fetch_local_content).and_return(local_file_content)
      end

      it 'should append the file to the values' do
        output = processor.perform
        expect(output.keys).to match_array([:image, :before_script])
      end

      it "should remove the 'include' keyword" do
        expect(processor.perform[:include]).to be_nil
      end
    end

    context 'with multiple external files are defined' do
      let(:remote_file) { 'https://gitlab.com/gitlab-org/gitlab-ce/blob/1234/.gitlab-ci-1.yml' }
      let(:external_files) do
        [
          '/spec/fixtures/gitlab/ci/external_files/.gitlab-ci-template-1.yml',
          remote_file
        ]
      end
      let(:values) do
        {
          include: external_files,
          image: 'ruby:2.2'
        }
      end

      let(:remote_file_content) do
        <<-HEREDOC
        stages:
          - build
          - review
          - cleanup
        HEREDOC
      end

      before do
        local_file_content = File.read(Rails.root.join('spec/fixtures/gitlab/ci/external_files/.gitlab-ci-template-1.yml'))

        allow_any_instance_of(Gitlab::Ci::Config::External::File::Local)
          .to receive(:fetch_local_content).and_return(local_file_content)

        WebMock.stub_request(:get, remote_file).to_return(body: remote_file_content)
      end

      it 'should append the files to the values' do
        expect(processor.perform.keys).to match_array([:image, :stages, :before_script, :rspec])
      end

      it "should remove the 'include' keyword" do
        expect(processor.perform[:include]).to be_nil
      end
    end

    context 'when external files are defined but not valid' do
      let(:values) { { include: '/lib/gitlab/ci/templates/template.yml', image: 'ruby:2.2' } }

      let(:local_file_content) { 'invalid content file ////' }

      before do
        allow_any_instance_of(Gitlab::Ci::Config::External::File::Local)
          .to receive(:fetch_local_content).and_return(local_file_content)
      end

      it 'should raise an error' do
        expect { processor.perform }.to raise_error(
          described_class::IncludeError,
          "Included file `/lib/gitlab/ci/templates/template.yml` does not have valid YAML syntax!"
        )
      end
    end

    context "when both external files and values defined the same key" do
      let(:remote_file) { 'https://gitlab.com/gitlab-org/gitlab-ce/blob/1234/.gitlab-ci-1.yml' }
      let(:values) do
        {
          include: remote_file,
          image: 'ruby:2.2'
        }
      end

      let(:remote_file_content) do
        <<~HEREDOC
        image: php:5-fpm-alpine
        HEREDOC
      end

      it 'should take precedence' do
        WebMock.stub_request(:get, remote_file).to_return(body: remote_file_content)
        expect(processor.perform[:image]).to eq('ruby:2.2')
      end
    end

    context "when a nested includes are defined" do
      let(:values) do
        {
          include: [
            { local: '/local/file.yml' }
          ],
          image: 'ruby:2.2'
        }
      end

      before do
        allow(project.repository).to receive(:blob_data_at).with('12345', '/local/file.yml') do
          <<~HEREDOC
            include:
              - template: Ruby.gitlab-ci.yml
              - remote: http://my.domain.com/config.yml
              - project: #{another_project.full_path}
                file: /templates/my-workflow.yml
          HEREDOC
        end

        allow_any_instance_of(Repository).to receive(:blob_data_at).with(another_project.commit.id, '/templates/my-workflow.yml') do
          <<~HEREDOC
            include:
              - local: /templates/my-build.yml
          HEREDOC
        end

        allow_any_instance_of(Repository).to receive(:blob_data_at).with(another_project.commit.id, '/templates/my-build.yml') do
          <<~HEREDOC
            my_build:
              script: echo Hello World
          HEREDOC
        end

        WebMock.stub_request(:get, 'http://my.domain.com/config.yml').to_return(body: 'remote_build: { script: echo Hello World }')
      end

      context 'when project is public' do
        before do
          another_project.update!(visibility: 'public')
        end

        it 'properly expands all includes' do
          is_expected.to include(:my_build, :remote_build, :rspec)
        end
      end

      context 'when user is reporter of another project' do
        before do
          another_project.add_reporter(user)
        end

        it 'properly expands all includes' do
          is_expected.to include(:my_build, :remote_build, :rspec)
        end
      end

      context 'when user is not allowed' do
        it 'raises an error' do
          expect { subject }.to raise_error(Gitlab::Ci::Config::External::Processor::IncludeError, /not found or access denied/)
        end
      end

      context 'when too many includes is included' do
        before do
          stub_const('Gitlab::Ci::Config::External::Mapper::MAX_INCLUDES', 1)
        end

        it 'raises an error' do
          expect { subject }.to raise_error(Gitlab::Ci::Config::External::Processor::IncludeError, /Maximum of 1 nested/)
        end
      end
    end
  end
end
