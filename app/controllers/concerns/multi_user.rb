module MultiUser
  extend ActiveSupport::Concern

  class_methods do
    # Allow the current action to define a new warden session.
    # Retain the previous warden session if the current action does nothing.
    def multi_user_login(options)
      prepend_before_action :enable_multi_user, options
    end
  end

  def enable_multi_user
    @multi_user = true
  end

  # Call this method in an around filter to handle multi-user warden sessions.
  # Must be specified after session storage has been defined.
  def set_multi_user
    yield && return unless @multi_user

    begin
      # Move the current active warden session out of the way.
      if previous_user = current_user
        Gitlab::WardenSession.save
        sign_out(previous_user)
      end

      yield
    ensure
      # Load the previous active warden session if no new session.
      if current_user.nil? && previous_user
        Gitlab::WardenSession.load(previous_user.id)
        bypass_sign_in(previous_user)
      end
    end
  end
end
