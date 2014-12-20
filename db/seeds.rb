# Organization -------------------------
o1 = Organization.find_or_create_by name: "Default organization"
o2 = Organization.find_or_create_by name: "Check organization"
o3 = Organization.find_or_create_by name: "Demo organization"

# User ---------------------------------
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
jtest.default_organization_id = o1.id
r = jtest.organization_roles.build(name: OrganizationRole::ROLE_SUPERADMIN)
r.organization_id = 0
jtest.save

# Accounting period --------------------
ap14 = AccountingPeriod.new({
                     name: "Räkenskapsår 2014",
                     accounting_from: DateTime.new(2014,01,01),
                     accounting_to: DateTime.new(2014,12,31),
                    active: 'true'
})
ap14.organization = o1
ap14.save
ap15 = AccountingPeriod.new({
                              name: "Räkenskapsår 2015",
    accounting_from: DateTime.new(2015,01,01),
    accounting_to: DateTime.new(2015,12,31),
   active: 'false'
})
ap15.organization = o1
ap15.save

# Accounting plan ---------------------
plan = Services::AccountingPlanCreator.new(o1, jtest)
plan.K1_read_and_save