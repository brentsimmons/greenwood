require 'sinatra'
require 'rdiscount'
require_relative './model/post'
require_relative './model/blog'
require_relative './archive_renderer'

settings.threaded = false

$blog_folder = Dir.getwd + "/blog/"
$blog = Blog.new($blog_folder)
$rendered_page_cache = {}
$archive_renderer = ArchiveRenderer.new($blog.blog_years)
$rendered_post_cache_with_permalinks = {}
$rendered_post_cache_without_permalinks = {}

$POSTS_PER_PAGE = 100

# Routes:
# / - home page - list of most recent posts
# /post/:postid - individual post
# /archive/ - list of years and months
# /archive/:year/:month/ - all posts in that month

get '/' do
	render_page("/") do
		title = "Latest"
		posts = $blog.recent_posts($POSTS_PER_PAGE)
		posts_as_html = rendered_posts(posts, true)
		locals = {title: title, body_text: posts_as_html}
		erb :index, :locals => locals
	end
end

get '/new' do
	new_post_page
end

post '/new' do
	post_text = params['post_text']
	$blog.save_new_post(post_text)
	empty_caches
	new_post_page
end

get '/post/:post_id/delete' do
	post_id = params['post_id']
	post = $blog.post_with(post_id)
	pass if post.nil?

end

get '/post/:post_id/edit' do
	post_id = params['post_id']
	post = $blog.post_with(post_id)
	pass if post.nil?

	title = date_string(post)
	post_as_html = rendered_post(post, false)
	locals = {title: title, current_rendered_post: post_as_html, post_text: post.body, post_id: post.post_id}
	erb :edit_post, :locals => locals
end

get '/post/:post_id' do
	post_id = params['post_id']
	post = $blog.post_with(post_id)
	pass if post.nil?

	render_page(post_id) do
		title = date_string(post)
		post_as_html = rendered_post(post, false)
		locals = {title: title, body_text: post_as_html}
		erb :index, :locals => locals
	end
end

get '/archive/' do
	render_page("archive") do
		title = "Archive"
		archive_as_html = $archive_renderer.rendered_archive
		locals = {title: title, body_text: archive_as_html}
		erb :archive, :locals => locals
	end	
end

get '/archive' do
	redirect to('/archive/')
end

get '/archive/:year/:month/' do
	year_string = params['year']
	year = year_string.to_i
	month_string = params['month']
	month = month_string.to_i
	
	cache_key = "archive/#{year_string}/#{month_string}/"
	s = $rendered_page_cache[cache_key]
	return s unless s.nil?
	
	posts = $blog.posts_in_year_and_month(year, month)
	pass if posts.nil? || posts.count < 1
	
	render_page(cache_key) do
		month_name = Date::MONTHNAMES[month]
		title = "#{month_name} #{year_string}"
		posts_as_html = rendered_posts(posts, true)
		locals = {title: title, body_text: posts_as_html, year: year_string, month: month_name}
		erb :archive_month, :locals => locals
	end
end

def new_post_page
	title = "New Post"
	posts = $blog.recent_posts($POSTS_PER_PAGE)
	posts_as_html = rendered_posts(posts, true)
	locals = {title: title, recent_posts: posts_as_html}
	erb :new_post, :locals => locals
end

def render_page(cache_key)
	s = $rendered_page_cache[cache_key]
	if s.nil?
		s = yield
		$rendered_page_cache[cache_key] = s
	end
	s
end

def empty_caches
	$rendered_page_cache = {}
	$archive_renderer = ArchiveRenderer.new($blog.blog_years)
	$rendered_post_cache_with_permalinks = {}
	$rendered_post_cache_without_permalinks = {}
end

# Post Renderer

def date_string(post)
	date_posted = Time.at(post.date_time_posted)
	date_posted.strftime("%d %b %Y - %I:%M %p")
end

def date_link(post)
	"<a href=/post/#{post.post_id}>#{date_string(post)}</a>"
end

def html_body(post)
	RDiscount.new(post.body).to_html
end

def rendered_posts(posts, with_permalink)
	html = ""
	posts.each { |post| html += rendered_post(post, with_permalink) }
	html
end

def rendered_post(post, with_permalink)
	cache = with_permalink ? $rendered_post_cache_with_permalinks : $rendered_post_cache_without_permalinks
	html = cache[post.post_id]
	if html.nil?
		locals = {date: with_permalink ? date_link(post) : date_string(post), html_body: html_body(post)}
		html = erb :post, :locals => locals
		cache[post.post_id] = html
	end
	html
end
