Landable::Engine.routes.draw do
  scope path: '/landable', module: 'api' do
    resources :themes, only: [:index]
    resources :directories, only: [:index, :show], :constraints => {:id => /[%a-zA-Z0-9\/_.~-]*/}

    resources :pages do
      post 'preview', on: :collection
    end

    resources :access_tokens, only: [:create, :destroy]
  end

  scope module: 'public' do
    get '*url' => 'pages#show', :constraints => {:url => /[a-zA-Z0-9\/_.~-]*/}
  end
end
