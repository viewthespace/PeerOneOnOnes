#!/usr/bin/env ruby

peers = [
  'Dan Ubilla',
  'Alex Trebek',
  'Jimmy Fallon',
  'Tom Cruise',
  'Ben Stiller',
  'Sean Connery',
  'Darrell Hammond',
  'Adam Sandler'
].shuffle

puts 'Peers'
peers.each_slice(2) do |b|
  puts "#{b[0]} with #{b[1]}"
end
