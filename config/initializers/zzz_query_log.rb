f = File.open(Rails.root.join("log", "queries.log"), "a")
ActiveSupport::Notifications.subscribe(/sql.active_record/) do |name, start, finish, message_id, values|
  f.puts values[:sql]
  f.puts "-----"
end
