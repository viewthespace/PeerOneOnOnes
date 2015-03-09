#!/usr/bin/env ruby

require "google_drive"
require "postmark"

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
@postmark_client = Postmark::ApiClient.new(ENV["POSTMARK_API_TOKEN"])

session = GoogleDrive.login_with_oauth(access_token)
spreadsheet = session.spreadsheet_by_key("17RtvMArCg87byGXuENlx1mWAJyPx0X6SPDlT1YdxEfU")

@ws = spreadsheet.worksheets[0]
@ws_counts = spreadsheet.worksheets[1]

@score = 1

def grab_peer? row
  @ws[row, 2].downcase.start_with? 'y'
end

def read_peers
  peers = []
  for row in 2 .. @ws.num_rows
    peers << {id: row - 1, name: @ws[row, 1], email: @ws[row, 2]}  if grab_peer? row
  end
  peers
end

def find_pairs peers
  while (@score > 0) do
    @score = 0
    pairs = []
    shuffled_peers = peers.shuffle

    shuffled_peers.each_slice(2) do |pair|
      pairs << pair
      if pair.length > 1
        @score += @ws_counts[pair[0][:id] + 1, pair[1][:id] + 1].to_i
      else
        @score += @ws_counts[pair[0][:id] + 1, peers.count + 2].to_i
      end
    end
  end
  pairs
end

def write_peers pairs
  puts 'Peers'
  pairs.each do |pair|

    # Write to Google Drive
    times_paired = @ws_counts[pair[0][:id] + 1, pair[1][:id] + 1].to_i

    @ws_counts[pair[0][:id] + 1, pair[1][:id] + 1] = times_paired + 1
    @ws_counts[pair[1][:id] + 1, pair[0][:id] + 1] = times_paired + 1

    # Write to console
    puts "#{pair[0][:name]} with #{pair[1][:name]}"
    if pair.length == 1
      puts "#{pair[0][:name]} sits this one out"
    end
  end
  puts ''
  puts "Number of repeats: #{@score}"
  @ws_counts.save
end

def email_peers pairs
  puts 'Sending Emails...'
  pairs.each do |pair|
    @postmark_client.deliver(
      from: 'dan.ubilla@vts.com',
      to: [pair[0][:email], pair[1][:email]],
      subject: 'Random Peer 1:1s',
      html_body: 'Hi there,

This message is to inform you that the both of you have been randomly paired for Peer 1:1s this week. Try and find a time that works for the both of you.

Thanks!',
      track_opens: true
    )
  end
end

peers = read_peers
pairs = find_pairs peers
write_peers pairs
email_peers pairs
