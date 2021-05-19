# frozen_string_literal: true
require 'date'
require 'pathname'

# https://docs.gitlab.com/ee/development/documentation/#move-or-rename-a-page
namespace :gitlab do
  namespace :docs do
    desc 'GitLab | Docs | Create a doc redirect'
    task :redirect, [:old_path, :new_path] do |_, args|
      if args.old_path
        old_path = args.old_path
      else
        puts '=> Enter the path of the OLD file:'
        old_path = STDIN.gets.chomp
      end

      if args.new_path
        new_path = args.new_path
      else
        puts '=> Enter the path of the NEW file:'
        new_path = STDIN.gets.chomp
      end

      #
      # If the new path is a relative URL, find the relative path between
      # the old and new paths.
      # The returned path is one level deeper, so remove the leading '../'.
      #
      unless new_path.start_with?('http')
        old_pathname = Pathname.new(old_path)
        new_pathname = Pathname.new(new_path)
        relative_path = new_pathname.relative_path_from(old_pathname).to_s
        (_, *last) = relative_path.split('/')
        new_path = last.join('/')
      end

      #
      # - If this is an external URL, move the date 1 year later.
      # - If this is a relative URL, move the date 3 months later.
      #
      date = Time.now.utc.strftime('%Y-%m-%d')
      date = new_path.start_with?('http') ? Date.parse(date) >> 12 : Date.parse(date) >> 3

      puts "=> Creating new redirect from #{old_path} to #{new_path}"
      File.open(old_path, 'w') do |post|
        post.puts '---'
        post.puts "redirect_to: '#{new_path}'"
        post.puts "remove_date: '#{date}'"
        post.puts '---'
        post.puts
        post.puts "This file was moved to [another location](#{new_path})."
        post.puts
        post.puts "<!-- This redirect file can be deleted after <#{date}>. -->"
        post.puts "<!-- Before deletion, see: https://docs.gitlab.com/ee/development/documentation/#move-or-rename-a-page -->"
      end
    end

    desc 'GitLab | Docs | Clean up old redirects'
    task :clean_redirects do
      require "yaml"

      # Get the current date
      date = Time.now.utc.strftime('%Y-%m-%d')
      month_day = Time.now.utc.strftime('%Y-%m')

      # Find the files to be deleted
      files_to_be_deleted = `grep -R "This redirect file can be deleted after" doc/ | grep #{month_day} | cut -d ":" -f 1`.split("\n")

      #
      # Iterate over the files to be deleted and print the needed
      # YAML entries for the Docs site redirects.
      #
      files_to_be_deleted.each do |f|
        frontmatter = YAML.safe_load(File.read(f))
        redirect = frontmatter["redirect_to"]
        remove_date = frontmatter["remove_date"]

        old_path = f.gsub(%r(\.md), '.html').gsub(%r(doc\/), '/ee/')

        #
        # Calculate new path:
        #   1. Create a new Pathname of the file
        #   2. Use dirname to get all but the last component of the path
        #   3. Join with the redirect_to entry
        #   4. Substitute:
        #      - '.md' => '.html'
        #      - 'doc/' => '/ee/'
        #
        new_path = Pathname.new(f).dirname.join(redirect).to_s.gsub(%r(\.md), '.html').gsub(%r(doc\/), '/ee/')

        # Check if the removal date is before today
        if remove_date < date
          puts "- from: #{old_path}"
          puts "  to: #{new_path}"
          puts "  remove_date: #{remove_date}"
        end
      end
    end
  end
end
