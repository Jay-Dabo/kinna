class Employee < ActiveRecord::Base
  # t.string   :name
  # t.integer  :birth_year
  # t.datetime :begin
  # t.datetime :end
  # t.decimal  :salary
  # t.decimal  :tax
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :begin, :ending, :salary, :tax, :birth_year

  validates :name, presence: true
  validates :birth_year, presence: true

  belongs_to :organization
  has_many :wages

  has_many :contact_relations, as: :parent do
    def search_by_org(o)
      where('organization_id = ?', o.id)
    end
  end

  has_many :contacts, through: :contact_relations do
    def search_by_org(o)
      where('"contact_relations"."organization_id" = ?', o.id)
    end
  end

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def can_delete?
    retur false if wages.size > 0
    true
  end
end
