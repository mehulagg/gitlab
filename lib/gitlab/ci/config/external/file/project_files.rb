# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module External
        module File
          class ProjectFiles < Base
            include Gitlab::Utils::StrongMemoize

            def initialize(params, context)
              @params = params
              @context = context
            end

            def matching?
              @params[:file].is_a?(Array) && params[:project].present?
            end

            def to_hash
              strong_memoize(:to_hash) do
                files.inject({}) do |hash, file|
                  hash.deep_merge!(file.to_hash)
                end
              end
            end

            def valid?
              errors.none?
            end

            def error_message
              errors.first
            end

            private

            def errors
              strong_memoize(:errors) do
                files.flat_map(&:errors)
              end
            end

            def files
              strong_memoize(:files) do
                @params[:file].map do |location|
                  ProjectFile.new(@params.merge(file: location), @context)
                end
              end
            end
          end
        end
      end
    end
  end
end
