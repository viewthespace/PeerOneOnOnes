#!/usr/bin/env ruby

require "google_drive"
GoogleSpreadsheet = GoogleDrive

client = Google::APIClient.new
auth = client.authorization
auth.client_id = ENV["CLIENT_ID"]
auth.client_secret = ENV["CLIENT_SECRET"]
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

ws = session.spreadsheet_by_key("17RtvMArCg87byGXuENlx1mWAJyPx0X6SPDlT1YdxEfU").worksheets[0]

peers = []

for row in 2 .. ws.num_rows
  peers << ws[row, 1]
end

peers.shuffle!

puts 'Peers'
peers.each_slice(2) do |b|
  puts "#{b[0]} with #{b[1]}"
end
