# frozen_string_literal: true

require_relative '../base'
require_relative '../../../feature/shared' unless defined?(Feature::Shared)

# notable differences:
# we don't check all feature flags -- maybe EE should override?

module Gitlab
  module Generators
    class FeatureFlagGenerator < InteractiveBase
      TYPES = Feature::Shared::TYPES.reject { |_, v| v[:deprecated] }

      desc 'Generate a Feature Flag entry file in the correct location'
      source_root File.expand_path('templates/', __dir__)

      class_option :amend,
                   group: :runtime,
                   type: :boolean,
                   default: false,
                   desc: 'Amend the previous commit (requires a topic branch)'

      class_option :type,
                   type: :string,
                   aliases: '-t',
                   lazy_default: :type,
                   desc: "The type of the Feature Flag (Available: #{TYPES.keys.join(', ')})"

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

      def create_feature_flag
        @file_path = "#{(ee? ? 'ee/' : '')}config/feature_flags/#{type}/#{file_name}.yml"
        template('feature_flag.yml', @file_path)
      end

      def amend_commit
        return unless options[:amend]

        raise ArgumentError, 'create a branch first' if %x(git symbolic-ref --short HEAD).chomp == 'master'
        %x(git add #{@file_path} && git commit --amend --no-edit)
        say_status(:amended, "added #{@file_path}", :green)
      rescue StandardError => e
        say_status(:failure, e.message, :red)
        exit(1)
      end

      protected

      def ee?
        resolved(:ee, :ee_only)
      end

      def type
        resolved = resolved(:type) { TYPES.first.first if TYPES.one? }
        return resolved if resolved

        response = ask_with_validation(
          'Enter the number for the Feature Flag type',
          options: TYPES.map.with_index(1) { |(k, v), i| ["[#{i}]", k, v[:description]] },
          default: 1,
          message: invalid_message('must be a valid selection')
        ) { |r| TYPES[r.to_sym].presence && r.to_sym }

        @definition = TYPES[response]
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
          'Generate a new rollout issue URL? [Yn] (enter "h" for help)',
          display_options: false,
          # optional: true,
          options: [
            ['[y]', 'yes, create and open a new issue url'],
            ['[n]', 'no, I can provide my own'],
            ['[h]', 'help, show this help']
          ]
        ) do |response, opts|
          case response
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
          end
        end
      end

      def milestone
        ask_for(
          :milestone,
          default: (File.read('VERSION').to_s.gsub(/^(\d+\.\d+).*$/, '\1').chomp rescue nil),
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
    end
  end
end
