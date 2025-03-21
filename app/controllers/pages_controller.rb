class PagesController < ApplicationController
  def homepage; end

  def accessibility; end

  def cookie_consent
    @consent = analytics_consent_cookie
  end
end
