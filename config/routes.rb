Landable::Engine.routes.draw do
  scope path: Landable.configuration.api_namespace, module: 'api' do
    resources :access_tokens, only: [:create, :update, :destroy]
    resources :categories, only: [:index]

    resources :directories, only: [:index, :show], constraints: {
      id: /[%a-zA-Z0-9\/_.~-]*/
    }

    resources :assets, only: [:index, :show, :create, :update]

    concern :has_assets do
      resources :assets, only: [:index, :update, :destroy]
    end

    resources :themes,
      only: [:index, :show, :create, :update],
      concerns: :has_assets

    resources :pages, concerns: :has_assets do
      post 'preview', on: :collection
      post 'publish', on: :member
    end

    resources :page_revisions, only: [:index, :show] do
      post 'revert_to', on: :member
    end
  end

  scope module: 'public' do
    get '*url' => 'pages#show', constraints: {
      url: /[a-zA-Z0-9\/_.~-]*/
    }
  end
end
