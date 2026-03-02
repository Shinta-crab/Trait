class PhotoScore < ApplicationRecord
  belongs_to :photo
  belongs_to :axis
end
