class Store < ActiveRecord::Base
  has_many :amazons, dependent: :destroy
  has_many :speeds, dependent: :destroy
  has_many :zones, dependent: :destroy
  validates :owner_id, uniqueness: true
end