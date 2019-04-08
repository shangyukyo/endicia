require 'rest-client'
require 'builder'

RestClient.log = Rails.logger

module Endicia
  module Request

    class Base
      attr_accessor :debug, :response_hash
      
      TEST_URL = 'https://elstestserver.endicia.com/LabelService/EwsLabelService.asmx'
      PRODUCTION_URL = 'https://labelserver.endicia.com/LabelService/EwsLabelService.asmx'

      def initialize(credentials, options = {})
        @credentials = credentials
        @options = options
        @debug = @options[:debug] === true        
      end

      def api_url
        @credentials.mode == "production" ? PRODUCTION_URL : TEST_URL
      end

      def process_request
        raise NotImplementedError, "Override process_request in subclass"
      end

      def xml_builder
        @xml_builder ||= Builder::XmlMarkup.new
      end

      def striped_xml_builder
        xml = xml_builder.to_s.gsub('<to_s/>', '')
        puts xml if @debug
        puts "\n"*2
        xml
      end

      private
      
      def parse_response(xml)
        @response_hash = begin
          Hash.from_xml(xml)
        rescue => e
          { "SystemError" => { "Status" => -1 } }
        end
      end

      def parsed_response(xml)
        parse_response(xml).values.first.except("xmlns:xsd", "xmlns", "xmlns:xsi")
      end

      def success?(xml)
        parsed_response(xml)['Status'].to_i.zero?
      end

      def add_requester(xml)
        xml.RequesterID @credentials.requester_id
      end

      def add_request_id(xml)
        xml.RequestID SecureRandom.hex(4)
      end

      def add_pass_phrase(xml)
        xml.PassPhrase @credentials.pass_phrase
      end

      def add_signature_option(xml, signature)
        xml.Services :AdultSignature => signature, :AdultSignatureRestrictedDelivery => 'OFF'
        xml.SignatureWaiver 'FALSE'
      end

      def add_account(xml)
        xml.AccountID @credentials.account_id
      end

      def add_certified_intermediary(xml)
        xml.CertifiedIntermediary {
          add_account(xml)
          add_pass_phrase(xml)
        }
      end      

      def add_shipper(xml, address)
        xml.FromCompny(address[:company]) if address[:company]
        xml.FromName(address[:name])
        street1, street2 = Array(address[:address])
        xml.ReturnAddress1(street1)
        xml.ReturnAddress2(street2) if street2
        xml.FromPhone(address[:phone_number]) if address[:phone_number]
        xml.FromCity(address[:city])
        xml.FromState(address[:state])
        xml.FromPostalCode(address[:postal_code])
      end

      def add_recipient(xml, address)
        xml.ToCompny(address[:company]) if address[:company]
        xml.ToName(address[:name])
        street1, street2 = Array(address[:address])
        xml.ToAddress1(street1)
        xml.ToAddress2(street2) if street2
        xml.ToPhone(address[:phone_number]) if address[:phone_number]
        xml.ToCity(address[:city])
        xml.ToState(address[:state])
        xml.ToCountryCode(address[:country_code]) if address[:country_code]
        xml.ToPostalCode(address[:postal_code])
      end
    end
    
  end
end



