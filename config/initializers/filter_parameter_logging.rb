# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]
#Some custom fields we probably dont want to see in logs
Rails.application.config.filter_parameters += [:email, :name, :address, :password_confirmation]
