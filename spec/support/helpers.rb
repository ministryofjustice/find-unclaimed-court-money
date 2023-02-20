module Helpers
  def request_login_as(name, password)
    post login_path, params: { login: { name:, password: } }
  end

  def use_admin_subdomain
    host! "admin.example.com"
  end
end
