# frozen_string_literal: true

module Boards
  module Lists
    class CreateService < Boards::Lists::BaseCreateService
    end
  end
end

Boards::Lists::CreateService.prepend_mod_with('EE::Boards::Lists::CreateService')
