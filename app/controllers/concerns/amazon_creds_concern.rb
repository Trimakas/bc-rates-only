module AmazonCredsConcern
extend ActiveSupport::Concern
include ApplicationConcern
  
  COUNTRY_CODES = {"AU"=> "A39IBJ37TRP1C6",
                  "CA"=> "A2EUQ1WTGCTBG2",
                  "FR"=> "A13V1IB3VIYZZH",
                  "DE"=> "A1PA6795UKMFR9",
                  "IT"=> "APJ6JRA9NG5V4",
                  "MX"=> "A1AM78C64UM0Y8",
                  "ES"=> "A1RKKUPIHCS9HS",
                  "GB"=> "A1F83G8C2ARO7P",
                  "US"=> "ATVPDKIKX0DER"}
  
  def is_amazon_client_good?(amazon_client)
    begin
      amazon_client.list_all_fulfillment_orders.parse
    rescue StandardError
      false
    else
      true
    end
  end
  
  def save_amazon_creds(marketplace, seller_id, auth_token)
    unless is_marketplace_already_saved_for_store?(marketplace)
      Amazon.create(seller_id: seller_id,
                    marketplace: marketplace,
                    country_code: get_country_code(marketplace),
                    auth_token: auth_token,
                    store_id: current_store.id,
                    three_speed: three_speeds?(marketplace))
    else
      amazon_to_update = current_store.amazons.find_by(seller_id: seller_id, marketplace: marketplace)
      amazon_to_update.update(seller_id: seller_id,
                              marketplace: marketplace,
                              country_code: get_country_code(marketplace),
                              auth_token: auth_token,
                              store_id: current_store.id,
                              three_speed: three_speeds?(marketplace))      
    end
  end
  
  def is_marketplace_already_saved_for_store?(marketplace)
    array_of_current_marketplaces = current_store.amazons.pluck(:marketplace)
    array_of_current_marketplaces.include?(marketplace)
  end
  
  
  def three_speeds?(marketplace)
    marketplace == "ATVPDKIKX0DER"
  end
  
  def update_store_setup
    current_store.update_attributes(setup: true)
  end

  def get_country_code(marketplace)
    COUNTRY_CODES.key(marketplace)
  end
end