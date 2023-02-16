class UploadsController < ApplicationController
  before_action :authenticate

  def new; end

  def authenticate
    unless current_user.present?
      redirect_to :admin, notice: "please login"
    end
  end
end
