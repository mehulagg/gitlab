# f = File.open(Rails.root.join("log", "queries.log"), "a")
ActiveSupport::Notifications.subscribe(/sql.active_record/) do |name, start, finish, message_id, values|

  if values[:sql].include?("999901, 999902, 999903, 999904, 999905, 999906")
    raise 'LONG QUERY'
  end
  # f.puts values[:sql]
  # f.puts "-----"
end
