class AnalysisResult < ApplicationRecord
  belongs_to :user
  has_one :my_style, dependent: :destroy
end
