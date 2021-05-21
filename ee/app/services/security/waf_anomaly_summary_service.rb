# frozen_string_literal: true

module Security
  # Service for fetching summary statistics from ElasticSearch.
  # Queries ES and retrieves both total nginx requests & modsec violations
  #
  class WafAnomalySummaryService < ::BaseService
    def initialize(environment:, cluster: environment.deployment_platform&.cluster, interval: 'day', from: 30.days.ago.iso8601, to: Time.zone.now.iso8601, options: {})
      @environment = environment
      @cluster = cluster
      @interval = interval
      @from = from
      @to = to
      @options = options
    end

    def execute(totals_only: false)
      return if elasticsearch_client.nil?
      return unless @environment.external_url

      # Use multi-search with single query as we'll be adding nginx later
      # with https://gitlab.com/gitlab-org/gitlab/issues/14707
      aggregate_results = elasticsearch_client.msearch(body: body)
      nginx_results, modsec_results = aggregate_results['responses']

      if chart_above_v3?
        nginx_total_requests = nginx_results.dig('hits', 'total', 'value').to_f
        modsec_total_requests = modsec_results.dig('hits', 'total', 'value').to_f
      else
        nginx_total_requests = nginx_results.dig('hits', 'total').to_f
        modsec_total_requests = modsec_results.dig('hits', 'total').to_f
      end

      return { total_traffic: nginx_total_requests, total_anomalous_traffic: modsec_total_requests } if totals_only

      anomalous_traffic_count = nginx_total_requests == 0 ? 0 : (modsec_total_requests / nginx_total_requests).round(2)

      {
        total_traffic: nginx_total_requests,
        anomalous_traffic: anomalous_traffic_count,
        history: {
          nominal: histogram_from(nginx_results),
          anomalous: histogram_from(modsec_results)
        },
        interval: @interval,
        from: @from,
        to: @to,
        status: :success
      }
    end

    def elasticsearch_client
      @elasticsearch_client ||= elastic_stack_adapter&.elasticsearch_client(timeout: @options[:timeout])
    end

    private

    def elastic_stack_adapter
      @elastic_stack_adapter ||= @cluster&.elastic_stack_adapter
    end

    def chart_above_v3?
      elastic_stack_adapter.chart_above_v3?
    end

    def body
      [
        { index: indices },
        {
          query: nginx_requests_query,
          aggs: aggregations(@interval),
          size: 0 # no docs needed, only counts
        },
        { index: indices },
        {
          query: modsec_requests_query,
          aggs: aggregations(@interval),
          size: 0 # no docs needed, only counts
        }
      ]
    end

    # Construct a list of daily indices to be searched. We do this programmatically
    # based on the requested timeframe to reduce the load of querying all previous
    # indices
    def indices
      (@from.to_date..@to.to_date).map do |day|
        "filebeat-*-#{day.strftime('%Y.%m.%d')}"
      end
    end

    def nginx_requests_query
      {
        bool: {
          must: [
            {
              range: {
                '@timestamp' => {
                  gte: @from,
                  lte: @to
                }
              }
            },
            {
              terms_set: {
                message: {
                  terms: environment_proxy_upstream_name_tokens,
                  minimum_should_match_script: {
                    source: 'params.num_terms'
                  }
                }
              }
            },
            {
              match_phrase: {
                'kubernetes.container.name' => {
                  query: ::Clusters::Applications::Ingress::INGRESS_CONTAINER_NAME
                }
              }
            },
            {
              match_phrase: {
                'kubernetes.namespace' => {
                  query: Gitlab::Kubernetes::Helm::NAMESPACE
                }
              }
            },
            {
              match_phrase: {
                stream: {
                  query: 'stdout'
                }
              }
            }
          ]
        }
      }
    end

    def modsec_requests_query
      {
        bool: {
          must: [
            {
              range: {
                '@timestamp' => {
                  gte: @from,
                  lte: @to
                }
              }
            },
            {
              prefix: {
                'transaction.unique_id': application_server_name
              }
            },
            {
              match_phrase: {
                'kubernetes.container.name' => {
                  query: ::Clusters::Applications::Ingress::MODSECURITY_LOG_CONTAINER_NAME
                }
              }
            },
            {
              match_phrase: {
                'kubernetes.namespace' => {
                  query: Gitlab::Kubernetes::Helm::NAMESPACE
                }
              }
            }
          ]
        }
      }
    end

    def aggregations(interval)
      {
        counts: {
          date_histogram: {
            field: '@timestamp',
            interval: interval,
            order: {
              '_key': 'asc'
            }
          }
        }
      }
    end

    def histogram_from(results)
      buckets = results.dig('aggregations', 'counts', 'buckets') || []

      buckets.map { |bucket| [bucket['key_as_string'], bucket['doc_count']] }
    end

    # Derive server_name to filter modsec audit log by environment
    def application_server_name
      @environment.formatted_external_url
    end

    # Derive proxy upstream name to filter nginx log by environment
    # See https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/log-format/
    def environment_proxy_upstream_name_tokens
      [
        *@environment.deployment_namespace.split('-'),
        @environment.slug # $RELEASE_NAME
      ]
    end
  end
end
