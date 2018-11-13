module Endicia
  module Request
    class Account < Base

      def active_api_access
        xml_builder.ChangePassPhraseRequest("TokenRequested" => false) do |xml|
          xml.RequesterID @credentials.requester_id
          xml.RequestID SecureRandom.hex(4)
          xml.CertifiedIntermediary {
            xml.AccountID @credentials.account_id
            xml.PassPhrase @credentials.tmp_pass_phrase
          }
          xml.NewPassPhrase @credentials.pass_phrase
        end

        body = xml_builder.to_s.gsub('<to_s/>', '')
        service_url = "#{api_url}/ChangePassPhraseXML"
        rsp = RestClient.post(service_url, { changePassPhraseRequestXML: body })
        puts rsp.body
        rsp
      end

      def buy_postage(amount)
        xml_builder.RecreditRequest do |xml|
          add_requester(xml)
          add_request_id(xml)
          add_certified_intermediary(xml)
          xml.RecreditAmount amount
        end

        service_url = "#{api_url}/BuyPostageXML"
        rsp = RestClient.post(service_url, { recreditRequestXML: striped_xml_builder })
        parse_response(rsp)
      end

    end
  end
end