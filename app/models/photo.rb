class Photo < ApplicationRecord
  belongs_to :genre
  belongs_to :main_style
end
