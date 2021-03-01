# frozen_string_literal: true

require 'gollum-lib'

module Gitlab
  module Git
    # class CommitterWithHooks < Gollum::Committer
    #   attr_reader :gl_wiki

    #   def initialize(gl_wiki, options = {})
    #     @gl_wiki = gl_wiki
    #     super(gl_wiki.gollum_wiki, options)
    #   end

    #   def commit
    #     result = Gitlab::Git::OperationService.new(git_user, gl_wiki.repository).with_branch(
    #       @wiki.ref,
    #       start_branch_name: @wiki.ref
    #     ) do |_start_commit|
    #       super(false)
    #     end

    #     result[:newrev]
    #   rescue Gitlab::Git::PreReceiveError => e
    #     message = "Hook failed: #{e.message}"
    #     raise Gitlab::Git::Wiki::OperationError, message
    #   end

    #   private

    #   def git_user
    #     @git_user ||= Gitlab::Git::User.new(@options[:username],
    #                                         @options[:name],
    #                                         @options[:email],
    #                                         gitlab_id)
    #   end

    #   def gitlab_id
    #     Gitlab::GlId.gl_id_from_id_value(@options[:user_id])
    #   end
    # end

    class Wiki
      include Gitlab::Git::WrapsGitalyErrors

      DuplicatePageError = Class.new(StandardError)

      DEFAULT_PAGINATION = Kaminari.config.default_per_page

      CommitDetails = Struct.new(:user, :user_id, :username, :name, :email, :message) do
        def to_h
          { user: user, user_id: user_id, username: username, name: name, email: email, message: message }
        end
      end

      # GollumSlug inlines just enough knowledge from Gollum::Page to generate a
      # slug, which is used when previewing pages that haven't been persisted
      class GollumSlug
        class << self
          def cname(name, char_white_sub = '-', char_other_sub = '-')
            if name.respond_to?(:gsub)
              name.gsub(/\s/, char_white_sub).gsub(/[<>+]/, char_other_sub)
            else
              ''
            end
          end

          def format_to_ext(format)
            format == :markdown ? "md" : format.to_s
          end

          def canonicalize_filename(filename)
            ::File.basename(filename, ::File.extname(filename)).tr('-', ' ')
          end

          def generate(title, format)
            ext = format_to_ext(format.to_sym)
            name = cname(title) + '.' + ext
            canonical_name = canonicalize_filename(name)

            path =
              if name.include?('/')
                name.sub(%r{/[^/]+$}, '/')
              else
                ''
              end

            path + cname(canonical_name, '-', '-')
          end
        end
      end

      attr_reader :repository

      def self.default_ref
        'master'
      end

      # Initialize with a Gitlab::Git::Repository instance
      def initialize(repository)
        @repository = repository
      end

      def repository_exists?
        @repository.exists?
      end

      # Supported
      def write_page(name, format, content, commit_details)
        with_committer_with_hooks({}) do |committer|
          filename = File.basename(name)
          dir = (tmp_dir = File.dirname(name)) == '.' ? '' : tmp_dir

          gollum_wiki.write_page(filename, format, content, { committer: committer }, dir)
        end
      rescue Gollum::DuplicatePageError => e
        raise Gitlab::Git::Wiki::DuplicatePageError, e.message
        # wrapped_gitaly_errors do
        #   gitaly_write_page(name, format, content, commit_details)
        # end
      end

      # Partially supported. There is a bug in the committer after hook
      # because it tries to access the page but it doesn't exist anymore
      def delete_page(page_path, commit_details)
        with_committer_with_hooks({}) do |committer|
          gollum_wiki.delete_page(gollum_page_by_path(page_path), { committer: committer })
        end
        # wrapped_gitaly_errors do
        #   gitaly_delete_page(page.path, commit_details)
        # end
      end

      def update_page(page_path, title, format, content, commit_details)
        with_committer_with_hooks({}) do |committer|
          page = gollum_page_by_path(page_path)
          gollum_wiki.update_page(page, page.name, format, content, committer: committer)
          gollum_wiki.rename_page(page, title, committer: committer)
        end
        puts "ACABO UPDATE*****"
        # wrapped_gitaly_errors do
        #   gitaly_update_page(page_path, title, format, content, commit_details)
        # end
      end

      # Almost supported
      # list_pages with content works (only sort by created_at is not supported)
      # When we don't want to load the content, we can perform a
      # `repository.ls_files` but we would need to support order and limit options
      # in Gitaly
      def list_pages(limit: 0, sort: nil, direction_desc: false, load_content: false)
        pages_limit = limit == 0 ? nil : limit

        if load_content == false
          # `repository.ls_files` ?
          # Maybe we can provide an option for pages to indicate not to load content.
          # in the meantime we stick to this
          gollum_wiki.pages( # rubocop:disable Style/IdenticalConditionalBranches
            limit: pages_limit, sort: sort, direction_desc: direction_desc
          ).map do |gollum_page|
            new_page(gollum_page)
          end
        else
          gollum_wiki.pages( # rubocop:disable Style/IdenticalConditionalBranches
            limit: pages_limit, sort: sort, direction_desc: direction_desc
          ).map do |gollum_page|
            new_page(gollum_page)
          end
        end

        # wrapped_gitaly_errors do
        #   gitaly_list_pages(
        #     limit: limit,
        #     sort: sort,
        #     direction_desc: direction_desc,
        #     load_content: load_content
        #   )
        # end
      end

      # Supported
      def page(title:, version: nil, dir: nil)
        puts "**** ENTRO EN PAGGEGEGE #{version}"
        if version
          version = Gitlab::Git::Commit.find(@repository, version)&.id
          return unless version
        end

        gollum_page = gollum_wiki.page(title, version, dir)
        return unless gollum_page

        new_page(gollum_page)
        # wrapped_gitaly_errors do
        #   gitaly_find_page(title: title, version: version, dir: dir)
        # end
      end

      # Supported
      def file(name, version)
        version ||= self.class.default_ref
        gollum_file = gollum_wiki.file(name, version)
        return unless gollum_file

        Gitlab::Git::WikiFile.new(gollum_file)
        # wrapped_gitaly_errors do
        #   gitaly_find_file(name, version)
        # end
      end

      # Supported
      # options:
      #  :page     - The Integer page number.
      #  :per_page - The number of items per page.
      #  :limit    - Total number of items to return.
      def page_versions(page_path, options = {})
        page = gollum_wiki.paged(Gollum::Page.canonicalize_filename(page_path), File.split(page_path).first)
        page.versions(per_page: options[:per_page], page: options[:per_page]).map do |versions|
          new_version(page, page.version.id)
        end

        # versions = wrapped_gitaly_errors do
        #   gitaly_wiki_client.page_versions(page_path, options)
        # end

        # Gitaly uses gollum-lib to get the versions. Gollum defaults to 20
        # per page, but also fetches 20 if `limit` or `per_page` < 20.
        # Slicing returns an array with the expected number of items.
        # slice_bound = options[:limit] || options[:per_page] || DEFAULT_PAGINATION
        # versions[0..slice_bound]
      end

      # Supported
      # New method
      # Public: Search all pages for this wiki.
      #
      # query - The string to search for
      #
      # Returns an Array with Objects of page name and count of matches
      def search(query)
        gollum_wiki.search(query)
      end

      def count_page_versions(page_path)
        @repository.count_commits(ref: 'HEAD', path: page_path)
      end

      def preview_slug(title, format)
        GollumSlug.generate(title, format)
      end

      def gollum_wiki
        # @gollum_wiki ||= Gollum::Wiki.new(@repository.path)

        @gollum_wiki ||= begin
          Gollum::Wiki.new(gollum_wiki_access)
        end
      end

      def gollum_wiki_access
        @gollum_wiki_access ||= Gollum::GitAccess.new(@repository.relative_path, nil, nil, { storage: @repository.storage, gl_repository: @repository.gl_repository, gl_project_path: @repository.gl_project_path })
      end

      def new_page(gollum_page)
        Gitlab::Git::WikiPage.new(gollum_page, new_version(gollum_page, gollum_page.version.id))
      end

      def new_version(gollum_page, commit_id)
        Gitlab::Git::WikiPageVersion.new(version(commit_id), gollum_page&.format)
      end

      def version(commit_id)
        Gitlab::Git::Commit.find(@repository, commit_id)
      end

      def assert_type!(object, klass)
        raise ArgumentError, "expected a #{klass}, got #{object.inspect}" unless object.is_a?(klass)
      end

      def committer_with_hooks(commit_details)
        # Gitlab::Git::CommitterWithHooks.new(self, commit_details.to_h)
        Gitlab::Git::WikiGitalyCommitter.new(self, {})
      end

      def with_committer_with_hooks(commit_details)
        committer = committer_with_hooks(commit_details)

        yield committer

        committer.commit

        nil
      end

      def gollum_page_by_path(page_path)
        page_name = Gollum::Page.canonicalize_filename(page_path)
        page_dir = File.split(page_path).first

        gollum_wiki.paged(page_name, page_dir) || (raise PageNotFound, page_path)
      end

      private

      def gitaly_wiki_client
        @gitaly_wiki_client ||= Gitlab::GitalyClient::WikiService.new(@repository)
      end

      def gitaly_write_page(name, format, content, commit_details)
        gitaly_wiki_client.write_page(name, format, content, commit_details)
      end

      def gitaly_update_page(page_path, title, format, content, commit_details)
        gitaly_wiki_client.update_page(page_path, title, format, content, commit_details)
      end

      def gitaly_delete_page(page_path, commit_details)
        gitaly_wiki_client.delete_page(page_path, commit_details)
      end

      def gitaly_find_page(title:, version: nil, dir: nil)
        return unless title.present?

        wiki_page, version = gitaly_wiki_client.find_page(title: title, version: version, dir: dir)
        return unless wiki_page

        Gitlab::Git::WikiPage.new(wiki_page, version)
      rescue GRPC::InvalidArgument
        nil
      end

      def gitaly_find_file(name, version)
        wiki_file = gitaly_wiki_client.find_file(name, version)
        return unless wiki_file

        Gitlab::Git::WikiFile.new(wiki_file)
      end

      def gitaly_list_pages(limit: 0, sort: nil, direction_desc: false, load_content: false)
        params = { limit: limit, sort: sort, direction_desc: direction_desc }

        gitaly_pages =
          if load_content
            gitaly_wiki_client.load_all_pages(**params)
          else
            gitaly_wiki_client.list_all_pages(**params)
          end

        gitaly_pages.map do |wiki_page, version|
          Gitlab::Git::WikiPage.new(wiki_page, version)
        end
      end
    end
  end
end
