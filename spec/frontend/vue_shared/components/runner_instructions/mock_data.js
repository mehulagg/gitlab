export const mockPlatformsObject = {
  linux: {
    human_readable_name: 'Linux',
    download_locations: {
      '386':
        'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386',
      amd64:
        'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64',
      arm:
        'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-arm',
      arm64:
        'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-arm64',
    },
    install_script_template_path: 'lib/gitlab/ci/runner_instructions/templates/linux/install.sh',
    runner_executable: 'sudo gitlab-runner',
  },
  osx: {
    human_readable_name: 'macOS',
    download_locations: {
      amd64:
        'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-darwin-amd64',
    },
    install_script_template_path: 'lib/gitlab/ci/runner_instructions/templates/osx/install.sh',
    runner_executable: 'sudo gitlab-runner',
  },
  windows: {
    human_readable_name: 'Windows',
    download_locations: {
      '386':
        'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-386.exe',
      amd64:
        'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe',
    },
    install_script_template_path: 'lib/gitlab/ci/runner_instructions/templates/windows/install.ps1',
    runner_executable: './gitlab-runner.exe',
  },
  docker: {
    human_readable_name: 'Docker',
    installation_instructions_url: 'https://docs.gitlab.com/runner/install/docker.html',
  },
  kubernetes: {
    human_readable_name: 'Kubernetes',
    installation_instructions_url: 'https://docs.gitlab.com/runner/install/kubernetes.html',
  },
};

export const mockInstructions = {
  install:
    "# Download the binary for your system\nsudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386\n\n# Give it permissions to execute\nsudo chmod +x /usr/local/bin/gitlab-runner\n\n# Create a GitLab CI user\nsudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash\n\n# Install and run as service\nsudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner\nsudo gitlab-runner start\n",
  register:
    'sudo gitlab-runner register --url http://0.0.0.0:3000/ --registration-token GE5gsjeep_HAtBf9s3Yz',
};
