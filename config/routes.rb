Rails.application.routes.draw do
  root to: 'pages#home'
  get '/auth/blockstack/callback' => 'pages#blockstack_callback'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
