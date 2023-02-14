Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response

  get "/accessibility", to: "pages#accessibility"
  get "/search", to: "searches#new"
  get "/search_results", to: "searches#results"

  resources :cases, only: [:show]

  root to: "pages#homepage"
end
