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
x05 = TaxCode.new({code: 05, text: "Momspliktig försäljning", sum_method: 'vat_period', code_type: 'vat'})
x05.organization = o1
x05.save
x10 = TaxCode.new({code: 10, text: "Utgående moms på försäljning 25 %", sum_method: 'accounting_period', code_type: 'vat'})
x10.organization = o1
x10.save
x11 = TaxCode.new({code: 11, text: "Utgående moms på försäljning 12 %", sum_method: 'accounting_period', code_type: 'vat'})
x11.organization = o1
x11.save
x12 = TaxCode.new({code: 12, text: "Utgående moms på försäljning 6 %", sum_method: 'accounting_period', code_type: 'vat'})
x12.organization = o1
x12.save
x48 = TaxCode.new({code: 48, text: "Ingående moms", sum_method: 'accounting_period', code_type: 'vat'})
x48.organization = o1
x48.save
x49 = TaxCode.new({code: 49, text: "Moms att betala eller få tillbaka", sum_method: 'total', code_type: 'vat'})
x49.organization = o1
x49.save

x50 = TaxCode.new({code: 50, text: "Avgiftspliktig bruttolön utan förmåner", sum_method: 'wage_period', code_type: 'wage'})
x50.organization = o1
x50.save
x55 = TaxCode.new({code: 55, text: "Underlag full arbetsgivaravgift 26 - 65 år", sum_method: 'subset_55', code_type: 'wage'})
x55.organization = o1
x55.save
x57 = TaxCode.new({code: 57, text: "Underlag arbetsgivaravgift - 26 år", sum_method: 'subset_57', code_type: 'wage'})
x57.organization = o1
x57.save
x59 = TaxCode.new({code: 59, text: "Underlag arbetsgivaravgift 65 år - ", sum_method: 'subset_59', code_type: 'wage'})
x59.organization = o1
x59.save
x56 = TaxCode.new({code: 56, text: "Full arbetsgivaravgift 26 - 65 år", sum_method: 'subset_56', code_type: 'wage'})
x56.organization = o1
x56.save
x58 = TaxCode.new({code: 58, text: "Arbetsgivaravgift - 26 år", sum_method: 'subset_58', code_type: 'wage'})
x58.organization = o1
x58.save
x60 = TaxCode.new({code: 60, text: "Arbetsgivaravgift 65 år - ", sum_method: 'subset_60', code_type: 'wage'})
x60.organization = o1
x60.save
x78 = TaxCode.new({code: 78, text: "Summa arbetsgivaravgifter", sum_method: 'accounting_period', code_type: 'wage'})
x78.organization = o1
x78.save
x81 = TaxCode.new({code: 81, text: "Lön och förmåner inkl SINK", sum_method: 'include_81', code_type: 'wage'})
x81.organization = o1
x81.save
x82 = TaxCode.new({code: 82, text: "Avdragen skatt från lön och förmåner", sum_method: 'accounting_period', code_type: 'wage'})
x82.organization = o1
x82.save
x99 = TaxCode.new({code: 99, text: "Summa avgift och skatt att betala", sum_method: 'total', code_type: 'wage'})
x99.organization = o1
x99.save

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

# Template ----------------------------
t1 = Template.new({
    name: "Inköp kontant",
    description: "Inköp kontant direktavskrivning",
    accounting_plan: k1
})
t1.organization = o1
t1.save
a1 = k1.accounts.where('number = ?', 4000).first
t1i1 = TemplateItem.new({
    account_id: a1.id,
    description: "Varor",
    enable_debit: true,
    enable_credit: false
})
t1i1.organization = o1
t1i1.template = t1
t1i1.save
a2 = k1.accounts.where('number = ?', 2640).first
t1i2 = TemplateItem.new({
    account_id: a2.id,
    description: "Ingående moms",
    enable_debit: true,
    enable_credit: false
})
t1i2.organization = o1
t1i2.template = t1
t1i2.save
a3 = k1.accounts.where('number = ?', 1920).first
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
    description: "Försäljning 25% moms",
    accounting_plan: k1
})
t2.organization = o1
t2.save
a1 = k1.accounts.where('number = ?', 3000).first
t2i1 = TemplateItem.new({
    account_id: a1.id,
    description: "Försäljning och utfört arbete samt övriga momspliktiga intäkter",
    enable_debit: false,
    enable_credit: true
})
t2i1.organization = o1
t2i1.template = t2
t2i1.save
a2 = k1.accounts.where('number = ?', 2610).first
t2i2 = TemplateItem.new({
    account_id: a2.id,
    description: "Utgående moms, 25 %",
    enable_debit: false,
    enable_credit: true
})
t2i2.organization = o1
t2i2.template = t2
t2i2.save
a3 = k1.accounts.where('number = ?', 1500).first
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
    description: "Betalning kundfaktura",
    accounting_plan: k1
})
t3.organization = o1
t3.save
a1 = k1.accounts.where('number = ?', 1500).first
t3i1 = TemplateItem.new({
    account_id: a1.id,
    description: "Kundfordringar ",
    enable_debit: false,
    enable_credit: true
})
t3i1.organization = o1
t3i1.template = t3
t3i1.save
a2 = k1.accounts.where('number = ?', 1920).first
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