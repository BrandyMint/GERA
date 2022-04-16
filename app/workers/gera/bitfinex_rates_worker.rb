# frozen_string_literal: true

module Gera
  # Import rates from Bitfinex
  #
  class BitfinexRatesWorker
    include Sidekiq::Worker
    include AutoLogger

    prepend RatesWorker

    # Stolen from: https://api.bitfinex.com/v1/symbols
    AVAILABLE_TICKETS = ["btcusd","ltcusd","ltcbtc","ethusd","ethbtc","etcbtc","etcusd","rrtusd","zecusd","zecbtc","xmrusd","xmrbtc","dshusd","dshbtc","btceur","btcjpy","xrpusd","xrpbtc","iotusd","iotbtc","ioteth","eosusd","eosbtc","eoseth","sanusd","omgusd","omgbtc","omgeth","neousd","neobtc","neoeth","etpusd","etpbtc","qtmusd","qtmbtc","edousd","btgusd","btgbtc","datusd","gntusd","sntusd","ioteur","batusd","mnausd","mnabtc","funusd","zrxusd","zrxbtc","zrxeth","trxusd","trxbtc","trxeth","repusd","repbtc","btcgbp","etheur","ethjpy","ethgbp","neoeur","neojpy","neogbp","eoseur","eosjpy","eosgbp","iotjpy","iotgbp","requsd","lrcusd","waxusd","daiusd","daibtc","daieth","bftusd","odeusd","antusd","antbtc","anteth","stjusd","xlmusd","xlmbtc","xlmeth","xvgusd","mkrusd","kncusd","kncbtc","lymusd","utkusd","veeusd","zcnusd","essusd","iqxusd","zilusd","zilbtc","bntusd","xrausd","vetusd","vetbtc","gotusd","xtzusd","xtzbtc","trxeur","mlnusd","omnusd","pnkusd","pnketh","dgbusd","bsvusd","bsvbtc","enjusd","rbtusd","rbtbtc","ustusd","euteur","eutusd","udcusd","tsdusd","paxusd","pasusd","vsyusd","vsybtc","bttusd","btcust","ethust","clousd","ltcust","eosust","gnousd","atousd","atobtc","atoeth","wbtusd","xchusd","eususd","leousd","leobtc","leoust","leoeos","leoeth","gtxusd","kanusd","gtxust","kanust","ampusd","algusd","algbtc","algust","btcxch","ampust","dusk:usd","dusk:btc","uosusd","uosbtc","ampbtc","fttusd","fttust","paxust","udcust","tsdust","btc:cnht","ust:cnht","cnh:cnht","chzusd","chzust","xaut:usd","xaut:btc","xaut:ust","btse:usd","testbtc:testusd","testbtc:testusdt","aaabbb","dogusd","dogbtc","dogust","dotusd","adausd","adabtc","adaust","fetusd","fetust","dotust","link:usd","link:ust","comp:usd","comp:ust","ksmusd","ksmust","egld:usd","egld:ust","uniusd","uniust","band:usd","band:ust","avax:usd","avax:ust","snxusd","snxust","yfiusd","yfiust","balusd","balust","filusd","filust","jstusd","jstbtc","jstust","iqxust","bchabc:usd","bchn:usd","xdcusd","xdcust","pluusd","sunusd","sunust","uopusd","uopust","eutust","xmrust","xrpust","b21x:usd","b21x:ust","sushi:usd","sushi:ust","xsnusd","dotbtc","eth2x:usd","eth2x:ust","eth2x:eth","aave:usd","aave:ust","xlmust","ctkusd","ctkust","solusd","solust","best:usd","albt:usd","albt:ust","celusd","celust","suku:usd","suku:ust","bmiusd","bmiust","mobusd","mobust","near:usd","near:ust","boson:usd","boson:ust","luna:usd","luna:ust","iceusd","doge:usd","doge:ust","oxyusd","oxyust","1inch:usd","1inch:ust","idxusd","forth:usd","forth:ust","idxust","chex:usd","qtfusd","qtfbtc","ocean:usd","ocean:ust","planets:usd","planets:ust","ftmusd","ftmust","nexo:usd","nexo:btc","nexo:ust","velo:usd","velo:ust","icpusd","icpbtc","icpust","fclusd","fclust","terraust:usd","terraust:ust","mirusd","mirust","grtusd","grtust","waves:usd","waves:ust","reef:usd","reef:ust","btceut","luna:btc","chsb:usd","chsb:btc","chsb:ust","xrdusd","xrdbtc","exousd","rose:usd","rose:ust","doge:btc","etcust","neoust","atoust","xtzust","batust","vetust","trxust","etheut","eurust","matic:usd","matic:btc","matic:ust","axsusd","axsust","hmtusd","hmtust","dora:usd","dora:ust","btc:xaut","eth:xaut","solbtc","avax:btc","jasmy:usd","jasmy:ust","ancusd","ancust","aixusd","aixust","shib:usd","shib:ust","mimusd","mimust","qrdo:usd","qrdo:ust","btcmim","mkrust","tlos:usd","tlos:ust","boba:usd","boba:ust","spell:usd","spell:ust","wncg:usd","wncg:ust","spell:mim","srmusd","srmust","crvusd","crvust","theta:usd","theta:ust","zmtusd","zmtust","wild:usd","wild:ust","dvfusd","pngusd","pngust","kaiusd","kaiust","woousd","wooust","trade:usd","trade:ust","sgbusd","sgbust","sxxusd","sxxust","ccdusd","ccdust","luna:eth","ccdbtc","gbpust","gbpeut","jpyust","bmnusd","bmnbtc","shft:usd","polc:usd","hixusd","shft:ust","polc:ust","hixust","gala:usd","gala:ust","apeusd","apeust","sidus:usd","sidus:ust","senate:usd","senate:ust","b2musd","b2must","btcf0:ustf0","ethf0:ustf0","xautf0:ustf0","btcdomf0:ustf0","testbtcf0:testusdtf0","ampf0:ustf0","eurf0:ustf0","gbpf0:ustf0","jpyf0:ustf0","europe50ixf0:ustf0","germany30ixf0:ustf0","eosf0:ustf0","ltcf0:ustf0","dotf0:ustf0","xagf0:ustf0","iotf0:ustf0","linkf0:ustf0","unif0:ustf0","ethf0:btcf0","adaf0:ustf0","xlmf0:ustf0","dotf0:btcf0","ltcf0:btcf0","xautf0:btcf0","dogef0:ustf0","solf0:ustf0","sushif0:ustf0","lunaf0:ustf0","filf0:ustf0","avaxf0:ustf0","lunaf0:btcf0","xrpf0:ustf0","xmrf0:ustf0","xrpf0:btcf0","algf0:ustf0","germany40ixf0:ustf0","aavef0:ustf0","maticf0:ustf0","ftmf0:ustf0","egldf0:ustf0","axsf0:ustf0","compf0:ustf0","xtzf0:ustf0","trxf0:ustf0","solf0:btcf0","avaxf0:btcf0","atof0:ustf0","shibf0:ustf0","omgf0:ustf0","btcf0:eutf0","ethf0:eutf0","neof0:ustf0","zecf0:ustf0","crvf0:ustf0","nearf0:ustf0","icpf0:ustf0","galaf0:ustf0","apef0:ustf0"].freeze


    # NOTE: formar tickers neousd neobtc neoeth neoeur
    FORCED_TICKERS = %i[btcusd].freeze

    private

    def rate_source
      @rate_source ||= RateSourceBitfinex.get!
    end

    # {"mid":"8228.25",
    # "bid":"8228.2",
    # "ask":"8228.3",
    # "last_price":"8228.3",
    # "low":"8055.0",
    # "high":"8313.3",
    # "volume":"13611.826947359996",
    # "timestamp":"1532874580.9087598"}
    def save_rate(ticker, data)
      currency_pair = pair_from_ticker ticker
      logger.info "save_rate #{ticker} #{data}"
      create_external_rates currency_pair, data, sell_price: data['high'], buy_price: data['low']
    end

    def pair_from_ticker(ticker)
      ticker = ticker.to_s
      CurrencyPair.new ticker[0, 3], ticker[3, 3]
    end

    def load_rates
      logger.info "load_rates #{tickers_to_load.join(',')}"
      tickers_to_load.each_with_object({}) { |ticker, ag| ag[ticker] = BitfinexFetcher.new(ticker: ticker).perform }
    end

    def tickers_to_load
      (FORCED_TICKERS + currencies_tickers).uniq
    end

    def currencies_tickers
      buffer = []
      Currency.alive.find_each do |c1|
        Currency.alive.find_each do |c2|
          ticker = c1.bitfinex_ticker + c2.bitfinex_ticker
          buffer << ticker if AVAILABLE_TICKETS.include? ticker
          ticker = c2.bitfinex_ticker + c1.bitfinex_ticker
          buffer << ticker if AVAILABLE_TICKETS.include? ticker
        end
      end
      buffer
    end
  end
end
