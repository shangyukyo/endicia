require 'endicia/request/shipment'

module Endicia
  module Request

    class Transactions < Base
      def initialize(credentials, options = {})        
        super(credentials, options)
        @tracking_numbers = options[:tracking_numbers]
        @start_datetime = options[:start_datetime]
        @end_datetime = options[:end_datetime]
        @debug = true
      end

      def process_request              
        build_xml
        
        service_url = "#{api_url}/GetTransactionsListingXML"        
        rsp = RestClient.post(service_url, { transactionsRequestXML: striped_xml_builder })        
        puts rsp
        response = parsed_response(rsp)        
      end


      def build_xml
        xml_builder.GetTransactionsListingRequest do |xml|
          add_requester(xml)
          add_request_id(xml)
          add_certified_intermediary(xml)       
          add_request_options(xml)
          add_pic_numbers(xml)
          add_adjustment_detail(xml)
        end
      end

      def add_request_options(xml)
        attributes = {          
          'StartDateTime' => @start_datetime,
          'EndDateTime' => @end_datetime,
          'TransactionType' => 'ALL',
          'RefundStatus' => 'ALL'
        }
        xml.RequestOptions(attributes)
      end

      def add_pic_numbers(xml)
        xml.PicNumbers do
          @tracking_numbers.each do |tracking_number|
            xml.PIC tracking_number
          end
        end
      end

      def add_adjustment_detail(xml)
        xml.IncludeAdjustmentDetails 'Y'
        xml.IncludeFromAddress 'Y'
        xml.IncludeTracking 'Y'
      end
    end

  end
end