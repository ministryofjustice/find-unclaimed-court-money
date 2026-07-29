# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data, "https://www.googletagmanager.com"
    policy.object_src  :none
    policy.script_src  :self, "https://www.googletagmanager.com"
    policy.style_src   :self
    policy.frame_src   "https://www.googletagmanager.com"
    policy.connect_src :self,
                       "https://www.google-analytics.com",
                       "https://analytics.google.com",
                       "https://www.googletagmanager.com"
    policy.base_uri    :self
  end

  # Per-request nonce added to script-src; inline <script> tags must carry the nonce attribute.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
