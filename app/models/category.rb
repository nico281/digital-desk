class Category < ApplicationRecord
  has_many :children, class_name: 'Category', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Category', optional: true

  has_many :professional_categories, dependent: :destroy
  has_many :professionals, through: :professional_categories
  has_many :services, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  scope :root, -> { where(parent_id: nil) }
  scope :ordered, -> { order(name: :asc) }

  before_validation :generate_slug, on: create

  def ancestors
    return [] if parent.nil?
    [parent] + parent.ancestors
  end

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug ||= name&.parameterize
  end
end
