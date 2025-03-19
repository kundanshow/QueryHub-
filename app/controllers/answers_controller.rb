class AnswersController < ApplicationController
  def create
    @question = Question.find(params[:question_id])  # Find the associated question
    @answer = @question.answers.build(answer_params) # Build the answer under the question
    @answer.user = current_user                      # Assign the currently logged-in user

    if @answer.save
      redirect_to @question, notice: "Answer submitted successfully!" # Redirect to show page
    else
      flash[:alert] = "There was an error submitting your answer."
      redirect_to @question
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:content)
  end

  def moderate_content(text)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai, :api_key))

    retries = 3
    begin
      response = client.moderations(parameters: { input: text })
      response["results"][0]["flagged"]
    rescue Faraday::TooManyRequestsError
      if retries > 0
        retries -= 1
        sleep(2**(3 - retries)) # Exponential backoff (2, 4, 8 seconds)
        retry
      else
        Rails.logger.warn "OpenAI API rate limit exceeded. Skipping moderation."
        false # If we can't moderate, assume it's okay
      end
    end
  end
end
