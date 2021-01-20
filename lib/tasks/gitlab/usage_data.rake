module Tasks
  module Gitlab
    class CSVMetric
      attr_reader :description, :product_category, :group, :stage

      def initialize(row)
        @row = row

        @description      = row['Description']
        @product_category = row['Product Category']
        @group            = row['Product Owner']
        @stage            = row['CS Stage Adoption']
      end

      def distribution
        distribution = []
        distribution << 'free'                if @row["On Core / Free?"]      == 'Yes'
        distribution << 'starter' << 'bronze' if @row["On Starter / Bronze?"] == 'Yes'
        distribution << 'premium' << 'silver' if @row["On Premium / Silver?"] == 'Yes'
        distribution << 'ultimate' << 'gold'  if @row["On Ultimate / Gold?"]  == 'Yes'
        distribution
      end

      def tier
        tier = []
        tier << 'ce' if @row ['On CE?'] ==  'Yes'
        tier << 'ee' if @row ['On EE?'] ==  'Yes'
        tier
      end

      def ee?
        tier.include?('ee')
      end
    end

    class UsagePingMetric
      attr_reader :file_name, :key_path

      def initialize(key_path, value)
        @key_path = key_path.to_s
        @value = value

        @file_name = @key_path.split('.').last.downcase
      end

      def ce_file_path
        "config/metrics/#{directory}/#{file_name}.yml"
      end

      def ee_file_path
        "ee/#{ce_file_path}"
      end

      def value_type
        value_type = 'number'
        value_type = 'string'  if directory == 'license'
        value_type = 'boolean' if directory == 'settings'
        value_type
      end

      def time_frame
        time_frame = 'none'
        time_frame = '7d'  if directory == 'counts_7d'
        time_frame = '28d' if directory == 'counts_28d'
        time_frame = 'all' if directory == 'counts_all'
        time_frame
      end

      def data_source
        return 'prometheus' if @key_path.include?('topology')
        return 'redis'      if @key_path.include?('redis')
        return 'database'   if @key_path.include?('count')
      end

      def ee?
        @key_path.include?('ee')
      end

      private

      def directory
        directory = 'counts_all'
        directory = 'counts_28d' if @key_path.include?('monthly')
        directory = 'counts_7d'  if @key_path.include?('weekly')
        directory = 'counts_7d'  if @key_path.include?('weekly')
        directory = 'license'    if %w(recorded_at license uuid hostname version installation_type active_user_count edition historical_max_users edition).any? { |sub_key| @key_path.include?(sub_key) }
        directory = 'settings'   if %w(settings).any? { |sub_key| @key_path.include?(sub_key) } || @value.is_a?(TrueClass) || @value.is_a?(FalseClass)
        directory
      end
    end
  end
end

namespace :gitlab do
  namespace :usage_data do
    def flatten_hash(param, prefix=nil)
      param.each_pair.reduce({}) do |a, (k, v)|
        v.is_a?(Hash) ? a.merge(flatten_hash(v, "#{prefix}#{k}.")) : a.merge("#{prefix}#{k}".to_sym => v)
      end
    end

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

    desc 'GitLab | UsageData | Generate definition yml files from Usage Ping payload'
    task :generate_defintion_files, [:csv_path] => :environment do |t, args|
      event_dictionary_data = CSV.parse(File.read(args.csv_path), headers: true)

      usage_ping_hash = Gitlab::UsageData.uncached_data

      flatten_hash(usage_ping_hash).each do |key, value|
        usage_ping_metric = Tasks::Gitlab::UsagePingMetric.new(key, value)

        definition = {
          'key_path'    =>  usage_ping_metric.key_path,
          'description' => '',
          'value_type'  => usage_ping_metric.value_type,
          'product_category' => '',
          'stage'        => '',
          'status'       => 'data_available',
          'group'        => '',
          'time_frame'   => usage_ping_metric.time_frame,
          'data_source'  => usage_ping_metric.data_source,
          'distribution' => [],
          'tier'         => [],
        }

        tier = []
        tier << 'ee' if usage_ping_metric.ee?

        # Event dictionary spreadsheet information
        csv_row = event_dictionary_data.find { |row| row["Metric Name"] == key.to_s }

        if csv_row
          csv_metric = Tasks::Gitlab::CSVMetric.new(csv_row)

          definition['description']      = csv_metric.description
          definition['product_category'] = csv_metric.product_category
          definition['group']            = csv_metric.group
          definition['distribution']     = csv_metric.distribution
          definition['stage']            = csv_metric.stage

          tier += csv_metric.tier
        end

        definition['tier'] = tier.uniq

        file_path = usage_ping_metric.ce_file_path
        file_path = usage_ping_metric.ee_file_path if tier == ['ee']

        # Don't update of override exiting definitions
        unless File.exists?(file_path)
          File.open(file_path, "w") { |file| file.write(definition.to_yaml) }
        end
      end
    end
  end
end
