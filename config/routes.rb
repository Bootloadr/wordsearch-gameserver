Rails.application.routes.draw do
 
  get 'welcome/join'

  get 'welcome/create'
 
  get 'game/index'
  post 'game/info'
  post 'game/back'
  get 'adminp/index'
  get 'newp/index'
  get 'pnewp/index'
  post 'pnewp/play'
  get 'padminp/index'
  post 'padminp/play'
  get 'grid/index'

  post 'newp/join'

  post 'adminp/create'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'welcome#index'
  mount ActionCable.server => "/cable"
end
