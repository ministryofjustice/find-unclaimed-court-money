class PingController < ActionController::Base # rubocop:disable Rails/ApplicationController
  protect_from_forgery with: :exception

  before_action :authenticate_deploy_dashboard!, only: :deploy_info

  def index
    render json: { status: "ok" }
  end

  def deploy_info
    render json: Deployment.info
  end

private

  def authenticate_deploy_dashboard!
    expected_secret = ENV.fetch("DEPLOY_DASHBOARD_SHARED_SECRET", nil)
    provided_secret = request.headers["X-Deploy-Dashboard-Secret"]

    return if expected_secret.present? &&
      provided_secret.present? &&
      ActiveSupport::SecurityUtils.secure_compare(provided_secret, expected_secret)

    head :unauthorized
  end
end
