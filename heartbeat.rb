require 'twilio-ruby'
require 'dotenv'

Dotenv.load

class HeartBeat

  def initialize
    @directory = ENV['DIRECTORY']
    @interval = ENV['INTERVAL'].to_i
    @notify_delay = ENV['DELAY'].to_i

    @last_notice = Time.now - @notify_delay
  end

  def start
    while true

      puts 'tick'

      if File.directory?(@directory)
        puts "server ok"
      else
        send_notice
      end

      sleep(@interval)

    end

  end

  private

  def send_notice

    if Time.now > @last_notice + @notify_delay
      send_sms
      @last_notice = Time.now
      puts @last_notice
    end

  end

  def send_sms

    @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']
    @client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: ENV['CELL_NUMBERS'],
      body: "Server drop detected at #{Time.now}"
    )
  end

end

heart = HeartBeat.new
heart.start
