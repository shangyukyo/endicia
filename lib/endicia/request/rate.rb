module Endicia
  module Request

    class Rate < ::Endicia::Request::Shipment
      def initialize(credentials, options = {})
        super(credentials, options)
        @options[:pricing] ||= 'Retail'
        @mail_class = @options[:mail_class]
        if @mail_class.nil?
          @mail_class = international_shipping? ? 'International' : 'Domestic'
        end
      end

      def process_request
        build_xml
        service_url = "#{api_url}/CalculatePostageRatesXML"
        rsp = RestClient.post(service_url, { postageRatesRequestXML: striped_xml_builder })

        puts rsp
        parsed_response(rsp)
      end

      def process_retail_request
        xml_builder.PostageRateRequest do |xml|
          add_requester(xml)
          add_certified_intermediary(xml)
          xml.MailClass(@mail_class)
          xml.Pricing 'Retail'
          xml.WeightOz(@weight.round(1))
          xml.ResponseOptions("PostagePrice" => 'FALSE')
          add_insurance(xml) if @insured_value.to_f > 0
          add_dimensions(xml) if @dimensions
          xml.DeliveryTimeDays 'TRUE'
          xml.FromPostalCode @shipper[:postal_code]
          xml.ToPostalCode @recipient[:postal_code]
          xml.ToCountryCode @recipient[:country_code]
        end

        service_url = "#{api_url}/CalculatePostageRateXML"
        rsp = RestClient.post(service_url, { postageRateRequestXML: striped_xml_builder })
        puts rsp
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
          xml.DeliveryTimeDays 'TRUE'
          xml.FromPostalCode @shipper[:postal_code]
          xml.ToPostalCode @recipient[:postal_code]
          xml.ToCountryCode @recipient[:country_code]
        end
      end
    end

  end
end