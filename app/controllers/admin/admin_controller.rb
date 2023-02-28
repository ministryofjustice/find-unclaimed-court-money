module Admin
  class AdminController < ApplicationController
    include AdminAuthorizationFilters
  end
end
