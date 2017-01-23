class Book < ActiveRecord::Base
  has_and_belongs_to_many :users

  include SimpleRecommender::Recommendable
end
