class ContactSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :telephone, :address, :zip, :city, :country, :comment
end
