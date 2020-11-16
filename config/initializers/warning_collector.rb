# frozen_string_literal: true

return unless ENV['CI']
return unless Rails.env.test? || Rails.env.development?

ActiveSupport::Deprecation.behavior = ->(message, callstack) {
  Warning.warn(message)
}

module Warning
  def self.output
    @output ||= begin
      dir = File.join(Rails.root.to_s, "warnings")
      FileUtils.mkdir_p(dir)
      prefix = "#{ENV['CI_JOB_NAME']}-".gsub(/[ \/]/, '-') if ENV['CI_JOB_NAME']
      filename = File.join(dir, "#{prefix}warnings.csv")
      File.open(filename, "w")
    end
  end

  def self.warn(message)
    root = Rails.root.to_s + "/"
    warning = message.gsub(root, "").chomp

    line = caller_locations.find do |location|
      location.path.end_with?("_spec.rb")
    end

    origin = line&.path&.gsub(root, "")

    output.write(%("#{warning}", "#{origin}:#{line&.lineno}"\n))
    $stderr.print(message) # rubocop:disable Style/StderrPuts
  end
end
