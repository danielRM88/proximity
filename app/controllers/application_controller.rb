class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def system_error
    render :file => 'public/500.html', :status => :error, :layout => false
  end
end
