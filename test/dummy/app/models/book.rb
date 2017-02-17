class Book < ActiveRecord::Base
  include SimpleRecommender::Recommendable

  has_and_belongs_to_many :tags

  has_many :likes
  has_many :users, through: :likes

  belongs_to :author, class_name: "User"

  similar_by :users
end
