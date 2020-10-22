# frozen_string_literal: true

module Security
  class DependencyListService
    SORT_BY_VALUES = %w(name packager severity).freeze
    SORT_VALUES = %w(asc desc).freeze
    FILTER_PACKAGE_MANAGERS_VALUES = %w(bundler yarn npm maven composer pip).freeze
    FILTER_VALUES = %w(all vulnerable).freeze

    # @param pipeline [Ci::Pipeline]
    # @param [Hash] params to sort and filter dependencies
    # @option params ['asc', 'desc'] :sort ('asc') Order
    # @option params ['name', 'packager', 'severity'] :sort_by ('name') Field to sort
    # @option params ['bundler', 'yarn', 'npm', 'maven', 'composer', 'pip'] :package_manager ('bundler') Field to filter
    # @option params ['all', 'vulnerable'] :filter ('all') Field to filter
    def initialize(pipeline:, params: {})
      @pipeline = pipeline
      @params = params
    end

    # @return [Array<Hash>] collection of found dependencies
    def execute
      collection = init_collection
      collection = filter_by_package_manager(collection)
      collection = filter_by_vulnerable(collection)
      collection = sort(collection)
      collection
    end

    private

    attr_accessor :params, :pipeline

    def init_collection
      pipeline.dependency_list_report.dependencies
    end

    def filter_by_package_manager(collection)
      return collection unless params[:package_manager]

      collection.select do |dependency|
        params[:package_manager].include?(dependency[:package_manager])
      end
    end

    def filter_by_vulnerable(collection)
      return collection unless params[:filter] == 'vulnerable'

      collection.select do |dependency|
        dependency[:vulnerabilities].any?
      end
    end

    def sort(collection)
      case params[:sort_by]
      when 'packager'
        collection.sort_by! { |a| a[:packager] }
      when 'severity'
        collection = sort_by_severity(collection)
      else
        collection.sort_by! { |a| a[:name] }
      end

      collection.reverse! if params[:sort] == 'desc'

      collection
    end

    # vulnerabilities are initially sorted by severity in report
    # https://gitlab.com/gitlab-org/security-products/analyzers/common/blob/ee9d378f46d9cc4e7b7592786a2a558dcc72b0f5/issue/report.go#L15
    # So we can assume that first vulnerability in vulnerabilities array
    # will have highest severity
    def sort_by_severity(collection)
      collection.sort do |dep_i, dep_j|
        level_i = dep_i.dig(:vulnerabilities, 0, :severity) || :info
        level_j = dep_j.dig(:vulnerabilities, 0, :severity) || :info

        ::Vulnerabilities::Finding::SEVERITY_LEVELS[level_j] <=> ::Vulnerabilities::Finding::SEVERITY_LEVELS[level_i]
      end
    end
  end
end
