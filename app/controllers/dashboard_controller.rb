class DashboardController < ApplicationController
  before_action :authenticate_user!  # Ensures only logged-in users can access the dashboard

  def index
    # Fetch user's questions per day for the line chart
    @questions_per_day = current_user.questions.group_by_day(:created_at).count
    Rails.logger.info @questions_per_day

    # Fetch user's answers grouped by topic for the pie chart
    @answers_per_title = current_user.answers.joins(:question).group("questions.title").count
  end
end 
