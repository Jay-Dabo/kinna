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

# Tax codes ---------------------------
tax_code = Services::TaxCodeCreator.new(o1, jtest)
tax_code.tax_codes_save

# Accounting plan ---------------------
plan_k1 = Services::AccountingPlanCreator.new(o1, jtest)
plan_k1.K1_read_and_save
plan_k1.K1_tax_code_update
k1 = plan_k1.accounting_plan

plan_bas = Services::AccountingPlanCreator.new(o1, jtest)
plan_bas.BAS_read_and_save
plan_bas.BAS_tax_code_update
bas = plan_bas.accounting_plan

# Accounting period --------------------
ap13 = AccountingPeriod.new({
  name: "Räkenskapsår 2013",
  accounting_from: DateTime.new(2013,01,01),
  accounting_to: DateTime.new(2013,12,31),
  active: 'true',
  accounting_plan: bas,
  vat_period_type: 'month'
})
ap13.organization = o1
ap13.save
ap14 = AccountingPeriod.new({
  name: "Räkenskapsår 2014",
  accounting_from: DateTime.new(2014,01,01),
  accounting_to: DateTime.new(2014,12,31),
  active: 'true',
  accounting_plan: k1,
  vat_period_type: 'month'
})
ap14.organization = o1
ap14.save
ap15 = AccountingPeriod.new({
  name: "Räkenskapsår 2015",
  accounting_from: DateTime.new(2015,01,01),
  accounting_to: DateTime.new(2015,12,31),
  active: 'false',
  accounting_plan: k1,
  vat_period_type: 'month'
})
ap15.organization = o1
ap15.save

# Templates ----------------------------
templates = Services::TemplateCreator.new(o1, jtest, k1)
templates.save_templates
