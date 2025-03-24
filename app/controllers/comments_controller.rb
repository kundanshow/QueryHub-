class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @answer = Answer.find(params[:answer_id])
    @comment = @answer.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      # Send email notification to the answer's author
      NotificationMailer.comment_notification(@answer, @comment).deliver_later
      redirect_to question_path(@answer.question), notice: "Comment added successfully!"
    else
      redirect_to question_path(@answer.question), alert: "Failed to add comment."
    end
  end    

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
