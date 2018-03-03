# Greenwood

DO NOT DEPLOY THIS APP AS-IS. IT IS *NOT* SECURE.

Greenwood is a small microblogging system, written in Ruby, that runs as a [Sinatra](http://sinatrarb.com/) app.

Before you can run it, you’ll need to have installed the `sinatra` and `rdiscount` gems. (The latter is for Markdown processing.)

Then, to run it, navigate to the app in Terminal, and type `ruby app.rb`. Then open the site in your browser using the port Sinatra reports. On my machine that’s `http://localhost:4567/`.

## This code may never get finished

I don’t plan to finish this project. I decided to go a different route.

But I’ve posted it anyway, since maybe somebody else can use it as a starting place.

## Things it does

Renders a home page, individual posts, and an archive. You can add a new item by going to `/new` in your browser.

## Things it doesn’t do

It never asks for any credentials! It’s wide open! Don’t put this on a server!

It doesn’t support standard blogging APIs. It should, so it could be used by [MarsEdit](https://red-sweater.com/marsedit/), [Micro.blog](https://micro.blog/), and other apps.

It doesn’t separate code from data and templates. Right now they’re all smooshed-together in the same repo.

## On using this code

It’s available via the Unlicense, which means you can do whatever. I’d recommend choosing a different name, just so there’s no confusion, of course.

## Note about the code

I’m an Objective-C and Swift developer writing Ruby code. I made some effort to create idiomatic Ruby code, but it probably shows that I’m not an experienced Rubyist.

## PS

[Greenwood](https://en.wikipedia.org/wiki/Greenwood,_Seattle) is the name of a neighborhood in Seattle next to where I live (Ballard).