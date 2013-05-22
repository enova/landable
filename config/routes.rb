Landable::Engine.routes.draw do
  scope path: '/landable', module: 'api' do
    resources :themes, only: [:index]
    resources :directories, only: [:index]

    resources :pages do
      get 'preview', on: :member
    end
  end

  scope module: 'public' do
    get '*url' => 'pages#show'
  end
end
