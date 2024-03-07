# Before running the app, you need to authenticate with your Twitter account
# This is a one-time per session step
# As long as you do not restart R, you do not need to authenticate again

# First you need to apply for a developer account at https://developer.twitter.com.

# Then you need to create a new app at https://developer.twitter.com/en/apps

# You will need to name your app. You will then see several keys and tokens
# that will allow your SafeGoOut app to access your Twitter account.
# Make a note of the following
# - Client ID
# - Client secret
# - Bearer Token

# Now, uncomment line 21 and run the code
# you will get a pop-up window asking you to enter your client ID and then
# your client secret. 
# Do not forget to replace "app_name" with the name of your app
# Note that the quotes are required
# client <- rtweet::rtweet_client(app = "app_name")

# Uncomment line 24 and run the code
# rtweet::client_as(client)

# Uncomment line 28 and run the code
# You will get a pop-up window asking you yo enter your bearer token
# auth <- rtweet::rtweet_app()

# Uncomment lines 31 and 32 and run the code
# rtweet::auth_as(auth)
# rtweet::auth_save(auth, "twitter-auth")
