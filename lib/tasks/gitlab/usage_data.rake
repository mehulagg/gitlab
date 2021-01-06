namespace :gitlab do
  namespace :usage_data do
    desc 'GitLab | UsageData | Generate raw SQLs for usage ping in YAML'
    task dump_sql_in_yaml: :environment do
      puts Gitlab::UsageDataQueries.uncached_data.to_yaml
    end

    desc 'GitLab | UsageData | Generate raw SQLs for usage ping in JSON'
    task dump_sql_in_json: :environment do
      puts Gitlab::Json.pretty_generate(Gitlab::UsageDataQueries.uncached_data)
    end

    desc 'GitLab | UsageData | Generate usage ping in JSON'
    task generate: :environment do
      puts Gitlab::Json.pretty_generate(Gitlab::UsageData.uncached_data)
    end

    desc 'GitLab | UsageData | Generate usage ping and send it to Versions Application'
    task generate_and_send: :environment do
      result = SubmitUsagePingService.new.execute

      puts Gitlab::Json.pretty_generate(result.attributes)
    end

    desc 'GitLab | UsageData | Generate metrics dictionary'
    task generate_metrics_dictionary: :environment do
      items = Gitlab::Usage::MetricDefinition.definitions
      markdown = Gitlab::Usage::MarkdownDictionary.build(items)

      out = File.join(Rails.root, 'doc', 'development', 'usage', 'dictionary.md')

      File.open(out, 'w') do |handle|
        handle.write(markdown)
      end
    end
  end
end
