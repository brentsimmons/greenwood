require 'find'
require 'date'
require_relative 'post'
require_relative 'blog_year'

# Posts are stored as individual files on disk instead of in a database.
#
# The advantage is that, for humans, it’s nice to have files on disk.
# You can put them in a repository, easily back them up,
# or move the data into other systems. Another advantage is a relaxed schema:
# posts can contain any metadata you want.
#
# The disadvantage is performance.
# To compensate, the Blog class reads all the posts into memory,
# which means that it’s relatively slow to initialize. After that it’s fast.

class Blog

	MARKDOWN_SUFFIX = ".markdown"

	def initialize(folder)
		@posts_folder = folder + "posts/"
		@pages_folder = folder + "pages/"
		read_posts_from_disk
	end

	def note_posts_did_change
		read_posts_from_disk
	end
	
	def save_new_post(post_text)
		date_time_posted = Time.now.to_f
		file_text = Post.file_text_for_new_post(post_text, date_time_posted)
		post_id = Post.post_id_with_date_time(date_time_posted)
		pub_date = Time.at(date_time_posted)
		path = "#{@posts_folder}/#{pub_date.year}/#{pub_date.month}/#{post_id}.#{MARKDOWN_SUFFIX}"
		Blog.write_file_to_disk(file_text, path)
		note_posts_did_change
	end
	
	def post_with(post_id)
		cached_post(post_id)
	end

	def posts_starting_with(post_id, max_posts)
		return nil unless max_posts > 0

		post = post_with(post_id)
		return nil if post.nil?

		index_of_post = @posts.index(post)
		return nil if index_of_post.nil? # Shouldn’t happen.

		@posts[index_of_post, max_posts]
	end

	def recent_posts(max_posts)
		# Posts for the home page.
		return nil unless max_posts > 0 && @posts.length > 0
		@posts[0, max_posts]
	end

	def posts_in_year_and_month(year, month)
		@posts.select do |post|
			pub_date = Time.at(post.date_time_posted)
			pub_date.month == month && pub_date.year == year
		end
	end
	
	def blog_years
		# Return BlogYear objects, unordered.
		blog_years = {}
		
		@posts.each do |post|
			pub_date = Time.at(post.date_time_posted)
			blog_year = blog_years[pub_date.year]
			if blog_year.nil?
				blog_year = BlogYear.new(pub_date.year)
				blog_years[pub_date.year] = blog_year
			end
			blog_year.add_month(pub_date.month)
		end
	
		blog_years.values
	end
	
	private

	def read_posts_from_disk
		@post_cache = {} # Caches by post_id.
		paths = all_file_paths(@posts_folder)
		unsorted_posts = paths.map { |f| post_with_path(f) }
		@posts = unsorted_posts.sort_by(&:date_time_posted).reverse
	end
	
	def post_with_path(f)
		post = Post.new(f)
		cache_post(post)
		post
	end

	def cache_post(post)
		return if post.nil?
		@post_cache[post.post_id] = post
	end

	def cached_post(post_id)
		@post_cache[post_id]
	end

	def all_file_paths(folder)
		paths = []
		Find.find(folder) { |f| paths.push(f) unless f.nil? }
		paths.reject! { |f| File.directory?(f) || !f.end_with?(MARKDOWN_SUFFIX) }
		paths
	end
	
	def self.write_file_to_disk(file_text, path)
    FileUtils.mkdir_p(File.dirname(path))
    new_file = File.open(path, 'w')
    new_file.puts(file_text)
    new_file.close()
  end

end

