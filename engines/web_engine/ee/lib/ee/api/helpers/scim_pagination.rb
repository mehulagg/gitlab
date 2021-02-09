# frozen_string_literal: true

module EE
  module API
    module Helpers
      module ScimPagination
        def scim_paginate(relation)
          relation.scim_paginate(start_index: params[:startIndex], count: per_page(params[:count]))
        end

        def per_page(requested_count)
          requested_limit = requested_count.to_i

          if requested_limit <= 0
            Kaminari.config.default_per_page
          else
            [requested_limit, Kaminari.config.max_per_page].min
          end
        end
      end
    end
  end
end
