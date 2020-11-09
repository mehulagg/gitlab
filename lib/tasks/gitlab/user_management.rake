namespace :gitlab do
  namespace :user_management do
    desc "GitLab | User management | Update all users of a group with personal project limit to 0 and can_create_group to false"
    task :update_users_of_a_group, [:group_id] => :environment do |t, args|
      group = Group.find(args.group_id)

      group.direct_and_indirect_users.update_all(projects_limit: 0, can_create_group: false)
    end
  end
end
