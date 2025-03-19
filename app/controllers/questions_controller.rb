class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]  # Ensure only logged-in users can ask questions

  def index
    @questions = Question.includes(:user, :answers).all  # Load associated data for performance
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build(question_params)

    if @question.save
      generate_ai_answer(@question)  # AI generates an answer after saving the question
      redirect_to @question, notice: "Your question has been posted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @question = Question.find(params[:id])
    @answers = @question.answers.includes(:user)  # Load all answers with user data
    @answer = Answer.new  # Prepare for answer submission form
    @question.increment!(:views_count)
    
  end

  def edit
    redirect_to questions_path, alert: "You are not authorized to edit this question." unless @question.user == current_user
  end

  def update
    if @question.user == current_user
      if @question.update(question_params)
        redirect_to questions_path, notice: "Question was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to questions_path, alert: "You are not authorized to update this question."
    end
  end

  def destroy
    if @question.user == current_user
      @question.destroy
      redirect_to questions_path, notice: "Question was successfully deleted."
    else
      redirect_to questions_path, alert: "You are not authorized to delete this question."
    end
  end

  private

  def question_params
    params.require(:question).permit(:title, :description)
  end

  def generate_ai_answer(question)
    client = OpenAI::Client.new(access_token: Rails.application.credentials.dig(:openai, :api_key))

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: "Answer the following question: #{question.title} #{question.description}" }],
        max_tokens: 150
      }
    )

    ai_answer = response.dig("choices", 0, "message", "content")

    if ai_answer.present?
      # Find or create AI user
      ai_user = User.find_or_create_by(email: "ai@queryhub.com") do |user|
        user.name = "AI Assistant"
        user.password = SecureRandom.hex(10)  # Random password (not needed for login)
      end

      # Save AI response as an answer
      question.answers.create!(content: ai_answer, user: ai_user)
    end
  end
end
