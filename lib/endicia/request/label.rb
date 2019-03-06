require 'endicia/request/shipment'
require 'endicia/label'

module Endicia
  module Request

    class Label < Shipment
      def initialize(credentials, options = {})        
        super(credentials, options)

        @mail_class = @options[:mail_class]
        @customs_info = @options[:customs_info] || {}
        @customs_items = @options[:customs_items] || []
        @label_specification = @options[:label_specification] || {}
        @label_specification[:image_format] ||= 'PNG'
        @label_specification[:label_size] ||= '4x6'
        @filepath = @options[:filepath]
        @signature_option = @options[:signature_option]
        @label_specification.merge!(filepath: @filepath)
      end

      def process_request        
        build_xml
        service_url = "#{api_url}/GetPostageLabelXML"
        rsp = RestClient.post(service_url, { labelRequestXML: striped_xml_builder })

        Endicia::Label.new(parsed_response(rsp), @label_specification)
      end

      def add_partner_customer(xml)
        customer_id = @options[:customer_id] || @shipper[:name]
        trasaction_id = @options[:trasaction_id] || SecureRandom.hex(6)
        xml.PartnerCustomerID(customer_id)
        xml.PartnerTransactionID(trasaction_id)
      end

      def add_label_format(xml)
        xml.LabelSize @label_specification[:label_size]
        xml.ImageFormat(@label_specification[:image_format])
        xml.ImageResolution 203
      end

      def add_customs_info(xml)
        xml.CustomsInfo {
          xml.ContentsType @customs_info[:purpose]
          if @customs_info[:purpose] == 'Other'
            xml.ContentsExplanation @customs_info[:explanation]
          end
          xml.EelPfc @customs_info[:eel_pfc]
          add_customs_items(xml)
        }
      end

      def add_customs_items(xml)
        xml.CustomsItems {
          @customs_items.each do |item|
            total_value = item[:quantity].to_i * item[:value].to_f
            total_value = ('%.2f' % total_value.to_s).to_f
            weight = ('%.2f' % item[:weight].to_s).to_f

            xml.CustomsItem {
              xml.Description item[:description]
              xml.Quantity item[:quantity]
              xml.Weight item[:weight]
              xml.Value total_value
              xml.CountryOfOrigin item[:origin_country]
            }
          end
        }
      end

      def build_xml
        attributes = {}

        if international_shipping? 
          attributes = { "LabelType" => "International", "LabelSubtype" => "Integrated" }
        end
          
        xml_builder.LabelRequest(attributes) do |xml|
          add_requester(xml)
          add_account(xml)
          add_pass_phrase(xml)
          xml.MailClass(@mail_class)
          add_sort_type(xml) if @mail_class =~ /ParcelSelect/            
          xml.WeightOz(@weight.round(1))
          xml.IncludePostage 'TRUE'
          xml.ResponseOptions("PostagePrice" => 'FALSE')
          add_signature_option(xml, @signature_option) if @signature_option
          xml.DeliveryTimeDays 'TRUE'
          add_insurance(xml) if @insured_value.to_f > 0
          add_dimensions(xml) if @dimensions
          add_partner_customer(xml)
          add_recipient(xml, @recipient)
          add_shipper(xml, @shipper)
          xml.ValidateAddress 'TRUE'
          add_customs_info(xml) if international_shipping?
          add_label_format(xml)
        end
      end
    end

  end
end