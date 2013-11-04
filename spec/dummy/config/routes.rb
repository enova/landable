Rails.application.routes.draw do
  get 'priority', to: 'priority#show'

  mount Landable::Engine => "/"
end
