return unless ENV.key?('CI')

ActiveSupport::Deprecation.behavior = ->(message, callstack) {
  Warning.warn(message)
}

module Warning
  def self.output
    @output ||= begin
      root = ENV['RAILS_ROOT'] || '.'
      dir = File.join(root, "deprecations")
      FileUtils.mkdir_p(dir)
      prefix = "#{ENV['CI_JOB_NAME']}-".gsub(/[ \/]/, '-') if ENV['CI_JOB_NAME']
      filename = File.join(dir, "#{prefix}-warnings.txt")
      File.open(filename, "w+")
    end
  end

  def self.log_warning(warning)
    output.write(warning)
  end

  def self.warn(warning)
    log_warning(warning)
  end
end
