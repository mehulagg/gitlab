namespace :eipi do
  desc 'List all the routes'
  task routes: :environment do
    all_routes = Rails.application.routes.routes

    routes = all_routes.map do |route|
      ActionDispatch::Routing::RouteWrapper.new(route)
    end

    routes.reject!(&:internal?)

    mapped = routes.map do |route|
      "#{route.controller}##{route.action}" if route.controller && route.action
    end

    File.write(File.join(Rails.root, 'routes.json'), mapped.to_json)
  end
end
