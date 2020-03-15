Rails.application.routes.draw do

  namespace 'api' do
    namespace 'v1' do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/v1/auth/registrations'
      }
      resources :users, only: [:index]
      resources :items do
        collection do
          get :search
        end
        member do
          post :change_exhibit
          post :buy
        end
      end
      resources :histories, only: [:index]
    end
  end
end
