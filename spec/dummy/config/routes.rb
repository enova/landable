Rails.application.routes.draw do
  mount Landable::Engine => '/' # move this to the end of your routes block
  get 'priority', to: 'priority#show'
end
