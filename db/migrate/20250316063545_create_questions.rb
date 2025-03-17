class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :title
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.integer :views_count
      t.integer :answer_count

      t.timestamps
    end
  end
end
