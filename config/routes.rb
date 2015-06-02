Rails.application.routes.draw do
  scope ':locale', locale: /#{I18n.available_locales.join("|")}/ do
    post '/users', to: 'users#create'
    devise_for :users, controllers: { confirmations: 'users/confirmations', omniauth: 'users/omniauth', passwords: 'users/passwords', registrations: 'users/registrations', sessions: 'users/sessions', unlocks: 'users/unlocks' }, constraints: { format: :html }

    resources :tags

    resources :prisons do
      collection do
        get 'prison_prisoner_counts', constraints: { format: :json }, defaults: { format: :json }
      end
    end

    resources :criminal_codes

    resources :articles do
      collection do
        get 'article_incident_counts', constraints: { format: :json }, defaults: { format: :json }
      end
    end

    resources :prisoners do
      collection do
        get 'incidents_to_csv', constraints: { format: :csv }, defaults: { format: :csv }
        get 'imprisoned_count_timeline', constraints: { format: :json }, defaults: { format: :json }
      end
    end

    resources :users, constraints: { format: :html }

    # root paths
    get '/about', to: 'root#about'
    get '/methodology', to: 'root#methodology'
    get '/csv_zip', to: 'root#to_csv_zip', constraints: { format: :csv }, defaults: { format: :csv }


    # home page
    root 'root#index'

    get '*path', to: redirect("/#{I18n.default_locale}") # handles /en/fake/path/whatever
  end

  get '', to: redirect("/#{I18n.default_locale}") # handles /
  get '*path', to: redirect("/#{I18n.default_locale}/%{path}") # handles /not-a-locale/anything

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
