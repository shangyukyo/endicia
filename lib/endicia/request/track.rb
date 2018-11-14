require 'endicia/request/base'

module Endicia
  module Request

    class Track < Base
      def initialize(credentials, options = {})
        super(credentials, options)
        @tracking_number = @options[:tracking_number]
      end

      def process_request
        build_xml
        service_url = "#{api_url}/StatusRequestXML"
        rsp = RestClient.post(service_url, { packageStatusRequestXML: striped_xml_builder })
        puts rsp

        parsed_response(rsp)
      end

      def build_xml
        xml_builder.PackageStatusRequest do |xml|
          add_requester(xml)
          add_request_id(xml)
          add_certified_intermediary(xml)
          xml.RequestOptions("PackageStatus" => "COMPLETE")
          xml.PicNumbers {
            xml.PicNumber @tracking_number
          }
        end
      end
    end

  end
end