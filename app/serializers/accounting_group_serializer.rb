class AccountingGroupSerializer < ActiveModel::Serializer
  attributes :id, :number, :name
  has_many :accounts
  def accounts
    object.accounts.order("number")
  end
end
