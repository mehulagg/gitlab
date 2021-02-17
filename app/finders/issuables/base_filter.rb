module Issuables
  class BaseFilter
    # This is used as a common filter for None / Any
    FILTER_NONE = 'none'
    FILTER_ANY = 'any'

    # This is used in unassigning users
    NONE = '0'

    attr_reader :issuables, :params

    def initialize(issuables, params:, not_filters_enabled: false)
      @issuables = issuables
      @params = params
      @not_filters_enabled = not_filters_enabled
    end

    def filter
      raise NotImplementedError
    end

    private

    def not_params
      params[:not]
    end

    def not_filters_enabled?
      @not_filters_enabled
    end
  end
end
