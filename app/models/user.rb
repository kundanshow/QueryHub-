class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

         has_many :questions, dependent: :destroy
         has_many :stores, dependent: :destroy
         has_many :answers, dependent: :destroy
end
