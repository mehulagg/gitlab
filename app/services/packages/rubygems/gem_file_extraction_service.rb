# frozen_string_literal: true

module Packages
  module Rubygems
    class GemFileExtractionService
      include Gitlab::Utils::StrongMemoize

      def initialize(package, package_file)
        @package = package
        @package_file = package_file
        @gem = Gem::Package.new(package_file.file)
      end

      def execute
        write_metadata
        write_gemspec
        set_dependencies
      end

      private

      attr_reader :package, :package_file, :gem

      def write_metadata
        package.rubygems_metadatum.upsert!(
          authors: gemspec.authors,
          files: gemspec.files,
          summary: gemspec.summary,
          description: gemspec.description,
          email: gemspec.email,
          homepage: gemspec.homepage,
          licenses: gemspec.licenses,
          metadata: gemspec.metadata,
          author: gemspec.author,
          bindir: gemspec.bindir,
          cert_chain: gemspec.cert_chain,
          executables: gemspec.executables,
          extensions: gemspec.extensions,
          extra_rdoc_files: gemspec.extra_rdoc_files,
          platform: gemspec.platform,
          post_install_message: gemspec.post_install_message,
          rdoc_options: gemspec.rdoc_options,
          require_paths: gemspec.require_paths,
          required_ruby_version: gemspec.required_ruby_version,
          required_rubygems_version: gemspec.required_rubygems_version.to_s,
          requrements: gemspec.requrements,
          rubygems_version: gemspec.rubygems_version,
          signing_key: gemspec.signing_key
        )
      end

      def write_gemspec
        # create new package_file with tmp file and store gemspec in it.
      end

      def set_dependencies
        # create new package_file with tmp file and store gemspec in it.
        # gemspec.dependencies.each do |dependency|
        #   package.dependencies.new(dependency)
        # end
      end

      def gemspec
        strong_memoize(:gemspec) do
          gem.spec
        end
      end

      # def extract_files
      #   return error('No gem file provided') unless package_file

      #   if extracted_files
      #     success
      #   else
      #     error('File extraction failed')
      #   end
      # end

      # def success
      #   ServiceResponse.success(payload: { files: extracted_files })
      # end

      # def error(message)
      #   ServiceResponse.error(message: message)
      # end
    end
  end
end
