class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  
  def index
    @questions = Question.includes(:user, :answers).all
  end

  def new
    @question = Question.new
  end

  def create
    @question = current_user.questions.build(question_params)

    if @question.save
       suggest_answers(@question)  # Find relevant answers from the database
    redirect_to question_answers_path(@question), notice: "Your question has been posted!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @answers = @question.answers.includes(:user)
    @answer = Answer.new
  end

  def edit
    unless @question.user == current_user
      redirect_to questions_path, alert: "You are not authorized to edit this question."
    end
  end

  def update
    if @question.user == current_user
      if @question.update(question_params)
        redirect_to @question, notice: "Question was successfully updated."
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

  def set_question
    @question = Question.find_by(id: params[:id])
    redirect_to questions_path, alert: "Question not found." if @question.nil?
  end

  def question_params
    params.require(:question).permit(:title, :description)
  end

  # Method to suggest answers from similar questions
  def suggest_answers(question)
   
    # Fetch similar records from the Store model
    similar_stores = Store.where("LOWER(title) LIKE ? AND LOWER(description) LIKE ?", 
                                 "%#{question.title.downcase}%", 
                                 "%#{question.description.downcase}%")
  
    # Create answers from similar Store records
    similar_stores.each do |store|
      question.answers.create!(content: store.content, user_id: store.user_id)
    end
  
   
  end
  
end
