class NotificationMailer < ApplicationMailer
    default from: 'notifications@queryhub.com' # Set a default sender email
  
    def new_answer_notification(answer)
      @answer = answer
      @question = answer.question
      @user = @question.user # The user who asked the question
  
      mail(to: @user.email, subject: "New Answer on Your Question: #{@question.title}")
    end


    def comment_notification(answer, comment)
        @answer = answer
        @comment = comment
        mail(to: @answer.user.email, subject: "New Comment on Your Answer")
      end
  end
  