class ProfessionalCategory < ApplicationRecord
  belongs_to :professional
  belongs_to :category

  validates :professional_id, uniqueness: { scope: :category_id }
end
