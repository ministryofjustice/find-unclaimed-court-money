class SearchesController < ApplicationController
  include Pagy::Backend

  def new
    @search = Search.new
  end

  def results
    @search = Search.new(search_params)

    if @search.valid?
      respond_to do |format|
        format.html { @pagy, @cases = pagy(@search.results) }
        format.csv do
          @cases = @search.results
          filename = "Unclaimed Court Accounts#{Time.zone.today}"
          response.headers["Content-Disposition"] = "attachment; filename=#{filename}.csv"
          render csv: @cases
        end
      end
    else
      render template: "searches/new", formats: [:html]
    end
  end

private

  def search_params
    params.require(:search).permit(:keywords, :date_from, :date_to)
  end
end
