module AmazonRateConcern
  extend ActiveSupport::Concern
  include ApplicationConcern
  include AmazonRateAdjustConcern
  attr_reader :name, :address1, :address2, :city, :state, :country_code, :zip, :sku_and_quantity, :amazon_rates_array
  
  SIMPLE_RATES = ["ATVPDKIKX0DER", "A39IBJ37TRP1C6"]
  NAME = "Rate Person"
    
  Address = Struct.new(:name, :line_1, :line_2, :line_3, :city, :state_or_province_code, :country_code, :postal_code)
  Item = Struct.new(:seller_sku, :seller_fulfillment_order_item_id, :quantity)


  def get_always_present_shipping_info(my_params) #everything but name and address, sometimes name and address isn't present when they preview rates in the cart
    @city = my_params[:destination][:city]
    @country_code = my_params[:destination][:country_iso2]
    if @country_code == "IT"
      @state = "MI"
    else
      @state = my_params[:destination][:state_iso2]
    end
    @zip = my_params[:destination][:zip]
  end
  
  def get_name_and_address(my_params)
    if do_we_need_a_fake_address?(my_params)
      @address1 = "123 Main Street"
    else
      @address1 = my_params[:destination][:street_1]
      @address2 = my_params[:destination][:street_2]
    end
  end
  
  def do_we_need_a_fake_address?(my_params)
    my_params[:destination][:street_1].empty?
  end
  
  def setup_address_struct
    Address.new(NAME, address1, address2, "", city, state, country_code, zip)
  end
  
  def setup_items_struct
    items = []
    sku_and_quantity.map do |product|
      seller_sku = product[:sku]
      seller_fulfillment_order_item_id = "bytestand_#{(0...8).map { (65 + rand(26)).chr }.join.downcase}"
      quantity = product[:quantity]
      items <<  Item.new(seller_sku, seller_fulfillment_order_item_id, quantity)
    end
  end
  
  def get_skus_and_quantity(my_params)
    @sku_and_quantity = []
    my_params[:items].each do |product|
      @sku_and_quantity << {sku: product["sku"], quantity: product["quantity"]}
    end
  end
  
  def simple_amazon_rate?(speed)
    SIMPLE_RATES.include?(speed["MarketplaceId"])
  end
  
  def parse_rates_from_amazon(amazon_rates)
    @amazon_rates_array = []
    if is_speed_array?(amazon_rates)
      amazon_rates["FulfillmentPreviews"]["member"].each do |speed|
        fulfill_array_speed(speed)
      end
    else
      fulfill_hash_speed(amazon_rates)
    end  
    return @amazon_rates_array
  end
  
  def is_speed_array?(rates)
    rates["FulfillmentPreviews"]["member"].kind_of?(Array)
  end
  
  def fulfill_hash_speed(parsed_amazon_rates)
    if parsed_amazon_rates["FulfillmentPreviews"]["member"]["IsFulfillable"] == "true"
      parse_complex_hash_rates(parsed_amazon_rates)
    end
  end
  
  def fulfill_array_speed(speed)
    if speed["IsFulfillable"] == "true"
      if simple_amazon_rate?(speed)
        parse_simple_rates(speed)
      else
        parse_complex_rates(speed)
      end
    end
  end
  
  def parse_complex_hash_rates(parsed_amazon_rates)
    number = Random.new.rand(1..10)
    amazon_rates_array  << {service_name: parsed_amazon_rates["FulfillmentPreviews"]["member"]["ShippingSpeedCategory"],
                        service_code: "FBA+#{number}",
                        total_price: sum_total_complex_hash_price(parsed_amazon_rates),
                        currency: find_non_us_currency_code_from_hash(parsed_amazon_rates),
                        min_delivery_date: DateTime.rfc3339(parsed_amazon_rates["FulfillmentPreviews"]["member"]["FulfillmentPreviewShipments"]["member"]["EarliestArrivalDate"]).to_time,
                        max_delivery_date: DateTime.rfc3339(parsed_amazon_rates["FulfillmentPreviews"]["member"]["FulfillmentPreviewShipments"]["member"]["LatestArrivalDate"]).to_time}
  end
  
  def sum_total_complex_hash_price(parsed_amazon_rates)
    amount = 0
    parsed_amazon_rates["FulfillmentPreviews"].each do |item|
      item.each do |fee|
        if fee["EstimatedFees"].kind_of?(Hash)
          fee["EstimatedFees"]["member"].each do |value|
            amount += value["Amount"]["Value"].to_f
          end
        end
      end
    end
    return amount.round(2)
  end
  
  ##### its actually US, Mexico, Canada and Australia are like this..
  def parse_simple_rates(speed)
    number = Random.new.rand(1..10)
    amazon_rates_array  << {service_name: speed["ShippingSpeedCategory"],
                  service_code: "FBA+#{number}",
                  total_price: (speed["EstimatedFees"]["member"]["Amount"]["Value"]).to_f,
                  currency: speed["EstimatedFees"]["member"]["Amount"]["CurrencyCode"],
                  min_delivery_date: DateTime.rfc3339(speed["FulfillmentPreviewShipments"]["member"]["EarliestArrivalDate"]).to_time,
                  max_delivery_date: DateTime.rfc3339(speed["FulfillmentPreviewShipments"]["member"]["LatestArrivalDate"]).to_time}
  end
  
  ####### just for the EU
  def parse_complex_rates(speed)
    number = Random.new.rand(1..10)
    amazon_rates_array  << {service_name: speed["ShippingSpeedCategory"],
                        service_code: "FBA+#{number}",
                        total_price: sum_total_price(speed),
                        currency: find_non_us_currency_code(speed),
                        min_delivery_date: DateTime.rfc3339(speed["FulfillmentPreviewShipments"]["member"]["EarliestArrivalDate"]).to_time,
                        max_delivery_date: DateTime.rfc3339(speed["FulfillmentPreviewShipments"]["member"]["LatestArrivalDate"]).to_time}
  end
  
  def sum_total_price(speed)
    amount = 0
    speed["EstimatedFees"]["member"].each do |fee|
      amount += fee["Amount"]["Value"].to_f
    end
    return amount.round(2)
  end
  
  def find_non_us_currency_code_from_hash(parsed_amazon_rates)
    currency_code_array = []
    parsed_amazon_rates["FulfillmentPreviews"]["member"]["EstimatedFees"].each do |fees|
      fees.each do |values|
        if values.kind_of?(Array)
          values.each do |currency|
            currency_code_array << currency["Amount"]["CurrencyCode"]
          end
        end
      end
    end
  return currency_code_array[0]
  end
  
  def find_non_us_currency_code(speed)
    currency_code_array = []
    speed["EstimatedFees"]["member"].each do |data|
      currency_code_array << data["Amount"]["CurrencyCode"]
    end
  return currency_code_array[0]
  end

  def determine_transit_duration(arrival_date)
    today = DateTime.now
    delivery = DateTime.parse(arrival_date)
    (delivery - today).round
  end

end