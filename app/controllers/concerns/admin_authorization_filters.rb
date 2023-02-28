require "ipaddr"

module AdminAuthorizationFilters
  def self.included(base)
    base.before_action :filter_ips
  end

protected

  def filter_ips
    user_ip = IPAddr.new(request.remote_ip)
    allowed_ips = Rails.application.config.allowlisted_ips

    if allowed_ips.present?
      verified = allowed_ips.any? do |allowed_ip|
        allowed_ip = IPAddr.new(allowed_ip)
        allowed_ip.include?(user_ip)
      end

      unless verified
        Rails.logger.error("#{user_ip} not allowed access")
        render file: "public/403.html", status: :forbidden, layout: false
      end
    end
  end
end
