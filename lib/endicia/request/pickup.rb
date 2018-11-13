module Endicia
  module Request

    class Pickup < ::Endicia::Request::Base
      def initialize(credentials, options = {})
        super(credentials, options)
        @pickup_location = @options[:pickup_location]
        @weight_lbs = @options[:weight_lbs]
        @mail_counts = @options[:mail_counts]
        @package_location = @options[:package_location] || 'NONE'
        @confirmation_number = @options[:confirmation_number]
      end

      def process_request
        build_xml
        service_url = "#{api_url}/GetPackagePickupXML"
        rsp = RestClient.post(service_url, { packagePickupRequestXML: striped_xml_builder })
        parse_response(rsp)
      end

      def process_cancel_request
        build_cancel_xml
        service_url = "#{api_url}/GetPackagePickupCancelXML"
        rsp = RestClient.post(service_url, { packagePickupCancelRequestXML: striped_xml_builder })
        parse_response(rsp)
      end

      def build_cancel_xml
        xml_builder.PackagePickupCancelRequest do |xml|
          add_requester(xml)
          add_request_id(xml)
          add_certified_intermediary(xml)
          add_pickup_address(xml)
          xml.ConfirmationNumber @confirmation_number
        end
      end

      def add_pickup_address(xml)
        if @pickup_location
          xml.UseAddressOnFile 'NO'
          xml.PhysicalPickupAddress {
            xml.FirstName @pickup_location[:first_name]
            xml.LastName @pickup_location[:last_name]
            xml.CompanyName @pickup_location[:company]
            xml.Address Array(@pickup_location[:address]).join(', ')
            xml.City @pickup_location[:city]
            xml.State @pickup_location[:state]
            xml.Zip5 @pickup_location[:postal_code]
            xml.Phone @pickup_location[:phone_number]
          }
        else
          xml.UseAddressOnFile 'YES'
        end
      end

      def add_package(xml)
        xml.EstimatedWeightLb @weight_lbs
      end

      def add_mail_counts(xml)
        @mail_counts.each_pair do |k, v|
          xml.tag!(k, v)
        end
      end

      def build_xml
        xml_builder.PackagePickupRequest do |xml|
          add_requester(xml)
          add_request_id(xml)
          add_certified_intermediary(xml)
          add_pickup_address(xml)
          add_mail_counts(xml)
          add_package(xml)
          xml.PackageLocation @package_location
          xml.SpecialInstructions 'Ring Bell'
        end
      end
    end
  
  end
end