namespace :admin do
  root to: "dashboard#index"
  resources :organizations, only: :index do
    get :search, on: :collection
    member do
      put :verify
      put :reject
    end
  end

  resources :hidden_users, only: [:index, :show] do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :hidden_budget_investments, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :debates, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :proposals, only: [:index, :show] do
    resources :milestones, controller: "proposal_milestones"
    resources :progress_bars, except: :show, controller: "proposal_progress_bars"
  end

  resources :hidden_proposals, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :spending_proposals, only: [:index, :show, :edit, :update] do
    member do
      patch :assign_admin
      patch :assign_valuators
    end

    get :summary, on: :collection
  end

  resources :proposal_notifications, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :budgets do
    member do
      put :calculate_winners
    end

    resources :groups, except: [:show], controller: "budget_groups" do
      resources :headings, except: [:show], controller: "budget_headings"
    end

    resources :budget_investments, only: [:index, :show, :edit, :update] do
      resources :milestones, controller: 'budget_investment_milestones'
      resources :progress_bars, except: :show, controller: "budget_investment_progress_bars"
      member { patch :toggle_selection }
    end

    resources :budget_phases, only: [:edit, :update]
  end

  resources :milestone_statuses, only: [:index, :new, :create, :update, :edit, :destroy]

  resources :signature_sheets, only: [:index, :new, :create, :show]

  resources :banners, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection { get :search }
  end

  resources :comments, only: :index do
    member do
      put :restore
      put :confirm_hide
    end
  end

  resources :tags, only: [:index, :create, :update, :destroy]

  resources :officials, only: [:index, :edit, :update, :destroy] do
    get :search, on: :collection
  end

  resources :settings, only: [:index, :update]
  put :update_map, to: "settings#update_map"

  resources :moderators, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  resources :valuators, only: [:show, :index, :edit, :update, :create, :destroy] do
    get :search, on: :collection
    get :summary, on: :collection
  end

  resources :valuator_groups

  resources :managers, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  resources :administrators, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end

  resources :users, only: [:index, :show]

  scope module: :poll do
    resources :polls do
      get :booth_assignments, on: :collection
      patch :add_question, on: :member

      resources :booth_assignments, only: [:index, :show, :create, :destroy] do
        get :search_booths, on: :collection
        get :manage, on: :collection
      end

      resources :officer_assignments, only: [:index, :create, :destroy] do
        get :search_officers, on: :collection
        get :by_officer, on: :collection
      end

      resources :recounts, only: :index
      resources :results, only: :index
    end

    resources :officers, only: [:index, :new, :create, :destroy] do
      get :search, on: :collection
    end

    resources :booths do
      get :available, on: :collection

      resources :shifts do
        get :search_officers, on: :collection
      end
    end

    resources :questions, shallow: true do
      resources :answers, except: [:index, :destroy], controller: 'questions/answers' do
        resources :images, controller: 'questions/answers/images'
        resources :videos, controller: 'questions/answers/videos'
        get :documents, to: 'questions/answers#documents'
      end
      post '/answers/order_answers', to: 'questions/answers#order_answers'
    end
  end

  resources :verifications, controller: :verifications, only: :index do
    get :search, on: :collection
  end

  resource :activity, controller: :activity, only: :show

  resources :newsletters do
    member do
      post :deliver
    end
    get :users, on: :collection
  end

  resources :admin_notifications do
    member do
      post :deliver
    end
  end

  resources :system_emails, only: [:index] do
    get :view
    get :preview_pending
    put :moderate_pending
    put :send_pending
  end

  resources :emails_download, only: :index do
    get :generate_csv, on: :collection
  end

  resource :stats, only: :show do
    get :proposal_notifications, on: :collection
    get :direct_messages, on: :collection
    get :polls, on: :collection
  end

  namespace :legislation do
    resources :processes do
      resources :questions
      resources :proposals do
        member { patch :toggle_selection }
      end
      resources :draft_versions
      resources :milestones
      resources :progress_bars, except: :show
      resource :homepage, only: [:edit, :update]
    end
  end

  namespace :api do
    resource :stats, only: :show
  end

  resources :geozones, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :geographies, only: [:index, :new, :create, :edit, :update, :destroy]

  namespace :site_customization do
    resources :pages, except: [:show] do
      resources :cards, only: [:index]
    end
    resources :images, only: [:index, :update, :destroy]
    resources :content_blocks, except: [:show]
    delete '/heading_content_blocks/:id', to: 'content_blocks#delete_heading_content_block', as: 'delete_heading_content_block'
    get '/edit_heading_content_blocks/:id', to: 'content_blocks#edit_heading_content_block', as: 'edit_heading_content_block'
    put '/update_heading_content_blocks/:id', to: 'content_blocks#update_heading_content_block', as: 'update_heading_content_block'
    resources :information_texts, only: [:index] do
      post :update, on: :collection
    end
  end

  resource :homepage, controller: :homepage, only: [:show]

  namespace :widget do
    resources :cards
    resources :feeds, only: [:update]
  end
end
