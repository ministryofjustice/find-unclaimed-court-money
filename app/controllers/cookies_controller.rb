class CookiesController < ApplicationController
  def accept
    cookies[:allow_analytics] = {
      value: "accept",
      expires: 1.year,
    }

    redirect_back fallback_location: root_path, flash: { cookies_consent_updated: "accept" }
  end

  def reject
    cookies[:allow_analytics] = {
      value: "reject",
      expires: 1.year,
    }

    redirect_back fallback_location: root_path, flash: { cookies_consent_updated: "reject" }
  end
end
