class User < ActiveRecord::Base
  # t.string :name
  # t.string :email,              null: false, default: ""
  # t.string :encrypted_password, null: false, default: ""
  # t.string   :reset_password_token
  # t.datetime :reset_password_sent_at
  # t.datetime :remember_created_at
  # t.integer :default_locale, default: 0 # defaults to english
  # t.integer :default_organization_id, default: null

  enum default_locale: [:en, :se]
  LOCALE_EN = 0
  LOCALE_SE = 1

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable, :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :default_locale,
                  :email, :password, :password_confirmation, :remember_me # by devise

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

  belongs_to :default_organization, class_name: 'Organization'
  has_many :organization_roles

  validates :email, presence: true, uniqueness: true

  def can_delete?
    false
  end

  # @todo Update comment with better description on why #parent_name is needed.
  # Probably used by contact_relation controller and/or view.
  # This still doesn't make sense, 'parent_name' should be name of the parent
  # this returns the name of the current object.
  def parent_name
    name
  end

  def superadmin?
    @superadmin ||= organization_roles.where(organization_id: 0).where(name: 'superadmin').count > 0
  end

  def admin_in_org(o)
    return true if organizations_roles.where(organization_id: o.id).where(name: 'admin').count > 0
    false
  end

  # Used by Devise to check if the user object can sign in.
  # @todo implement suspended user check here.
  def active_for_authentication?
    super
  end

  # When on sale, we want to display the user name not as an select but as a string.
  # simple_form f.input :user, as:string
  # => #<User:0x007f8a4f374278>
  # instead, display this:
  def to_s
    name
  end
end
