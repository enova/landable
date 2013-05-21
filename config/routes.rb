Landable::Engine.routes.draw do
  scope path: '/landable', module: 'api' do
    resources :themes,    only: [:index, :show]
    resources :templates, only: [:index, :show]
    resources :pages
  end

  scope module: 'public' do
    get '*url' => 'pages#show'
  end
end
