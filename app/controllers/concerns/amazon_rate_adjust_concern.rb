module AmazonRateAdjustConcern
  extend ActiveSupport::Concern
  include ApplicationConcern
  attr_reader :parsed_amazon_rates, :current_speeds, :shop, :speed_details, :cart_amount, :marketplace
  
  SPEEDS = ["Standard", "Priority", "Expedited"]
  
  def adjust_amazon_rates(parsed_amazon_rates, cart_amount, marketplace)
    initialize_variables(parsed_amazon_rates, cart_amount, marketplace)
    round_amazon_rates
    which_speeds_are_enabled_in_db?
    remove_non_enabled_speeds_from_amazon_rates
    get_enabled_speeds_from_db
    get_enabled_speed_details_that_are_true
    return @parsed_amazon_rates
  end
  
  def initialize_variables(parsed_amazon_rates, cart_amount, marketplace)
    @parsed_amazon_rates = parsed_amazon_rates
    @shop = get_store_via_params(my_params)
    @cart_amount = cart_amount
    @marketplace = marketplace
  end
  
  def round_amazon_rates
    parsed_amazon_rates.each do |rate|
      rate[:total_price] = (rate[:total_price].ceil).round(0)
    end

  end
  
  def which_speeds_are_enabled_in_db? #this returns a simple array with the speed names listed
    @current_speeds = shop.speeds.where(enabled: true, marketplace: marketplace).pluck(:shipping_speed)
  end
  
  def remove_non_enabled_speeds_from_amazon_rates # removes the rate quotes from Amazon that are not enabled in our db
    speed_to_remove = SPEEDS - current_speeds
    unless speed_to_remove.nil?
      speed_to_remove.each do |speed_getting_deleted|
        parsed_amazon_rates.delete_if{|speed| speed[:speed] == speed_getting_deleted}
      end
    end
  end
  
  def get_enabled_speeds_from_db #this queries the db with the enabled speeds from above
    @speed_details = []
    current_speeds.each do |speed|
      @speed_details << shop.speeds.find_by(shipping_speed: speed, marketplace: marketplace)
    end
  end
  
  def get_enabled_speed_details_that_are_true #this gets all the details that are true each speed
    speed_details.each do |speed|
      speed_name = {speed: speed[:shipping_speed]}
      whats_turned_on = speed.attributes.select{|k,v| v == true }
      walk_thru_each_rate_type(speed_name.merge(whats_turned_on),speed)
    end
  end
  
  def walk_thru_each_rate_type(speed_hash, speed_from_db)
    if speed_hash.has_key?("flex")
      handle_flex_rates(speed_from_db)
    end
    if speed_hash.has_key?("fixed")
      handle_fixed_rates(speed_from_db)
    end
    if speed_hash.has_key?("free")
      handle_free_shipping(speed_from_db)
    end
  end
  
  def handle_flex_rates(speed_from_db)
    dollar_or_percent = speed_from_db[:flex_dollar_or_percent]
    flex_amount = speed_from_db[:flex_amount]
    speed = speed_from_db[:shipping_speed]
    parsed_amazon_rates.each do |rate|
      if rate.has_value?(speed)
        rate[:total_price] = dollar_or_percent == "$" ? rate[:total_price] = rate[:total_price].to_f + flex_amount.to_f : rate[:total_price] = rate[:total_price].to_f * (1 + (flex_amount.to_f/100))
      end
    end
  end
  
  def handle_fixed_rates(speed_from_db)
    fixed_amount = speed_from_db[:fixed_amount]
    speed = speed_from_db[:shipping_speed]
    parsed_amazon_rates.each do |rate|
      if rate.has_value?(speed)
        rate[:total_price] = fixed_amount
      end
    end
  end

  def handle_free_shipping(speed_from_db)
    free_shipping_amount = speed_from_db.free_shipping_amount
    free_shipping_amount.nil? ? free_shipping_amount = 0 : free_shipping_amount
    speed = speed_from_db[:shipping_speed]
    parsed_amazon_rates.each do |rate|
      if rate.has_value?(speed)
        if cart_amount >= free_shipping_amount
          rate[:total_price] = 0
        end
      end
    end
  end
  
  def my_params
    params.require(:base_options)
  end

end