module Admin
  class SessionsController < AdminController
    def new
      if current_user.present?
        redirect_to admin_upload_path and return
      end

      @login = Login.new
    end

    def create
      @login = Login.new(create_params)

      if @login.valid?
        session[:user_id] = @login.user.id
        redirect_to admin_upload_path
      else
        render :new
      end
    end

    def destroy
      session.delete(:user_id)
      redirect_to admin_path
    end

    def create_params
      params.require(:login).permit(:name, :password)
    end
  end
end
