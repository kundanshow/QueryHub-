class AnswersController < ApplicationController
    def create
      @question = Question.find(params[:question_id])
      @answer = @question.answers.build(answer_params)
      @answer.user = current_user
  
      # AI moderation
      if moderate_content(@answer.content)
        flash[:alert] = "Your answer may contain inappropriate content."
        redirect_to @question and return
      end
  
      if @answer.save
        redirect_to @question, notice: "Answer submitted!"
      else
        render 'questions/show'
      end
    end
  
    private
  
    def answer_params
      params.require(:answer).permit(:content)
    end
  
    def moderate_content(text)
      client = OpenAI::Client.new
      response = client.moderations(parameters: { input: text })
      response["results"][0]["flagged"]
    end
  end
  