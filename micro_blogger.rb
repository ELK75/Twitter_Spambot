require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "initializing..."
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		message = clean_message(message)
		@client.update(message)
	end

	def dm(target, message)
		puts "Cruising through the dms like #{target}:"
		screen_names = @client.followers.collect do |follower| 
			@client.user(follower).screen_name
		end
		puts message
		message = "d @#{target} #{message}"
		if screen_names.include?(target)
			tweet(message)
		else puts "Sorry, you do not follow #{target}"
		end
	end

	def follower_list
		screen_names = []
		@client.followers.each do |follower|
			screen_names << @client.user(follower).screen_name
		end
		screen_names
	end

	def spam_my_followers(message)
		spam_list = follower_list
		spam_list.each {|follower| dm(follower, message)}
	end

	def everyones_last_tweet
  	screen_names = follower_list
    # put names in alphabetical order
    screen_names.sort_by! { |friend| friend.downcase}
    screen_names.each do |friend|
      status = @client.user(friend).status
      timestamp = friend.status.created_at
      timestamp.strftime("%A, %b, %d")
      puts "#{friend} said this on #{timestamp}"
      puts status.text
        #     # print each friend's screen_name
        #     # print each friend's last message
      sleep(10)
    end
  end

  def clean_up_definition(definition)
  	# gets rid of the denotion of whether or
  	# not it's a noun/verb/adj/etc...
  	definition.sub!(/[a-z]+\.\s/, '')
  end

  def tweet_word_and_definition(dictionary)
  	while true
  		phrases = %w(Wow! Cool! Neat! Rad! Groovy!)
  		random_word = dictionary.keys.sample
  		random_defintion = clean_up_definition(dictionary[random_word])
  		random_phrase = phrases.sample
  		word_of_day_tweet = "#{random_word} means #{random_defintion}\n#{random_phrase}"
  		tweet(word_of_day_tweet)
  		sleep(3600)
  	end
  end

  def print_word_of_the_day
    dictionary = Hash.new('')
  	File.open("dictionary.txt").readlines.each do |line|
  		word_and_def = line.split('  ')
  		next if word_and_def.length != 2
  		dictionary[word_and_def[0]] = word_and_def[1]
  	end
  	tweet_word_and_definition(dictionary)
  end

  def shorten(original_url)
  	puts "Shortening this URL: #{original_url}"
  	Bitly.use_api_version_3
  	bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
  	return bitly.shorten(original_url).short_url
  end

	def clean_message(message)
		message[0..139] unless message.nil?
	end

	def run
		puts "Welcome to the JSL Twitter Client"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet(parts[1..-1].join(" "))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				when 's' then shorten(parts[1])
				when 'turl' then tweet(parts[1..-2].join(" ") + 
					" " + shorten(parts[-1]))
				when 'wod' then print_word_of_the_day
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end
end

blogger = MicroBlogger.new
blogger.run