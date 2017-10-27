module Gitlab
  module QA
    module Component
      ##
      # This class represents GitLab QA specs image that is implemented in
      # the `qa/` directory located in GitLab CE / EE repositories.
      #
      # TODO, it needs some refactoring.
      #
      class Specs
        include Scenario::Actable

        IMAGE_NAME = 'gitlab/gitlab-qa'.freeze

        def initialize
          @docker = Docker::Engine.new
        end

        def test(gitlab:, suite: 'Test::Instance')
          test_address(
            release: gitlab.release,
            address: gitlab.address,
            name: "#{gitlab.name}-specs",
            network: gitlab.network,
            suite: suite
          )
        end

        def test_address(release:, address:, name: nil, network: nil,
                         suite: 'Test::Instance')
          puts "Running instance suite #{suite} for Gitlab " \
               "#{release.edition.upcase} at #{address}"

          args = [suite, address]

          @docker.run(IMAGE_NAME, release.edition_tag, *args) do |command|
            build_command(command, name, network)
          end
        end

        private

        def build_command(command, name, network)
          command << "-t --rm --net=#{network || 'bridge'}"

          Runtime::Env.delegated.each do |env|
            command.env(env, "$#{env}")
          end

          unless Runtime::Env.dind?
            command.volume('/var/run/docker.sock', '/var/run/docker.sock')
          end

          command.volume(Runtime::Env.screenshots_dir, '/home/qa/tmp')
          command.name(name || "gitlab-specs-#{Time.now.to_i}")
        end
      end
    end
  end
end
