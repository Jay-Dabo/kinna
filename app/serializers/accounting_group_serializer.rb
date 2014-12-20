class AccountingGroupSerializer < ActiveModel::Serializer
  attributes :id, :number, :name
  has_many :accounts
end
