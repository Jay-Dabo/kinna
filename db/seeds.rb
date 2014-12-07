# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Organization
o1 = Organization.find_or_create_by name: "Default organization"
o2 = Organization.find_or_create_by name: "Check organization"
o3 = Organization.find_or_create_by name: "Demo organization"

# User
jtest = User.new({
    name: "jtest",
    email: "jtest@mailinator.com",
    password: "foobar",
    password_confirmation: "foobar"
})
jtest.default_organization_id = 3
[o1,o2,o3].each do |org|
  r = jtest.organization_roles.build(name: OrganizationRole::ROLE_ADMIN)
  r.organization_id = org.id
end

r = jtest.organization_roles.build(name: OrganizationRole::ROLE_SUPERADMIN)
r.organization_id = 0
jtest.save

