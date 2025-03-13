class ApplicationController < ActionController::Base
  default_form_builder(GOVUKDesignSystemFormBuilder::FormBuilder)

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def analytics_consent_cookie
    cookies && cookies[ConsentCookie::COOKIE_NAME]
  end
  helper_method :analytics_consent_cookie

  def analytics_allowed?
    analytics_consent_cookie == ConsentCookie::ACCEPT
  end
  helper_method :analytics_allowed?
end
