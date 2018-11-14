require 'endicia/request/base'
module Endicia
  module Request

    class Delete < Base
      def initialize(credentials, options = {})
        super(credentials, options)
        @customs_number = @options[:customs_number]
        @transaction_id = @options[:transaction_id]
      end

      def process_request        
        build_xml
        service_url = "#{api_url}/GetRefundXML"        
        rsp = RestClient.post(service_url, { refundRequestXML: striped_xml_builder })
        parse_response(rsp)
      end

      def build_xml
        xml_builder.RefundRequest do |xml|
          add_requester(xml)
          add_request_id(xml)
          add_certified_intermediary(xml)
          xml.PicNumbers { xml.PicNumber @customs_number }
          xml.TransactionsIds { xml.TransactionId @transaction_id }
        end
      end

    end

  end
end