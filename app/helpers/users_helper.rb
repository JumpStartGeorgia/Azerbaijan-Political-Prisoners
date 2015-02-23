module UsersHelper
  def roles_editable_by_current_user
    roles = []
    Role.all.each do |role|
      roles.append(role) if can? :create, User.new(email: 'assdfasdfasdf@asdfdsffsd.com', password: '1234231432143', role: role)
    end

    return roles
  end
end
