describe Gitlab::QA::Component::Specs do
  let(:docker) { spy('docker command') }

  before do
    stub_const('Gitlab::QA::Docker::Command', docker)
  end

  describe '#perform' do
    it 'bind-mounts a docker socket' do
      described_class.perform do |specs|
        specs.suite = spy('suite')
        specs.release = spy('release')
      end

      expect(docker).to have_received(:volume)
        .with('/var/run/docker.sock', '/var/run/docker.sock')
    end

    it 'bind-mounds volume with screenshots in an appropriate directory' do
      allow(SecureRandom)
        .to receive(:hex)
        .and_return('abc123')
      allow(Gitlab::QA::Runtime::Env)
        .to receive(:artifacts_dir)
        .and_return('/tmp/gitlab-qa')

      described_class.perform do |specs|
        specs.suite = spy('suite')
        specs.release = double('release', edition: :ce, project_name: 'gitlab-ce', qa_image: 'gitlab-ce-qa', qa_tag: 'latest')
      end

      expect(docker).to have_received(:volume)
        .with('/var/run/docker.sock', '/var/run/docker.sock')
      expect(docker).to have_received(:volume)
        .with('/tmp/gitlab-qa/gitlab-ce-qa-abc123', '/home/qa/tmp')
    end
  end
end
