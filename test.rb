all_routes = Rails.application.routes.routes

routes = all_routes.map do |route|
  ActionDispatch::Routing::RouteWrapper.new(route)
end

routes.reject!(&:internal?)

results = routes.map do |route|
  { name: route.name,
    verb: route.verb,
    path: route.path,
    reqs: route.reqs }
end

puts results.map{|r| "#{r[:path]}, #{r[:reqs]}"}.join("\n")