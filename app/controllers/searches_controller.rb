class SearchesController < ApplicationController
  include Pagy::Backend

  def new
    @search = Search.new
  end

  def results
    @search = Search.new(search_params)

    if @search.valid?
      @pagy, @cases = pagy(@search.results)
    else
      render :new
    end
  end

  def search_params
    params.require(:search).permit(:keywords, :date_from, :date_to)
  end
end
