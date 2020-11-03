require 'rails/generators'

module Gitlab
  module Generators
    class InteractiveBase < Rails::Generators::NamedBase
      def initialize(args, *options)
        super
        self.options = self.options.merge(resolved_lazy_options)
      rescue Interrupt
        exit(1)
      rescue ArgumentError => e
        puts "Generator failed: #{e.message}"
        exit(1)
      end

      private

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

        label = 'required'
        if opts[:optional] || opts[:default]
          label = 'optional'
          return opts[:default] || '' if options[:quiet]
        else
          raise ArgumentError, "required value not provided" if options[:quiet]
        end

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
