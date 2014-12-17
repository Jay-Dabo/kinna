class ContactsController < ApplicationController
  load_and_authorize_resource through: :current_organization

  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  def index
    @breadcrumbs = [['Contacts']]
    @contacts = @contacts.order('name').page(params[:page])
  end

  def new
  end

  def show
  end

  def create
    @contact = Contact.new contact_params
    @contact.organization = current_organization
    respond_to do |format|
      if @contact.save
        # Contact.save as service
        u = current_organization.users.find_by_email @contact.email
        if u
          @contact_relation = u.contact_relations.build
          @contact_relation.organization = current_organization
          @contact_relation.contact = @contact
          @contact_relation.save
        end
        format.html { redirect_to contacts_path, notice: "#{t(:contact_added)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_add)} #{t(:contact)}"
        format.html { render :new }
      end
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to contacts_path, notice: "#{t(:contact)} #{t(:was_successfully_updated)}"
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:contact)}"
      render :show
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: "#{t(:contact)} #{t(:was_destroyed)}"
  end

  private

  def contact_params
    params.require(:contact).permit(Contact.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Contacts', contacts_path], ["#{t(:new)} #{t(:contact)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Contacts', contacts_path], [@contact.name]]
  end
end
