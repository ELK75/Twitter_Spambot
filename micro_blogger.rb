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

  def syllable_count(sentance)
    sentance.scan(/[aiouy]+e*|e(?!d$|ly).|[td]ed|le$/).size
  end

  def make_line(lines, syllables)
    for index in 1...lines.size
      syllables_in_line = syllable_count(lines[0..index].join(" "))
      if syllables_in_line > syllables
        return false
      elsif syllables_in_line == syllables
        haiku_line = lines[0..index]
        lines.slice!(0, index+1)
        return haiku_line
      end
    end
  end

  def make_haiku(sentance)
    return false if syllable_count(sentance) != 17
    lines = sentance.split
    begin
      line_one =  make_line(lines, 5).join(" ")
      line_two =  make_line(lines, 7).join(" ")
      line_three = make_line(lines, 5).join(" ")
      return "#{line_one}\n#{line_two}\n#{line_three}"
    rescue NoMethodError
      return false
    end
  end

  def print_haiku
    texts = ["The Catcher in the Rye",
             "Fahrenheit 451", "To Kill a Mockingbird"]
    chosen_text = texts[rand(0...texts.size)]
    file = File.open("#{chosen_text}.txt")
    contents = file.read.gsub!("\n", ' ')
    sentances = contents.split(/(?:\.|\?|\!)(?= [^a-z]|$)/)
    number_of_sentances = sentances.length
    random_sentance = ""
    while !make_haiku(random_sentance)
      random_sentance = sentances[rand(0...number_of_sentances)]
      random_sentance.gsub!(/\"/, '')
      random_sentance.downcase!
    end
    haiku = "#{make_haiku(random_sentance)}\n\n"\
            "Haiku from the book #{chosen_text}"
    puts haiku
    tweet(haiku)
    sleep(3600)
    print_haiku
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
        when 'haiku' then print_haiku
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end
end

blogger = MicroBlogger.new
blogger.run