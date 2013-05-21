Landable::Engine.routes.draw do
  scope path: '/landable', module: 'api' do
    resources :themes, only: [:index]
    resources :pages
  end

  scope module: 'public' do
    get '*url' => 'pages#show'
  end
end
