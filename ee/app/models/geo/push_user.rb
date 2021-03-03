# frozen_string_literal: true

class Geo::PushUser
  include ::Gitlab::Identifier

  def initialize(gl_id)
    @gl_id = gl_id
  end

  def user
    @user ||= identify_using_ssh_key(gl_id)
  end

  private

  attr_reader :gl_id
end
