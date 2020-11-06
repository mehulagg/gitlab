# frozen_string_literal: true

module AssetsHelper
  # Taken from https://gist.github.com/averyvery/6e4576023b395de1aaf5
  def read_file_contents(stylesheet)
    if %w(test development).include?(Rails.env.to_s)
      # If we're running the full asset pipeline,
      # just grab the body of the final output
      stylesheet.source
    else
      # In a production-like environment, read the
      # fingerprinted and compiled file
      File.read(File.join(Rails.root, 'public', 'assets', stylesheet.digest_path))
    end
  end

  def inline_file(asset_path)
    file = Rails.application.assets.find_asset(asset_path)
    file.nil? ? '' : read_file_contents(file)
    # file = Rails.application.assets.find_asset(stylesheet_path(asset_path))
    # file.source
  end

  def inline_css(asset_path)
    "<style>#{inline_file asset_path}</style>".html_safe
  end
end
