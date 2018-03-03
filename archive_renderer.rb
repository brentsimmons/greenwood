require_relative './model/blog_year'

class ArchiveRenderer

	def initialize(blog_years)
		@sorted_blog_years = blog_years.sort { |left, right| left.year <=> right.year }.reverse
	end

	def rendered_archive
		html = ""
		@sorted_blog_years.each { |blog_year| html += rendered_year(blog_year) }
		html
	end

	private

	def rendered_year(blog_year)
		html = "<h2>#{blog_year.year}</h2>\n"
		blog_year.months.sort.reverse.each { |month| html += rendered_month(blog_year.year, month) }
		html
	end

	def rendered_month(year, month)	
		month_name = Date::MONTHNAMES[month]
		"<a href=\"/archive/#{year}/#{month}/\">#{month_name}</a><br />\n"
	end
end
