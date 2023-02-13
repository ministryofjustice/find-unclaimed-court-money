class SearchesController < ApplicationController
  def new
    @search = Search.new
  end

  def results
    search = Search.new(search_params)
    @cases = Case.all
  end

  def search_params
    params.require(:search).permit(:keywords, :date_from, :date_to)
  end
end
