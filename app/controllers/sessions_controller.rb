class SessionsController < ApplicationController
  def new
    @login = Login.new
  end

  def create
    @login = Login.new(create_params)

    if @login.valid?
      session[:user_id] = @login.user.id.to_s
      redirect_to upload_path
    else
      render :new
    end
  end

  def create_params
    params.require(:login).permit(:name, :password)
  end
end
