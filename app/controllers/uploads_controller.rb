class UploadsController < ApplicationController
  before_action :authenticate

  def new
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(create_params)

    if @upload.valid? && @upload.process
      @results = @upload.results
      render :complete
    else
      render :new
    end
  end

  def authenticate
    unless current_user.present?
      redirect_to :admin, notice: "please login"
    end
  end

  def create_params
    params.require(:upload).permit(:file)
  end
end
