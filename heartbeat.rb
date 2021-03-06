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

    loop do

      if File.directory?(@directory)
        status = "UP"
      else
        status = "DOWN"
        send_notice
      end

      log_time status
      sleep(@interval)

    end

  end

  private

  def log_time(status)
    log_file = File.open( "server_status.log","w" )
    log_file << "Last Check: Server #{status} at #{Time.now.asctime}"
    log_file.close
  end

  def send_notice

    if Time.now > @last_notice + @notify_delay
      send_sms
      @last_notice = Time.now
    end

  end

  def send_sms

    recipients = ENV['RECIPIENTS'].split(",")

    recipients.each do |cell_number|
      @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']
      @client.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: cell_number,
        body: "Server drop detected at #{Time.now.asctime}"
      )
    end

  end

end

heart = HeartBeat.new
heart.start
