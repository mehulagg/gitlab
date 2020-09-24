# frozen_string_literal: true

module Geo
  class NodeCreateService
    attr_reader :params

    def initialize(params)
      @params = params.dup
      @params[:namespace_ids] = @params[:namespace_ids].to_s.split(',') if @params[:namespace_ids].is_a? String
    end

    def execute
      GeoNode.create(params)
    end
  end
end
