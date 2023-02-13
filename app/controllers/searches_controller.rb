class SearchesController < ApplicationController
  include Pagy::Backend

  def new
    @search = Search.new
  end

  def results
    search = Search.new(search_params)

    # title = Model.arel_table[:title]
    # Model.where(title.matches("%#{query}%"))
    @pagy, @cases = pagy(Case.where("lower(case_name) LIKE ?", "%#{search.keywords.downcase}%"))
  end

  def search_params
    params.require(:search).permit(:keywords, :date_from, :date_to)
  end
end
