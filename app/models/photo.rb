class Photo < ApplicationRecord
  belongs_to :genre
  # optional: true を追記（これで nil を許容します）
  belongs_to :main_style, optional: true 
  
  has_many :likes, dependent: :destroy 
  has_many :photo_scores, dependent: :destroy
end
