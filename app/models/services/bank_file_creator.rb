module Services
  class BankFileCreator
    require 'csv'

    def initialize(organization, user)
      @user = user
      @organization = organization
      @import_bank_file
    end

    def read_and_save_nordea
      save_bank_file
      idx = 1
      from = '2099-12-31'
      to = '1900-01-01'
      CSV.foreach('KONTOUTDRAG.CSV', { :col_sep => "\t" }) do |row|
        case idx
          when 1
            # Check konto row[1]
          when 2
            # Rubrikrad
          else
            # bokföringsdatum, belopp, konto, namn, referens, saldo, , , , ,notering
            save_bank_file_row(row[0], row[1], row[2], row[3], row[4], row[10])
            from = row[0] if row[0] < from
            to = row[0] if row[0] > to
            end
        idx += idx
      end
      @import_bank_file.from_date = from
      @import_bank_file.to_date = to
      @import_bank_file.save
    end

    def save_bank_file
      @import_bank_file = ImportBankFile.new
      @import_bank_file.import_date = DateTime.now
      @import_bank_file.from_date = DateTime.now
      @import_bank_file.to_date = DateTime.now
      @import_bank_file.reference = 'Import'
      @import_bank_file.organization = @organization
      @import_bank_file.save
    end

    def save_bank_file_row(posting_date, amount, bank_account, name, reference, note)

      bank_file_row = @import_bank_file.import_bank_file_rows.build
      bank_file_row.posting_date = posting_date
      bank_file_row.amount = amount
      bank_file_row.bank_account = bank_account
      bank_file_row.name = name
      bank_file_row.reference = reference
      bank_file_row.note = note
      bank_file_row.posted = false
      bank_file_row.organization = @organization
      bank_file_row.save
    end
  end
end
