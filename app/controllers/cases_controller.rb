class CasesController < ApplicationController
  def show
    @case = Case.find_by!(account_number: params[:account_number])
  end
end
