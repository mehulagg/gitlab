namespace :gitlab do
  namespace :user_management do
    desc "GitLab | User management | Update all users of a group with personal project limit to 0 and can_create_group to false"
    task :update_users_of_a_group, [:group_id] => :environment do |t, args|
      group = Group.find(args.group_id)

      ids = group.direct_and_indirect_users.pluck(:id)
      result = User.where(id: ids).update_all(projects_limit: 0, can_create_group: false)
      puts "Done".green if result == ids.count
      puts "Something went wrong".red if result != ids.count
    end
  end
end
