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

  def shorten(original_url)
  	puts "Shortening this URL: #{original_url}"
  	Bitly.use_api_version_3
  	bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
  	return bitly.shorten(original_url).short_url
  end

	def clean_message(message)
		message[0..139]
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
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end
end

blogger = MicroBlogger.new
blogger.run