# frozen_string_literal: true

module MicrosoftTeams
  class Notifier
    def initialize(webhook)
      @webhook = webhook
      @header = { 'Content-type' => 'application/json' }
    end

    def ping(options = {})
      result = false

      begin
        response = Gitlab::HTTP.post(
          @webhook.to_str,
          headers: @header,
          body: body(options)
        )

        result = true if response
      rescue Gitlab::HTTP::Error, StandardError => error
        Gitlab::AppLogger.info("#{self.class.name}: Error while connecting to #{@webhook}: #{error.message}")
      end

      result
    end

    private

    def body(options = {})
      result = { 'sections' => [] }

      result['title'] = options[:title]
      result['summary'] = options[:summary]
      result['sections'] << MicrosoftTeams::Activity.new(options[:activity]).prepare

      attachments = options[:attachments]
      unless attachments.blank?
        result['sections'] << { text: attachments }
      end

      result.to_json
    end
  end
end
