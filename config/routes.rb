Rails.application.routes.draw do
get "start/index"
root "start#index"




get 'pages/home', to: "pages#home", as: :pages_home

post 'pages/start_game', to: "pages#start_game", as: :pages_start_game
post 'pages/hit', to: "pages#hit", as: :pages_hit

# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

# Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
# Can be used by load balancers and uptime monitors to verify that the app is live.
get "up" => "rails/health#show", as: :rails_health_check

end
