class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    content_resources = [Article, CriminalCode, Prisoner, Prison, Tag]
    if user.is? 'super_admin'
      can :manage, :all
    elsif user.is? 'site_admin'
      can :manage, content_resources
      can [:read, :edit, :update], PageSection
      can [:read, :new], User
      can [:edit, :create, :update, :destroy], User, role: { name: 'site_admin' }
      can [:edit, :create, :update, :destroy], User, role: { name: 'content_manager' }
    elsif user.is? 'content_manager'
      can :manage, content_resources
    end

    # Actions everyone can do:
    can :read, content_resources
    can :incidents_to_csv, Prisoner
    can :prison_prisoner_counts, Prison
    can :imprisoned_count_timeline, Prisoner
    can :article_incident_counts, Article

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
