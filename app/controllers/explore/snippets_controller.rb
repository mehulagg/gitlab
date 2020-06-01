# frozen_string_literal: true

class Explore::SnippetsController < Explore::ApplicationController
  include Gitlab::NoteableMetadata

  def index
    order = params[:order] || 'updated_at'
    @snippets = SnippetsFinder.new(current_user, explore: true, order_by: order)
      .execute
      .page(params[:page])
      .without_count
      .inc_author

    @noteable_meta_data = noteable_meta_data(@snippets, 'Snippet')
  end
end
