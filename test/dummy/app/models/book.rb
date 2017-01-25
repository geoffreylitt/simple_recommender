class Book < ActiveRecord::Base
  has_and_belongs_to_many :tags

  has_many :likes
  has_many :users, through: :likes

  belongs_to :author, class_name: "User"

  include SimpleRecommender::Recommendable
end
