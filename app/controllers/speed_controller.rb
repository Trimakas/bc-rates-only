class SpeedController < ApplicationController
  
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  attr_reader :shipping_speed, :flex, :fixed, :fixed_rate_amount, :flex_amount,
              :free_shipping_amount, :free, :flex_dollar_or_percent, :enabled, :marketplace
  
  MARKETPLACES = [{ text: 'Australia', value: "A39IBJ37TRP1C6" },
                  { text: 'Canada', value: "A2EUQ1WTGCTBG2" },
                  { text: 'France', value: "A13V1IB3VIYZZH" },
                  { text: 'Germany', value: "A1PA6795UKMFR9" },
                  { text: 'Italy', value: "APJ6JRA9NG5V4" },
                  { text: 'Mexico', value: "A1AM78C64UM0Y8" },
                  { text: 'Spain', value: "A1RKKUPIHCS9HS" },
                  { text: 'United Kingdom', value: "A1F83G8C2ARO7P" },
                  { text: 'United States', value: "ATVPDKIKX0DER" }]
  
  
  def save_shipping_info
    parse_params(safe_params)
    if flex_values_not_valid?
      render json: {flex_values: "not_valid"}
    elsif fixed_values_not_valid?
      render json: {fixed_values: "not_valid"}
    else
      save_or_update_speed
      head :ok
    end
  end
  
  def delete_speed_internally
    speed_to_delete = safe_params["speed_type"]
    marketplace =  safe_params["marketplace"]
    saved_speed_to_delete = current_store.speeds.find_by(marketplace: marketplace, shipping_speed: speed_to_delete)
    unless saved_speed_to_delete.nil?
      saved_speed_to_delete.delete
    end
    head :ok
  end
  
  def return_marketplaces
    marketplaces = []
    marketplace_ids = current_store.amazons.pluck(:marketplace)
    marketplace_ids.each do |market|
      marketplaces << MARKETPLACES.find {|location| location[:value] == market }
    end
    render json: marketplaces
  end
  
  def return_speed_info
    fixed_params = JSON.parse(safe_params) 
    marketplace = fixed_params["marketplace"]
    speed_to_find = fixed_params["speed"]
    speed_to_return = current_store.speeds.find_by(shipping_speed: speed_to_find, marketplace: marketplace)
    render json: speed_to_return
  end
  
  def number_of_speeds_to_return
    render json: {three_speed: current_store.amazon.three_speed?}
  end
  
  private
  
  def parse_params(safe_params)
    @marketplace = safe_params[:marketplace]
    @shipping_speed = safe_params[:speed_type]
    @enabled = safe_params[:speed_enabled]
    @flex = safe_params[:flex_enabled]
    @fixed = safe_params[:fixed_enabled]
    @fixed_rate_amount = safe_params[:fixed_rate_amount]
    @flex_amount = safe_params[:flex_above_or_below_amount]
    @free_shipping_amount = safe_params[:free_shipping_amount]
    @free = safe_params[:free_enabled]
    @flex_dollar_or_percent = safe_params[:percent_or_dollar]
  end
  
  def flex_values_not_valid?
    flex_value_check = []
    if flex
      flex_value_check << flex_amount.empty?
      flex_value_check << flex_dollar_or_percent.empty?
    end
    flex_value_check.include?(true)
  end
  
  def fixed_values_not_valid?
    fixed_value_check = []
    if fixed
      fixed_value_check << fixed_rate_amount.empty?
    end
    fixed_value_check.include?(true)    
  end
  
  def save_or_update_speed
    current_speed = current_store.speeds.where(shipping_speed: shipping_speed, marketplace: marketplace)
    if current_speed.empty?
      current_store.speeds.create(
        marketplace: marketplace,
        store_id: current_store.id,
        shipping_speed: shipping_speed,
        enabled: enabled,
        flex: flex,
        fixed: fixed,
        free: free,
        fixed_amount: fixed_rate_amount,
        flex_amount: flex_amount,
        free_shipping_amount: free_shipping_amount,
        flex_dollar_or_percent: flex_dollar_or_percent)
    else
      current_store.speeds.find_by(shipping_speed: shipping_speed, marketplace: marketplace).update(
        enabled: enabled,
        flex: flex,
        fixed: fixed,
        free: free,
        fixed_amount: fixed_rate_amount,
        flex_amount: flex_amount,
        free_shipping_amount: free_shipping_amount,
        flex_dollar_or_percent: flex_dollar_or_percent)
    end
  end
  
  def safe_params
    params.require(:bytestand_rate_info)
  end
  
end