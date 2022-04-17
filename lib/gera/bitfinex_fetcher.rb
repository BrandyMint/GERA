require 'rest-client'

module Gera
  class BitfinexFetcher
    API_TICKER_URL = 'https://api.bitfinex.com/v1/pubticker/'
    API_TICKERS_URL = 'https://api.bitfinex.com/v1/symbols'

    def fetch_tickers
      parse_response RestClient::Request.execute url: API_TICKERS_URL, method: :get, verify_ssl: false
    end

    def fetch_ticker(ticker)
      parse_response RestClient::Request.execute url: API_TICKER_URL + ticker, method: :get, verify_ssl: false
    end

    private

    def parse_response(response)
      raise response.code unless response.code == 200
      JSON.parse response.body
    end
  end
end
