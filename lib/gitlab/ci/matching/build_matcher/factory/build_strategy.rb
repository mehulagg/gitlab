# frozen_string_literal: true

module Gitlab
  module Ci
    module Matching
      class BuildMatcher
        class Factory
          class BuildStrategy
            def self.applies_to?(record)
              record.is_a?(::Ci::Build)
            end

            def self.build_from(record)
              attributes = {
                protected: record.protected?,
                tag_list: record.tag_list,
                build_ids: [record.id],
                project: record.project
              }

              [BuildMatcher.new(attributes)]
            end
          end
        end
      end
    end
  end
end
