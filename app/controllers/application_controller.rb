class ApplicationController < ActionController::Base
  include Authlogic
  
  protect_from_forgery
  layout 'application'
  
  helper_method :current_user, :logged_in?
  
  before_filter :correct_safari_and_ie_accept_headers
  before_filter { |c| User.current_user = c.current_user if c.current_user }
  before_filter { |c| (c.action_has_layout = false) if c.request.xhr? }
  
  before_filter :set_selected_project
  
  def correct_safari_and_ie_accept_headers
    ajax_request_types = ['text/javascript', 'application/json', 'text/xml']
    request.accepts.sort!{ |x, y| ajax_request_types.include?(y.to_s) ? 1 : -1 } if request.xhr?
  end
  
  def local_request?
    %w(staging).include?(Rails.env) || super
  end
  
  def default_paging
    { :page => params[:page], :per_page => 50 }
  end
  
  protected
  
  def logged_in?
    !current_user.nil?
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  def set_selected_project
    @project = params[:project_id] ? Project.find_by_id(params[:project_id]) : current_user.projects.first
  end
  
  def set_status_and_error_for(results)
    flash[:success] = results[:successes].join("\n\n") unless results[:successes].empty?
    flash[:error] = results[:failures].join("\n\n") unless results[:failures].empty?
  end
end