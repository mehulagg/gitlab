begin
  app = Rails.application

  # The `ActionDispatch::Static` middleware intercepts requests for static files 
  # by checking if they exist in the `/public` directory. 
  # We're replacing it with our `Gitlab::Middleware::Static` that does the same,
  # except ignoring `/uploads`, letting those go through to the GitLab Rails app.

  app.config.middleware.swap(
    ActionDispatch::Static, 
    Gitlab::Middleware::Static, 
    app.paths["public"].first, 
    app.config.static_cache_control
  )
rescue
  # If ActionDispatch::Static wasn't loaded onto the stack (like in production), 
  # an exception is raised.
end
