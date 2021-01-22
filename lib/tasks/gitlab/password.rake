# frozen_string_literal: true

namespace :gitlab do
  namespace :password do
    desc 'GitLab | Password | Reset default admin user password'
    task :reset, [:username] => :environment do |_, args|
      username = args[:username] || 'root'

      password = STDIN.getpass('Enter password: ')
      password_confirm = STDIN.getpass('Confirm password: ')
      abort("Password do not match.") unless password.eql?(password_confirm)

      user = User.find_by_username(username)
      abort("Unable to find user with username #{username}") unless user

      user.update!(password: password, password_confirmation: password, password_automatically_set: false)
      puts "Password successfully updated"
    end
  end
end
