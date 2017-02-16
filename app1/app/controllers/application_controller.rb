class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # use cancan to authorize resources
  # you will want to configure ability.rb model for your specific business rules
  # and probably want to move the following to each controller (with configurations)
  # load_and_authorize_resource

  # set $models for application layout header to programatically set links to models
  Rails.application.eager_load!
  $models = ActiveRecord::Base.descendants

  # set the title of the app
  $app_name = `pwd`.split('/').last.humanize

  # converts url?q=k1,v1,k2,v2... to { k1 => v1, k2 => v2 }.  Used to allow for queries.
  def get_query_hash key='q'
    q = (params[key] || "").split ','
    $query_hash = Hash[*q]
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to main_app.root_url, :alert => exception.message
  end


  protected

  def configure_permitted_parameters
    #devise_parameter_sanitizer.permit(:sign_up, keys: [:business_id, :super_admin_role,...])
  end
end

