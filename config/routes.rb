Landable::Engine.routes.draw do
  # API
  scope path: '/landable', module: 'api' do
    resources :pages
  end

  scope module: 'public' do
    get '*url' => 'pages#show'
  end
end
