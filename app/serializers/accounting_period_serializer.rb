class AccountingPeriodSerializer < ActiveModel::Serializer
  attributes :id, :name, :allow_from, :allow_to
end
