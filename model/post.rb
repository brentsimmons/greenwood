# A post contains:
#	Attributes are lines at the top that start with @.
#
#	The one required attribute is date_time_posted, as in:
#	@date_time_posted 1480104816.829768
#	That time stamp is the same thing you get with Time.now.getutc.to_f.
#	The post_id is the time stamp converted to a string, with . replaced
#	by _, as in "1480104816_829768"
#
#	All text after the attributes at the top is the body of the post.
#
#	Because the post is passed to the renderer (post.erb), you can create whatever
#	attributes you want and refer to them. Posts could have a title, for instance.
#
#	Example:
#	@date_time_posted 1480104816.829768
#	This is *a post*, written in [Markdown](https://daringfireball.net/projects/markdown/syntax).


class Post

	DATE_TIME_POSTED_KEY = "date_time_posted"

	attr_reader :attributes
	attr_reader :body
	attr_reader :path
	attr_reader :date_time_posted # float like 1480104816.829768. Must be unique.
	attr_reader :post_id # date_time_posted as string, with . replaced with _. Example: "1480104816_829768"

	def initialize(path)

		@path = path
		@body = ""
		@attributes = {}

		file = File.new(path)

		pullingAttributes = true
		file.each_line do |line|
			if pullingAttributes
				one_key, one_value = key_value_with_line(line)
			end

			if one_key.nil?
				pullingAttributes = false
			else
				attributes[one_key] = one_value
			end

			@body += line unless pullingAttributes
		end
		
		@date_time_posted = attributes[DATE_TIME_POSTED_KEY]
		@post_id = Post.post_id_with_date_time(@date_time_posted)

		file.close
	end

	def self.attributes_for_new_post(date_time)
		# date_time must be a float, as in 1486270904.965188.
		attributes = {}
		attributes[DATE_TIME_POSTED_KEY] = date_time
		attributes
	end
	
	def self.text_with_attributes(attributes)
		s = ""
		attributes.each_pair do |key, value|
			s += "@#{key} "
			if value.is_a?(String)
				s += "\"#{value}\"\n"
			elsif value.respond_to?(:to_s)
				s += "#{value.to_s}\n"
			end
		end
		s
	end
	
	def self.post_id_with_date_time(date_time)
		date_time.to_s.gsub('.', '_')
	end
	
	def self.file_text_for_new_post(body, date_time_posted)
		attributes = attributes_for_new_post(date_time_posted)
		file_text = text_with_attributes(attributes)
		file_text += body
	end
	
	private

	def key_value_with_line(line)
		if line[0,1] != "@" then return nil, nil end

		index_of_space = line.index(" ")
		if index_of_space == nil then return nil, nil end

		key = line[1, index_of_space - 1]
		value = line[index_of_space + 1, line.length - (index_of_space + 1)]
		value.strip!

		if key == DATE_TIME_POSTED_KEY then return key, value.to_f end

		if /\D/.match(value) == nil #it's an integer
			value = value.to_i
		end

		if value == "(empty-string)" then value = "" end

		if /Date$/.match(key) != nil then value = Time.parse(value) end
		
		# Special case to support inessential.com post format. For testing.
		if key == "pubDate"
			key = DATE_TIME_POSTED_KEY
			value = value.to_f
		end

		if /Array$/.match(key) != nil
			value = value.split(", ")
			value.map!(&:strip)
		end

		return key, value
	end

end
