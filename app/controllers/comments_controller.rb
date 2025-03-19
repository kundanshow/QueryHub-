class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @answer = Answer.find(params[:answer_id])
    @comment = @answer.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.html { redirect_to @answer.question, notice: "Comment added successfully!" }
        format.js   # For AJAX rendering
      end
    else
      redirect_to @answer.question, alert: "Failed to add comment."
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
