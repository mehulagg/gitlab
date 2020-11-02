# frozen_string_literal: true

class Profiles::SavedRepliesController < Profiles::ApplicationController
  before_action :set_saved_reply, only: [:edit, :update, :destroy]

  feature_category :users

  def index
    @saved_replies = current_user.saved_replies
    @saved_reply = SavedReply.new
  end

  def create
    @saved_reply = SavedReply.new(saved_reply_params)
    @saved_reply.user = current_user

    if @saved_reply.save
      redirect_to(profile_saved_replies_path, notice: "'#{@saved_reply.title}' was successfully created.")
    else
      render 'index'
    end
  end

  def edit
  end

  def update
    if @saved_reply.update_attributes(saved_reply_params)
      redirect_to(profile_saved_replies_path, notice: "'#{@saved_reply.title}' was successfully updated.")
    else
      render 'edit'
    end
  end

  def destroy
    if @saved_reply.destroy
      redirect_to(profile_saved_replies_path, notice: _('Note template was successfully deleted.'))
    end
  end

  private

  def saved_reply_params
    params.require(:saved_reply).permit(:note, :title)
  end


  def set_saved_reply
    @saved_reply ||= current_user.saved_replies.find(params['id'])
  end
end
