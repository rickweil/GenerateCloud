class WelcomeController < ApplicationController

  ########### @todo NO_AUTHENTICATION
  if $AUTHENTICATOR
    skip_before_action :authenticate_user!, :only => [:index]
  end

  def index
  end
end
