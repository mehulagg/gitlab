# frozen_string_literal: true

namespace :grape do
  desc 'Print compiled grape routes'
  task routes: :environment do
    print_routes
  end

  namespace :routes do
    desc 'Print compiled grape routes with the parameters'
    task params: :environment do
      print_routes do |route|
        route_params(route.options[:params])
      end
    end
  end

  def print_routes
    API::API.routes.each do |route|
      puts "#{route.options[:method]} #{route.path} - #{route_description(route.options)}"

      yield(route)
    end
  end

  def route_description(options)
    options[:settings][:description][:description] if options[:settings][:description]
  end

  def route_params(params)
    params.each do |name, options|
      values =
        case options[:values]
        when Array
          options[:values].join
        else
          options[:values]
        end

      puts [
        '  ',
        name,
        options[:type],
        options[:required] ? 'required' : 'optional',
        options[:desc],
        options[:values]
      ].join(' | ')
    end
  end
end
