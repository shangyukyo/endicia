module Endicia
  class Credentials
    attr_reader :requester_id, :account_id, :tmp_pass_phrase, :pass_phrase, :mode

    def initialize(options = {})
      @requester_id    = options[:requester_id]
      @account_id      = options[:account_id]
      @tmp_pass_phrase = options[:tmp_pass_phrase]
      @pass_phrase     = options[:pass_phrase]
      @mode            = options[:mode]
    end

  end
end

