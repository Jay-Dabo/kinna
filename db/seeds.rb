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

# Template ----------------------------
t1 = Template.new({
    name: "Inköp kontant",
    description: "Inköp kontant direktavskrivning"
})
t1.organization = o1
t1.save
a1 = Account.where('number = ?', 4000).first
t1i1 = TemplateItem.new({
    account_id: a1.id,
    description: "Varor",
    enable_debit: true,
    enable_credit: false
})
t1i1.organization = o1
t1i1.template = t1
t1i1.save
a2 = Account.where('number = ?', 2640).first
t1i2 = TemplateItem.new({
    account_id: a2.id,
    description: "Ingående moms",
    enable_debit: true,
    enable_credit: false
})
t1i2.organization = o1
t1i2.template = t1
t1i2.save
a3 = Account.where('number = ?', 1920).first
t1i3 = TemplateItem.new({
    account_id: a3.id,
    description: "PlusGiro",
    enable_debit: false,
    enable_credit: true
})
t1i3.organization = o1
t1i3.template = t1
t1i3.save
#-----------------------------------------
t2 = Template.new({
    name: "Försäljning",
    description: "Försäljning 25% moms"
})
t2.organization = o1
t2.save
a1 = Account.where('number = ?', 3000).first
t2i1 = TemplateItem.new({
    account_id: a1.id,
    description: "Försäljning och utfört arbete samt övriga momspliktiga intäkter",
    enable_debit: false,
    enable_credit: true
})
t2i1.organization = o1
t2i1.template = t2
t2i1.save
a2 = Account.where('number = ?', 2610).first
t2i2 = TemplateItem.new({
    account_id: a2.id,
    description: "Utgående moms, 25 %",
    enable_debit: false,
    enable_credit: true
})
t2i2.organization = o1
t2i2.template = t2
t2i2.save
a3 = Account.where('number = ?', 1500).first
t2i3 = TemplateItem.new({
    account_id: a3.id,
    description: "Kundfordringar",
    enable_debit: true,
    enable_credit: false
})
t2i3.organization = o1
t2i3.template = t2
t2i3.save
#-----------------------------------------
t3 = Template.new({
    name: "Kundbetalning",
    description: "Betalning kundfaktura"
})
t3.organization = o1
t3.save
a1 = Account.where('number = ?', 1500).first
t3i1 = TemplateItem.new({
    account_id: a1.id,
    description: "Kundfordringar ",
    enable_debit: false,
    enable_credit: true
})
t3i1.organization = o1
t3i1.template = t3
t3i1.save
a2 = Account.where('number = ?', 1920).first
t3i2 = TemplateItem.new({
    account_id: a2.id,
    description: "PlusGiro",
    enable_debit: true,
    enable_credit: false
})
t3i2.organization = o1
t3i2.template = t3
t3i2.save
#-----------------------------------------