module Services
  class VerificateItemsCreator

    def initialize(organization, user, verificate, verificate_items)
      @user = user
      @organization = organization
      @verificate = verificate
      @verificate_items = verificate_items
    end

    def save
      Rails.logger.info "#{@verificate_items.inspect}"
      @verificate_items[:row].each do |item|
        verificate_item = @verificate.verificate_items.build
        verificate_item.organization = @organization
        verificate_item.account = item[1][:account]
        verificate_item.description = item[1][:description]
        verificate_item.debit = item[1][:debit]
        verificate_item.credit = item[1][:credit]
        verificate_item.save
      end
      if @verificate.balanced?
        @verificate.state_change('mark_final')
      end
    end
  end
end
