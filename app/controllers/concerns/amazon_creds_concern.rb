module AmazonCredsConcern
extend ActiveSupport::Concern
include ApplicationConcern
  
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
                    auth_token: auth_token,
                    store_id: current_store.id,
                    three_speed: three_speeds?(marketplace))
    else
      current_store.amazons.update(seller_id: seller_id,
                                  marketplace: marketplace,
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

end