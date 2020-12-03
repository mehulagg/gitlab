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
      puts Gitlab::UsageData.to_json(force_refresh: true)
    end

    desc 'GitLab | UsageData | Generate usage ping and send it to Versions Application'
    task generate_and_send: :environment do
      result = SubmitUsagePingService.new.execute
      puts result.inspect
    end

    desc 'GitLab | UsageData | Generate metrics dictionary'
    task generate_metrics_dictionary: :environment do
      out = File.join(Rails.root, 'lib', 'gitlab', 'usage_data', 'metric', 'dictionary.json')
      dictionary = Gitlab::Json.pretty_generate(Gitlab::UsageData::Metric.dictionary)

      File.open(out, 'w') do |handle|
        handle.write(dictionary)
      end

      puts dictionary
    end
  end
end
