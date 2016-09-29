module QA
  module Scenario
    module Test
      module Omnibus
        class Image < Scenario::Template
          def perform(version)
            Docker::Gitlab.act(version.downcase) do |version|
              with_name("gitlab-qa-#{version}")
              with_image("gitlab/gitlab-#{version}")
              with_image_tag('nightly')
              within_network('bridge')

              reconfigure do |line|
                exit(0) if line =~ /gitlab Reconfigured!/
              end
            end
          end
        end
      end
    end
  end
end
