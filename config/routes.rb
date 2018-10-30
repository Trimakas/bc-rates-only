Rails.application.routes.draw do

  root 'welcome#index'
  post '/', to: 'welcome#index'
  post 'rates', to: 'rate#rates'
  get 'where_to_send_user' => 'welcome#where_to_send_user'
  
  get '/auth/:name/callback' => 'omniauth#callback'
  get '/load' => 'omniauth#load'
  get '/uninstall' => 'omniauth#uninstall'
  
  post 'amazon_credentials_check', to: 'amazon_creds#amazon_credentials_check'
  get 'return_amazon_credentials' => 'amazon_creds#return_amazon_credentials' 
  
  get 'return_currency_info' => 'currency#return_currency_info' 
  
  post 'save_shipping_info', to: 'speed#save_shipping_info'
  post 'delete_speed_internally', to: 'speed#delete_speed_internally'
  get 'return_speed_info' => 'speed#return_speed_info'
  get 'number_of_speeds_to_return' => 'speed#number_of_speeds_to_return'  
  
  get 'return_zone_info' => 'zone#return_zone_info'
  post 'receive_zone_info' => 'zone#receive_zone_info'
end
