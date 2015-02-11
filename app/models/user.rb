class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :role

  def is? ( requested_role )
    if (self.role)
      self.role.name == requested_role
    else
      return false
    end
  end
end
