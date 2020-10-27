# frozen_string_literal: true

require 'rails/generators'

# notable differences:
# we don't check all feature flags -- maybe EE should override?

module Gitlab
  module Generators
    class FeatureFlagGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('templates/', __dir__)

      desc 'Generates a Feature Flag yml'

      class << self
        def types
          {
            development: { description: 'Short lived, used to enable unfinished code to be deployed', rollout_issue: true, ee_only: false, },
            ops: { description: 'Long-lived feature flags that control operational aspects of GitLab\'s behavior', rollout_issue: false, ee_only: false, },
          }
          # Feature::Shared::TYPES.reject { |_, v| v[:deprecated] }
        end
      end

      class_option :type,
                   type: :string,
                   aliases: '-t',
                   lazy_default: :type,
                   desc: "The type of the Feature Flag (Available: #{types.keys.join(', ')})"

      class_option :group,
                   type: :string,
                   aliases: '-g',
                   lazy_default: :group,
                   desc: 'The group introducing the Feature Flag (e.g. group::apm)'

      class_option :introduced_by_url,
                   type: :string,
                   aliases: '-m',
                   lazy_default: :introduced_by_url,
                   desc: 'URL of Merge Request introducing the Feature Flag'

      class_option :rollout_issue_url,
                   type: :string,
                   aliases: '-i',
                   lazy_default: :rollout_issue_url,
                   desc: 'URL of Feature Flag rollout Issue'

      class_option :milestone,
                   type: :string,
                   aliases: '-M',
                   lazy_default: :milestone,
                   desc: 'Milestone in which the Feature Flag was introduced'

      class_option :default_enabled,
                   type: :boolean,
                   aliases: '-d',
                   lazy_default: :default_enabled?,
                   desc: 'If the Feature Flag should be default enabled or not'

      class_option :ee,
                   type: :boolean,
                   aliases: '-e',
                   lazy_default: :ee?,
                   desc: 'Generate the Feature Flag for GitLab EE'

      delegate :types, to: :class

      def initialize(args, *options)
        super
        self.options = self.options.merge(resolved_lazy_options)
      end

      def create_feature_flag
        template('feature_flag.yml', "#{(ee? ? 'ee/' : '')}config/feature_flags/#{type}/#{file_name}.yml")
      end

      protected

      def ee?
        resolved(:ee, :ee_only)
      end

      def type
        resolved = resolved(:type) { types.first.first if types.one? }
        return resolved if resolved

        response = ask_with_validation(
          'Enter the number for the Feature Flag type',
          options: types.map.with_index(1) { |(k, v), i| ["[#{i}]", k, v[:description]] },
          default: 1,
          message: invalid_message('must be a valid selection')
        ) { |r| types[r.to_sym].presence && r.to_sym }

        @definition = types[response]
        response
      end

      def group
        ask_for(
          :group,
          message: invalid_message('must begin with "group::"')
        ) { |r| r =~ %r(^group::) && r }
      end

      def introduced_by_url
        ask_for(
          :introduced_by_url,
          optional: true,
          message: invalid_message('must begin with "https://gitlab.com"')
        ) { |r| r =~ %r(^|http://gitlab.com) && r }
      end

      def rollout_issue_url
        ask_with_validation(
          'Generate a new rollout issue URL? [Yns] (enter "h" for help)',
          display_options: false,
          options: [
            ['[y]', 'yes, create and open a new issue url'],
            ['[n]', 'no, I can provide my own'],
            ['[s]', 'skip'],
            ['[h]', 'help, show this help']
          ]
        ) do |response, opts|
          case response
          when nil, is?(:skip)
            true
          when '', is?(:yes)
            system('open', generated_rollout_issue_url)
            return generated_rollout_issue_url
          when is?(:no)
            return ask_for(
              :rollout_issue_url,
              optional: true,
              message: invalid_message('must begin with "https://gitlab.com"')
            ) { |r| r =~ %r(^|https://gitlab.com) && r }
          when is?(:help)
            opts[:display_options] = true
            nil
          else
            nil
          end
        end
      end

      def milestone
        ask_for(
          :milestone,
          # default: (File.read('VERSION').to_s.gsub(/^(\d+\.\d+).*$/, '\1').chomp rescue nil),
          # optional: true,
          message: invalid_message('must look like a version')
        ) { |r| r =~ %r(^|\d{2-3}.\d{1-3}) && r }
      end

      def default_enabled?
        resolved(:default_enabled) || false
      end

      private

      def generated_rollout_issue_url
        "https://gitlab.com/gitlab-org/gitlab/-/issues/new?#{URI.encode_www_form({
          'issue[title]': "[Feature flag] Rollout of `#{file_name}`",
          'issuable_template': 'Feature Flag Roll Out',
        })}"
      end

      def resolved_lazy_options
        @resolved_lazy_options ||= self.class.class_options.inject({}) do |memo, (key, value)|
          memo[key] = send(value.lazy_default) if value.lazy_default
          memo
        end
      end

      def resolved(options_key, definition_key = nil, &block)
        options[options_key] ||
          (@definition ||= {})[options_key || definition_key] ||
          block.try(:call)
      end

      def ask_for(options_key, definition_key = nil, **opts, &block)
        prompt = opts[:prompt] || self.class.class_options[options_key].description
        resolved(options_key, definition_key) ||
          ask_with_validation(prompt, **opts, &block)
      end

      def ask_with_validation(prompt, **opts, &block)
        message = Array(opts[:message] || invalid_message)
        message = invalid_message(message) if message.size == 1

        label = opts[:optional] || opts[:default] ? 'optional' : 'required'

        until (answer ||= nil)
          if opts[:options] && opts[:display_options] != false
            print_table(opts[:options], indent: 14, truncate: true)
          end

          answer = ask("    #{label}  #{prompt}:", **opts)
          answer = find_in_options(opts[:options], answer)
          answer = block.call(answer.to_s, opts) if block_given?

          say_status(*message) if opts[:optional] != true && answer.nil?
        end

        if answer.blank?
          say_status(:skipped, '', :cyan)
        else
          say_status(:answer, answer, :green)
        end

        answer
      end

      def find_in_options(options, answer)
        match = (options || []).find { |o| o[0].to_s == "[#{answer}]" || o[1].to_s == answer }
        return answer unless match

        match.size > 2 ? match[1] : answer
      end

      def invalid_message(message = 'is not valid', color: :red)
        [:invalid, "response #{Array(message).join(', ')}", color]
      end

      def is?(value)
        value = value.to_s
        value.size == 1 ? /\A#{value}\z/i : /\A(#{value}|#{value[0, 1]})\z/i
      end
    end
  end
end
