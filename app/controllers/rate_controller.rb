class RateController < ApplicationController
  include AmazonRateConcern
  include BCRateResponseConcern
  include CartRequestConcern
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  attr_reader :address, :items, :rate_preview, :marketplace
    
  EU_COUNTRY_CODES = [ 'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 
                      'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB', 'GF', 'GP', 'MQ', 'ME', 
                      'YT', 'RE', 'MF', 'GI', 'AX', 'PM', 'GL', 'BL', 'SX', 'AW', 'CW', 'WF', 'PF', 'NC', 'TF', 'AI', 
                      'BM', 'IO', 'VG', 'KY', 'FK', 'MS', 'PN', 'SH', 'GS', 'TC', 'AD', 'LI', 'MC', 'SM', 'VA', 'JE', 
                      'GG', 'GI', 'CH', 'IM', 'HR']  
    
  def rates
    prep_amazon_rate_request
    rate_preview = request_amazon_rates
    if rate_preview != "no_rates"
      pre_adjusted_parsed_amazon_rates = parse_rates_from_amazon(rate_preview)
      final_amazon_rates = adjust_amazon_rates(pre_adjusted_parsed_amazon_rates, get_cart_amount(my_params), marketplace)
      prep_bc_rate_response(final_amazon_rates)
      Rails.logger.info "\n #{bc_rate_response} \n"
      render json: bc_rate_response
    else
      render json: bc_rate_response_when_no_amazon_response
    end
  end
  
  private
  
  def prep_amazon_rate_request
    get_always_present_shipping_info(my_params)
    get_name_and_address(my_params)
    get_skus_and_quantity(my_params)
    @address = setup_address_struct
    @items = setup_items_struct
  end
  
  def request_amazon_rates
    client = create_fulfillment_client
    begin
      client.get_fulfillment_preview(address, items).parse
    rescue StandardError => e
      Rails.logger.info "\nWhat went wrong with the request for rates from Amazon? #{e}\n"
      return "no_rates"
    end
  end
  
  def create_fulfillment_client
    amazon = which_amazon_creds_to_use
    client = ""
    if amazon
      @marketplace = amazon.marketplace
      seller_id = amazon.seller_id
      auth_token = amazon.auth_token
      client = create_amazon_client(marketplace, seller_id, auth_token)
    else
      Rails.logger.info "\n sorry this store #{store} doesn't have a matching marketplace for the order with customers #{get_name_and_address(my_params)}\n"
    end
    return client
  end
  
  def destination_country_code
    my_params["destination"]["country_iso2"]
  end
  
  def current_store_country_codes
    store.amazons.pluck(:country_code)
  end
  
  def which_amazon_creds_to_use
    if current_store_country_codes.include?(destination_country_code)
      return store.amazons.find_by(country_code: destination_country_code)
    else
      return pick_closest_country_code_to_order
    end
  end
  
  def pick_closest_country_code_to_order
    if EU_COUNTRY_CODES.include?(destination_country_code)
      pick_the_enabled_eu_marketplace
    else
      return nil
    end
  end
  
  def pick_the_enabled_eu_marketplace
    amazon_eu_country_codes = ["GB", "IT", "DE", "FR", "ES"]
    enabled_country_codes = amazon_eu_country_codes & current_store_country_codes
    amazon_client_to_use = store.amazons.find_by(country_code: enabled_country_codes[0])
    if amazon_client_to_use
      return amazon_client_to_use
    else
      return nil
    end
  end
  
  def store
    get_store_via_params(my_params)
  end
  
  def my_params
    params.require(:base_options)
  end
  
end