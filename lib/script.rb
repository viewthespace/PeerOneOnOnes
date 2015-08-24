#!/usr/bin/env ruby

# require "google_drive"
# require "postmark"

# GoogleSpreadsheet = GoogleDrive

# client = Google::APIClient.new
# auth = client.authorization
# auth.client_id = ENV["POOO_CLIENT_ID"]
# auth.client_secret = ENV["POOO_CLIENT_SECRET"]
# auth.scope =
#     "https://www.googleapis.com/auth/drive " +
#     "https://spreadsheets.google.com/feeds/"
# auth.redirect_uri = "https://www.example.com/oauth2callback"
# print("1. Open this page:\n%s\n\n" % auth.authorization_uri)
# print("2. Enter the authorization code shown in the page: ")
# auth.code = $stdin.gets.chomp
# auth.fetch_access_token!
# access_token = auth.access_token
# @postmark_client = Postmark::ApiClient.new(ENV["POSTMARK_API_TOKEN"])

# session = GoogleDrive.login_with_oauth(access_token)
# spreadsheet = session.spreadsheet_by_key("17RtvMArCg87byGXuENlx1mWAJyPx0X6SPDlT1YdxEfU")

# @ws = spreadsheet.worksheets[0]
# @ws_counts = spreadsheet.worksheets[1]

# @score = 1

# def grab_peer? row
#   @ws[row, 2].downcase.start_with? 'y'
# end

# def read_peers
#   peers = []
#   for row in 2 .. @ws.num_rows
#     peers << {id: row - 1, name: @ws[row, 1], email: @ws[row, 3]}  if grab_peer? row
#   end
#   peers
# end

# def find_pairs peers
#   while (@score > 0) do
#     @score = 0
#     pairs = []
#     shuffled_peers = peers.shuffle

#     shuffled_peers.each_slice(2) do |pair|
#       pairs << pair
#       if pair.length > 1
#         @score += @ws_counts[pair[0][:id] + 1, pair[1][:id] + 1].to_i
#       else
#         @score += @ws_counts[pair[0][:id] + 1, peers.count + 2].to_i
#       end
#     end
#   end
#   pairs
# end

# def write_peers pairs
#   puts 'Peers'
#   pairs.each do |pair|
#     if pair.length == 2
#       # Write to Google Drive
#       times_paired = @ws_counts[pair[0][:id] + 1, pair[1][:id] + 1].to_i

#       @ws_counts[pair[0][:id] + 1, pair[1][:id] + 1] = times_paired + 1
#       @ws_counts[pair[1][:id] + 1, pair[0][:id] + 1] = times_paired + 1

#       # Write to console
#       puts "#{pair[0][:name]} with #{pair[1][:name]}"
#       if pair.length == 1
#         puts "#{pair[0][:name]} sits this one out"
#       end
#     end
#   end
#   puts ''
#   puts "Number of repeats: #{@score}"
#   @ws_counts.save
# end

#meetings will always be sorted by id order?
#assume system has at least two users
#what to do when user is added
#what to do when user is removed
#maybe come up with a way that doesn't use the same combination again

@number_of_searches = 0

puts "searching"

def find_pairs
  @number_of_searches += 1
  # puts "searching for pairs... #{@number_of_searches += 1}"
  user_ids = User.all.map(&:id)

  number_of_combinations = user_ids.combination(2).to_a.size

  # puts "#{number_of_combinations} COMBINATIONS"

  meeting_user_ids = Meeting.where('archived_at is null').map{|m| [m.primary_user_id, m.secondary_user_id].sort}.sort.uniq

  # puts "#{meeting_user_ids.size} meetings"

  paired_user_ids = user_ids.shuffle.each_slice(2).to_a.map(&:sort).sort
  paired_user_ids_with_complete_pairs = paired_user_ids.select{ |p| p.size == 2}

  # puts "meeting user ids: #{meeting_user_ids}"
  # puts "paired_user_ids_with_complete_pairs: #{paired_user_ids_with_complete_pairs}"


  if (meeting_user_ids & paired_user_ids_with_complete_pairs).present?
    # puts (meeting_user_ids & paired_user_ids_with_complete_pairs).to_s

    if meeting_user_ids.size == number_of_combinations || (number_of_combinations - meeting_user_ids.size) <= paired_user_ids_with_complete_pairs.size
      puts "all #{number_of_combinations} combinations have been exhausted, ARCHIVING ALL MEETINGS"
      meeting_user_ids.each do |pair|
        Meeting.where(primary_user_id: pair[0], secondary_user_id: pair[1]).each(&:archive)
        Meeting.where(primary_user_id: pair[1], secondary_user_id: pair[0]).each(&:archive)
      end
    end
    find_pairs
  else
    paired_user_ids.each do |pair|
      if pair.size == 2
        # puts "creating a meeting for #{pair[0]} and #{pair[1]}"
        Meeting.create(primary_user_id: pair[0], secondary_user_id: pair[1])
      else
        # email person saying no pair this week
      end
    end
    puts "tried #{@number_of_searches} combinations"
    puts "#{number_of_combinations} COMBINATIONS"
    new_meetings = Meeting.where('archived_at is null').map{|m| [m.primary_user_id, m.secondary_user_id].sort}.sort.uniq
    puts "#{new_meetings.size} new meetings exist now"
  end
end


find_pairs


# paired_user_ids.each do |pair|
#   raise "Meetings "

# end



#account for odd numbers of users


# def email_peers pairs
#   puts 'Sending Emails...'
#   pairs.each do |pair|
#     if pair.length == 2
#       @postmark_client.deliver(
#         from: 'dan.ubilla@vts.com',
#         to: [pair[0][:email], pair[1][:email]],
#         subject: 'Random Peer 1:1s',
#         html_body: 'Hi there,

#   This message is to inform you that the both of you have been randomly paired for Peer 1:1s this week. Try and find a time that works for the both of you.

#   Thanks!',
#         track_opens: true
#       )
#     end
#   end
# end

# # peers = read_peers
# # pairs = find_pairs peers
# write_peers pairs
# email_peers pairs
