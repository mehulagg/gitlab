# frozen_string_literal: true

require 'gollum-lib'

module Gitlab
  module Git
    class WikiGitalyCommitter < Gollum::Committer
      attr_reader :gl_wiki
      attr_accessor :actions

      def initialize(gl_wiki, options = {})
        @gl_wiki = gl_wiki
        @actions = []
        super(gl_wiki.gollum_wiki, options)
      end

      # Public: References the Git index for this commit.
      #
      # Returns a Gollum::Git::Index.
      def index
        raise NotImplementedError
      end

      # Adds a page to the given Index.
      #
      # dir    - The String subdirectory of the Gollum::Page without any
      #          prefix or suffix slashes (e.g. "foo/bar").
      # name   - The String Gollum::Page filename_stripped.
      # format - The Symbol Gollum::Page format.
      # data   - The String wiki data to store in the tree map.
      # allow_same_ext - A Boolean determining if the tree map allows the same
      #                  filename with the same extension.
      #
      # Raises Gollum::DuplicatePageError if a matching filename already exists.
      # This way, pages are not inadvertently overwritten.
      #
      # Returns nothing (modifies the Index in place).
      def add_to_index(dir, name, format, data, allow_same_ext = false)
        # spaces must be dashes
        dir.tr!(' ', '-')
        name.tr!(' ', '-')

        path = @wiki.page_file_name(name, format)

        dir = '/' if dir.strip.empty?

        fullpath = ::File.join(*[dir, path])
        fullpath = fullpath[1..-1] if fullpath =~ /^\//

        fullpath = fullpath.force_encoding('ascii-8bit') if fullpath.respond_to?(:force_encoding)

        begin
          data = wiki.normalize(data)
        rescue ArgumentError => err
          # Swallow errors that arise from data being binary
          raise err unless err.message.include?('invalid byte sequence')
        end

        actions << { action: :create, file_path: fullpath, content: data }
      end

      def update_working_dir(dir, name, format)
        # No-op
      end

      def delete(page_path)
        actions << { action: :delete, file_path: page_path }
      end

      def add(path, data)
        actions << { action: :update, file_path: path, content: data }
      end

      # Writes the commit to Git and runs the after_commit callbacks.
      #
      # Returns the String SHA1 of the new commit.
      def commit(update_ref = true)
        result = wiki.repo.multi_action(::User.first, actions)
        new_sha = result[:newrev]

        @callbacks.each do |cb|
          cb.call(self, new_sha)
        end
        new_sha
      end

      # Adds a callback to be fired after a commit.
      #
      # block - A block that expects this Committer instance and the created
      #         commit's SHA1 as the arguments.
      #
      # Returns nothing.
      def after_commit(&block)
        @callbacks << block
      end

      # Determine if a given page (regardless of format) is scheduled to be
      # deleted in the next commit for the given Index.
      #
      # map   - The Hash map:
      #         key - The String directory or filename.
      #         val - The Hash submap or the String contents of the file.
      # path - The String path of the page file. This may include the format
      #         extension in which case it will be ignored.
      #
      # Returns the Boolean response.
      # def page_path_scheduled_for_deletion?(map, path)
      #   parts = path.split('/')
      #   if parts.size == 1
      #     deletions = map.keys.select { |k| !map[k] }
      #     downfile  = parts.first.downcase.sub(/\.\w+$/, '')
      #     deletions.any? { |d| d.downcase.sub(/\.\w+$/, '') == downfile }
      #   else
      #     part = parts.shift
      #     if (rest = map[part])
      #       page_path_scheduled_for_deletion?(rest, parts.join('/'))
      #     else
      #       false
      #     end
      #   end
      # end

      # # Determine if a given file is scheduled to be deleted in the next commit
      # # for the given Index.
      # #
      # # map   - The Hash map:
      # #         key - The String directory or filename.
      # #         val - The Hash submap or the String contents of the file.
      # # path - The String path of the file including extension.
      # #
      # # Returns the Boolean response.
      # def file_path_scheduled_for_deletion?(map, path)
      #   parts = path.split('/')
      #   if parts.size == 1
      #     deletions = map.keys.select { |k| !map[k] }
      #     deletions.any? { |d| d == parts.first }
      #   else
      #     part = parts.shift
      #     if (rest = map[part])
      #       file_path_scheduled_for_deletion?(rest, parts.join('/'))
      #     else
      #       false
      #     end
      #   end
      # end
    end
  end
end
