#!/usr/bin/env ruby

require "google_drive"
GoogleSpreadsheet = GoogleDrive

client = Google::APIClient.new
auth = client.authorization
auth.client_id = ENV["POOO_CLIENT_ID"]
auth.client_secret = ENV["POOO_CLIENT_SECRET"]
auth.scope =
    "https://www.googleapis.com/auth/drive " +
    "https://spreadsheets.google.com/feeds/"
auth.redirect_uri = "https://www.example.com/oauth2callback"
print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
print("2. Enter the authorization code shown in the page: ")
auth.code = $stdin.gets.chomp
auth.fetch_access_token!
access_token = auth.access_token

session = GoogleDrive.login_with_oauth(access_token)
spreadsheet = session.spreadsheet_by_key("17RtvMArCg87byGXuENlx1mWAJyPx0X6SPDlT1YdxEfU")

ws = spreadsheet.worksheets[0]
ws_counts = spreadsheet.worksheets[1]

peers = []
score = 1

for row in 2 .. ws.num_rows
  peers << {id: row - 1, name: ws[row, 1]}
end

while (score > 0) do
  score = 0
  shuffled_peers = peers.shuffle

  puts 'Peers'
  shuffled_peers.each_slice(2) do |pair|
    if pair[1]
      puts "#{pair[0][:name]} with #{pair[1][:name]}"
      score += ws_counts[pair[0][:id] + 1, pair[1][:id] + 1].to_i
    else
      puts "#{pair[0][:name]} sits this one out"
      score += ws_counts[pair[0][:id] + 1, peers.count + 2].to_i
    end
  end
  puts ''
end

puts "Number of repeats: #{score}"
