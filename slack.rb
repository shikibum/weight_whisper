# frozen_string_literal: true

require 'net/https'
require 'uri'
require 'json'
require 'date'
require 'dotenv/load'
require 'slack'

# withings API
#
# refresh_tokenからaccess_tokenを取得
def get_access_token
  uri = URI.parse("https://account.withings.com/oauth2/token")
  request = Net::HTTP::Post.new(uri)
  request.set_form_data(
    "client_id" => ENV['CLIENT_ID'],
    "client_secret" => ENV['CLIENT_SECRET'],
    "grant_type" => "refresh_token",
    "refresh_token" => ENV['REFRESH_TOKEN'],
    )

  req_options = {
    use_ssl: uri.scheme == "https",
  }

  response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
    http.request(request)
  end

  result = JSON.parse(response.body)
  access_token = result["access_token"]

  puts 'Get access token'
end

# データ取得
def get_weight_date
    uri = URI.parse("https://wbsapi.withings.net/measure?action=getmeas&meastype=1&category=1&startdate=#{Date.today.prev_day(7).to_time.to_i}&enddate=#{Date.today.to_time.to_i}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

  result = JSON.parse(response.body)
  result["body"]["measuregrps"].each {|hoge| hoge["measures"][0]["value"] }
end

#条件分岐

# Slack投稿
Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

p Slack.chat_postMessage(channel: "#shikibu_weight", text: "test")
# => {"ok"=>true, "channel"=>"CKZ3F723H", "ts"=>"1561623158.000100", "message"=>{"type"=>"message", "subtype"=>"bot_message", "text"=>"test", "ts"=>"1561623158.000100", "username"=>"weight_whisper", "bot_id"=>"BKRHLAYLR"}}
