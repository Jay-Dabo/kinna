
= Kinna - basic accounting software

Kinna atempts to be a basic accounting software for the organizations in Sweden.

  - It should use the BAS 2014 konto plan.

  - All data should be exportable using the SIE format.

  - Import using the SIE format should be supported.

== Data model:

    User (authentication)
      email, password, name

    Organization
      has_many OrganizationRole (joins with user and organization)
        - vat_number
        - name
        - address
        - zip
        - city

    Period
      belongs_to :organization
      has_many :verificates

    AccountType
      # Should contain all the accounts in the BAS 2014 serie with proper defaults
        - expense boolean(yes/no)
        - number (integer)
        - name (string)

    Account
      # The accounts used by an organization.
      # An organization can either use the default ones from accountType, or create their own
      belongs_to :organization
        - number (integer) (uniq scoped to organization)
        - name (string) (uniq scoped to organization)
        - state (active, inactive)
        - expense boolean (yes/no)

    Verificate
      # The verificate 'head', should contain date,state,period.
      # MUST validate verification_item sum to be 0
      belongs_to :period
      belongs_to :organization
      has_one :related_verificate # another verificate
      has_many :verificate_items
      has_many :comments
        - date
        - description


    VerificateItem
      # A row in the 'Verificate', should contain the account and amount and possible a description
      belongs_to :verificate
      belongs_to :organization
      belongs_to :account

        - direction: enum(credit, debit) # Better name than direction?
        - description (text)
        - amount (integer)

    Comments
      # A series of comments can be added to a verificate.
      belongs_to :parent (Verificate)
        - user_id
        - content (text)
