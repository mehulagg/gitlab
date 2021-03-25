# frozen_string_literal: true

require 'date'

# https://docs.gitlab.com/ee/development/documentation/#move-or-rename-a-page
namespace :gitlab do
  namespace :docs do
    desc 'GitLab | Docs | Create a doc redirect'
    task :redirect, [:oldpath, :newpath] do |t, args|

      if args.oldpath
        oldpath = args.oldpath
      else
        puts 'Enter the path of the old file (relative to the doc/ directory): '
        oldpath = STDIN.gets.chomp
      end

      if args.newpath
        newpath = args.newpath
      else
        puts 'Enter the redirect URL (relative to the old file or external): '
        newpath = STDIN.gets.chomp
      end

      # - If this is an external URL, move the date 1 year later.
      # - If this is a relative URL, move the date 3 months later.
      date = Time.now.strftime('%Y-%m-%d')
      date = newpath.start_with?('http') ? Date.parse(date) >> 12 : Date.parse(date) >> 3

      oldpath = "doc/#{oldpath}"
      puts "Creating new redirect from #{oldpath} to #{newpath}"
      File.open(oldpath, 'w') do |post|
        post.puts '---'
        post.puts "redirect_to: '#{newpath}'"
        post.puts '---'
        post.puts
        post.puts "This file was moved to [another location](#{newpath})."
        post.puts
        post.puts "<!-- This redirect file can be deleted after <#{date}>. -->"
        post.puts "<!-- Before deletion, see: https://docs.gitlab.com/ee/development/documentation/#move-or-rename-a-page -->"
      end
	  end
  end
end
