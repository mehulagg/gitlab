module Gitlab
  module Sitemaps
    class UrlExtractor
      class << self
        include Gitlab::Routing

        def extract_from_group(group)
          #  epics (in case the group has them)
          # packages and registries
          [
           group_url(group),
           issues_group_url(group),
           merge_requests_group_url(group)
          ]
        end
      end
    end
  end
end
