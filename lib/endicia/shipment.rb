require 'endicia/credentials'
require 'endicia/request/account'
require 'endicia/request/rate'
require 'endicia/request/delete'
require 'endicia/request/label'
require 'endicia/request/pickup'
require 'endicia/request/track'
require 'endicia/request/transactions'

module Endicia
  class Shipment
    def initialize(options = {})
      @credentials = Credentials.new(options)
    end

    def label(options = {})
      Request::Label.new(@credentials, options).process_request
    end

    def rate(options = {})      
      Request::Rate.new(@credentials, options).process_request
    end

    def retail_rate(options = {})
      Request::Rate.new(@credentials, options).process_retail_request
    end    
    
    def pickup(options)
      Request::Pickup.new(@credentials, options).process_request
    end

    def cancel_pickup(options)
      Request::Pickup.new(@credentials, options).process_cancel_request
    end

    def track(options = {})
      Request::Track.new(@credentials, options).process_request
    end

    def delete(options = {})
      Request::Delete.new(@credentials, options).process_request
    end

    def active_api_access(options = {})
      Request::Account.new(@credentials, options).active_api_access
    end

    def change_pass_phrase(new_pass_phrase, options = {})
      Request::Account.new(@credentials, options).change_pass_phrase(new_pass_phrase)
    end

    def buy_postage(amount, options = {})
      Request::Account.new(@credentials, options).buy_postage(amount)
    end

    def transactions(options = {})
      Request::Transactions.new(@credentials, options).process_request
    end

  end
end