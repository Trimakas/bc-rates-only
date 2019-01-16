class AmazonCredsController < ApplicationController
  include AmazonCredsConcern
  include ApplicationConcern
  skip_before_action :verify_authenticity_token
  attr_reader :marketplace, :seller_id, :auth_token, :client_status

  def amazon_credentials_check
    parse_params
    amazon_client = create_amazon_client(marketplace, seller_id, auth_token)
    @client_status = is_amazon_client_good?(amazon_client)
    if client_status
      save_amazon_creds(marketplace, seller_id, auth_token)
      update_store_setup
    end
      render json: {are_the_amazon_creds_good: client_status}
  end
  
  def remove_amazon_credentials
    parse_params
    amazon_to_remove = Amazon.find_by(marketplace: marketplace, seller_id: seller_id, auth_token: auth_token)
    amazon_to_remove.delete
    head :ok
  end
  
  def assemble_zones(seller_id, marketplace)
    zones = []
    if !(current_store.zones.empty?)
      current_store.zones.where(selected: true, seller_id: seller_id, marketplace: marketplace).each do |zone|
        zones << {name: zone.zone_name, value: zone.bc_zone_id}
      end
    end
    return zones
  end
  
  def assemble_amazon_credentials
    amazon_credentials = []
    if !(current_store.amazons.empty?)
      current_store.amazons.each do |amazon|
        amazon_credentials << {auth_token: amazon.auth_token,
                              seller_id: amazon.seller_id,
                              marketplace: amazon.marketplace,
                              zones: assemble_zones(amazon.seller_id, amazon.marketplace)}
      end
      return amazon_credentials
    else
      empty_credentials = [{seller_id: ""}].to_json
      return empty_credentials
    end
  end
  
  def return_amazon_credentials
    render json: assemble_amazon_credentials
  end
  
  private

  def parse_params
    @marketplace = params["marketplace"].upcase
    @seller_id = params["seller_id"].upcase
    @auth_token = params["auth_token"].downcase
  end
  
end