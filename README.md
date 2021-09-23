# README

This was my first experience writing a REST API in Ruby on Rails. Please excuse naming that doesn't follow language specific conventions that I am not used to.
Much of the time was spent researching how to properly set things up. I had to do some tinkering around in development.rb to turn on caching in the development environment.
My thought process was documented on comments.

Due to the small scope of this challenge, I decided to put all the logic into locations_controller.rb. I am not the most familiar with
Ruby programming, but I would assume that in a much larger project the logic would be better organized elsewhere. 
Usually I would split the logic between multiple helper functions to facillitate better modular programming, but this project only has two methods 
that don't share too much logic.

I believe that before any coding is even started, it is imperative that there is full understanding over all external calls that will be made. So I first started off
by testing as much different input as I could to the Geo Resolution API that I was tasked to work with. 
(curl --location --request GET 'https://get.geojs.io/v1/ip/geo.json?ip=[YOUR_IP_HERE]')

I discovered that the API doesn't properly send back HTTP status codes. It always returns 200 OK no matter how real or fake the IP Address supplied is. This could lead to some complications that need to be addressed with proper error handling if this project was on a more serious larger scale without the time constraint. Also sometimes a completely
valid IP Address had the chance of not returning back all the expected fields in the response. 

I mention in the comments where I would make improvements/additions if I was given the time. Thank you for your time and for the opportunity to test myself.

3rd party requirements to run

HTTParty
- gem install httparty
- Then add "gem 'httparty'" to Gemfile


Then to run:

- rails s
- Then hit the following CURL commands:

First endpoint that allows users to submit IP addresses. Fetches the country/city from GeoJS and stores them in server memory cache

```
curl --location --request POST 'localhost:3000/locations/submit' \
--header 'ip: [YOUR_IP_HERE]'
```

Second endpoint allows users to see all IP addresses tracked, and the data associated with it. The user is able to filter all IP addresses by country/city.

```
curl --location --request GET 'localhost:3000/locations/data' \
--header 'city: [YOUR_CITY_HERE]' \
--header 'country: [YOUR_COUNTRY_HERE]'
```