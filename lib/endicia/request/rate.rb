require 'endicia/request/shipment'

module Endicia
  module Request

    class Rate < Shipment
      def initialize(credentials, options = {})
        super(credentials, options)
        @options[:pricing] ||= 'Retail'
        @mail_class = @options[:mail_class]
        @signature_option = @options[:signature_option]

        if @mail_class.nil?
          @mail_class = international_shipping? ? 'International' : 'Domestic'
        end
      end

      def process_request
        build_xml
        puts striped_xml_builder
        service_url = "#{api_url}/CalculatePostageRatesXML"
        rsp = RestClient.post(service_url, { postageRatesRequestXML: striped_xml_builder })
        
        parsed_response(rsp)
      end

      def build_xml
        xml_builder.PostageRatesRequest do |xml|
          add_requester(xml)
          add_certified_intermediary(xml)
          xml.MailClass(@mail_class)
          xml.WeightOz(@weight.round(1))
          add_sort_type(xml) if @mail_class =~ /ParcelSelect/            
          xml.ResponseOptions("PostagePrice" => 'FALSE')
          add_insurance(xml) if @insured_value.to_f > 0
          add_dimensions(xml) if @dimensions
          add_signature_option(xml, @signature_option) if @signature_option
          xml.DeliveryTimeDays 'TRUE'
          xml.FromPostalCode @shipper[:postal_code]
          xml.ToPostalCode @recipient[:postal_code]
          xml.ToCountryCode @recipient[:country_code]
        end
      end
    end

  end
end