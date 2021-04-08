# frozen_string_literal: true

# Auto-require all cops in `rubocop/cop/**/*.rb`
Dir[File.join(__dir__, 'cop', '**', '*.rb')].sort.each { |file| require file }
