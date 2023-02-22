Rails.application.routes.draw do
  get "/healthcheck/live", to: proc { [200, {}, %w[OK]] }
  get "/healthcheck/ready", to: GovukHealthcheck.rack_response

  get "/accessibility", to: "pages#accessibility"
  get "/search", to: "searches#new"
  get "/search_results", to: "searches#results"

  resources :cases, param: :account_number, only: [:show]

  constraints subdomain: "admin" do
    get "/", to: "sessions#new", as: :admin
    post "/", to: "sessions#create", as: :login
    delete "/logout", to: "sessions#destroy"

    get "/upload", to: "uploads#new"
    post "/upload", to: "uploads#create"
  end

  get "/404", to: "errors#not_found"

  root to: "pages#homepage"
end
