class Ability
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  include CanCan::Ability
  def initialize(user)
    if user.super_admin_role? 
      can [:manage], [:all]
    end
    if user.super_user_role? 
      can [:manage], [Business, Consumable, Device]
    end
    if user.super_user_role? 
      can [:read, :update], [Patient, Result]
    end
    if user.clinic_admin_role? 
      can [:read, :update], [Business], :id => user.business_id
    end
    if user.clinic_admin_role? 
      can [:manage], [Result], :business_id => user.business_id
    end
    if user.clinic_admin_role? 
      can [:read], [Device], :business_id => user.business_id
    end
    if user.clinic_admin_role?  || user. clinic_user_role? 
      can [:manage], [Patient], :business_id => user.business_id
    end
    if user.clinic_user_role? 
      can [:read], [Business], :id => user.business_id
    end
    if user.clinic_user_role? 
      can [:read], [Result], :user_id => user.id
    end
    if user.patient_role? 
      can [:read], [Result], :user_id => user.id
    end
    if user.device_role? 
      can [:manage], [Result], :business_id => user.business_id
    end
  end
end
