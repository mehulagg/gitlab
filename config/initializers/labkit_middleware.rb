# frozen_string_literal: true

Rails.application.config.middleware.insert(1, Labkit::Middleware::Rack)
