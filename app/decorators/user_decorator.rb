class UserDecorator < Draper::Decorator
  delegate_all

  def roles(organization_id)
    @roles ||= organization_roles.where(organization_id: organization_id).pluck(:name)
    @roles.join ', '
  end
end
