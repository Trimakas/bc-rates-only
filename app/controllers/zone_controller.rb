class ZoneController < ApplicationController
  skip_before_action :verify_authenticity_token
  attr_reader :zones
  include ShippingZoneConcern
  
  BODY = {name: "FBA Shipping by ByteStand", 
          type: "carrier_37", 
          settings: {carrier_options: {delivery_services: [], packaging: []}}, 
          enabled: true, 
          handling_fees:{"fixed_surcharge"=>0}}.to_json
  
  def return_zone_info
    get_shipping_zones(current_store)
    zones = current_store.zones
    render json: zones 
  end
  
  def receive_zone_info
    @zones = return_zones_from_params
    add_amazon_info_to_zones
    get_shipping_methods_for_zones(@zones)
    add_rate_to_shipping_zone
    update_selected_zones
    update_not_selected_zones
    head :ok
  end
  
  private
  
  def add_amazon_info_to_zones
    zones.each do |selected_zone_id|
      current_zone = current_zone(selected_zone_id)
      current_zone.update(seller_id: seller_id_from_params,
                          marketplace: marketplace_from_params)
    end
  end
  
  def marketplace_from_params
    params["marketplace"]
  end
  
  def seller_id_from_params
    params["seller_id"]
  end
  
  #just need the zone id is all
  def return_zones_from_params
    just_zones = []
    params["zones"].each do |zone|
      just_zones << zone["value"]
    end
    return just_zones
  end
  
  def get_shipping_methods_for_zones(zones)
    zones.each do |zone|
      shipping_methods = HTTParty.get(
        "https://api.bigcommerce.com/stores/#{current_store.bc_hash}/v2/shipping/zones/#{zone}/methods",
        :headers => create_request_headers(current_store))
      does_fba_shipping_exist_in_zone(shipping_methods, zone)
    end
  end
  
  def does_fba_shipping_exist_in_zone(shipping_methods, zone)
    shipping_methods.each do |method|
      if method["type"] == "carrier_37"
        remove_fba_ship(method["id"], zone)
      end
    end
  end
  
  def remove_fba_ship(shipping_method_id, zone)
    HTTParty.delete(
      "https://api.bigcommerce.com/stores/#{current_store.bc_hash}/v2/shipping/zones/#{zone}/methods/#{shipping_method_id}",
      :headers => create_request_headers(current_store))
  end
  
  def add_rate_to_shipping_zone
    zones.each do |zone|
      HTTParty.post(
          "https://api.bigcommerce.com/stores/#{current_store.bc_hash}/v2/shipping/zones/#{zone}/methods",
          :body => BODY,
          :headers => create_request_headers(current_store))
    end
  end
  
  def update_selected_zones
    zones.each do |selected_zone_id|
      current_zone = current_zone(selected_zone_id)
      current_zone.update(selected: true)
    end
  end
  
  def update_not_selected_zones
    all_zone_ids = current_store.zones.where(seller_id: seller_id_from_params, marketplace: marketplace_from_params).pluck(:bc_zone_id)
    zones_to_de_select = all_zone_ids - zones
    if zones_to_de_select.length > 0
      get_shipping_methods_for_zones(zones_to_de_select)
      zones_to_de_select.each do |set_zone_to_false|
        false_zone = current_store.zones.find_by(bc_zone_id: set_zone_to_false)
        false_zone.update(selected: false)
      end
    end
  end
  
  def current_zone(zone_id)
    current_store.zones.find_by(bc_zone_id: zone_id)
  end
  
end