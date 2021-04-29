# frozen_string_literal: true

module Events
  class RenderService < BaseRenderer
    def execute(events, atom_request: false)
      notes = events.map(&:note).compact
      notes = notes.select { |note| !note.confidential }

      render_notes(notes, atom_request)
    end

    private

    def render_notes(notes, atom_request)
      Notes::RenderService
        .new(current_user)
        .execute(notes, render_options(atom_request))
    end

    def render_options(atom_request)
      return {} unless atom_request

      { only_path: false, xhtml: true }
    end
  end
end
