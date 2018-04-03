# README

So this is an example of an application that adheres to GDPR regulations (aka EU wide fundamental changes to how personally identifiable information is stored).
A lot of people seem to consider it really hard whereas in practice it's really not that bad and hopefully this small project helps you solve some problems.  

Points covered:

* Per row encryption for personally identifiable information (also helps with right to be forgotten, it's just a matter of removing your encryption_key for a given user now)
* Retention policy
* Separate types of user consents

Points partially covered:

* Your ToS/consents types changing (all model requirements are in here, it's just a matter of adding a redirect after user logs in with a form to fill)
* Log cleansing - slightly modified config/initializers/filter_parameter_logging.rb

Points not covered:

* auditing - no admin panel built in to show this kind of functionality but you can get really far by adding audited gem anyway
* testing - will probably add some if I see anyone interested in using this app for something

Tested on:

* Ruby 2.5.0
* Redis 3.2.1 (everything is namespaced in encrypt namespace so it probably won't hinder your environment)
* Standard SQLite adapter

Usage:

There is a seeds.rb file so you can do rails db:seed to have two standard types of user consents, this is enough to complete registration. 

If you need a more detailed description then visit https://blog.vraith.com for details
