module BCRateResponseConcern
  require 'date'
  extend ActiveSupport::Concern
  include ApplicationConcern
  
  attr_reader :rate_quotes, :min_date, :max_date
  
  def prep_bc_rate_response(parsed_amazon_rates)
    @rate_quotes = []
    parsed_amazon_rates.each do |speed|
      delivery_range_prep(speed)
      @rate_quotes << {code: speed[:service_code],
                      display_name: "#{speed[:service_name]}: Estimated #{delivery_range(min_date, max_date)}",
                      cost: {
                        currency: speed[:currency],
                        amount: speed[:total_price]
                      }
                    }
    end
  end
  
  def delivery_range_prep(speed)
    @min_date = ""
    @max_date = ""
    if speed[:currency] == "USD"
      @min_date = (Date.parse(speed[:min_delivery_date].to_s)).strftime("%b. %d")
      @max_date = (Date.parse(speed[:max_delivery_date].to_s)).strftime("%b. %d")
    else
      @min_date = (Date.parse(speed[:min_delivery_date].to_s)).strftime("%d %b.")
      @max_date = (Date.parse(speed[:max_delivery_date].to_s)).strftime("%d %b.")      
    end
  end
  
  def delivery_range(min, max)
    if min == max
      return "#{min}"
    else
      return "#{min} - #{max}" 
    end
  end
  
  def bc_rate_response
    {
      quote_id: "fba_shipping",
      messages: [],
    	carrier_quotes: [{
    			carrier_info: {
    				code: "bytestand",
    				display_name: "FBA Shipping"
    			},
    			quotes: rate_quotes
    		}],
    }
  end
  
  def bc_rate_response_when_no_amazon_response
    {
      quote_id: "fba_shipping",
      messages: [],
    	carrier_quotes: [{
    			carrier_info: {
    				code: "bytestand",
    				display_name: "FBA Shipping"
    			},
    			quotes: []
    		}],
    }
  end

end
