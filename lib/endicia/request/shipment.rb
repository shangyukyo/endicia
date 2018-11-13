module Endicia
  module Request

    class Shipment < Base
      
      def initialize(credentials, options = {})
        super(credentials, options)

        @shipper = @options[:shipper]
        @recipient = @options[:recipient]
        @recipient[:country_code] ||= 'US'
        @package = @options[:package]
        @weight = @package[:weight]
        @dimensions = @package[:dimensions]
        @insured_value = @package[:insured_value] || 0
      end

      def add_dimensions(xml)
        xml.MailpieceDimensions {
          xml.Length @dimensions[:length]
          xml.Width @dimensions[:width]
          xml.Height @dimensions[:height]
        }
      end

      def add_insurance(xml)
        xml.Service("InsuredMail" => "Endicia")
        xml.InsuredValue @insured_value
      end

      def add_sort_type(xml)
        xml.SortType 'Nonpresorted'
        xml.EntryFacility 'Other'
      end

      def international_shipping?
        @recipient[:country_code] != 'US'
      end
    end

  end
end