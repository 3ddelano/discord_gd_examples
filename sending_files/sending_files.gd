extends Control

"""
Bot which sends image files.
The bot has a a single command: gd.file
"""

var PREFIX = "gd."

func _ready():
	print("Sending Files Bot")
	var bot = $DiscordBot
	bot.TOKEN = "YOUR_TOKEN_HERE"
	assert(bot.TOKEN != "YOUR_TOKEN_HERE", "You need to set a valid TOKEN for the bot.")

	# Connect the signals of DiscordBot to this script
	bot.connect("bot_ready", self, "_on_DiscordBot_bot_ready")
	bot.connect("message_create", self, "_on_DiscordBot_message_create")

	# Connect with Discord
	bot.login()


# Called when the bot is logged in to Discord
func _on_DiscordBot_bot_ready(bot: DiscordBot):
	print("Logged in as " + bot.user.username + "#" + bot.user.discriminator)
	print("Ready on " + str(bot.guilds.size()) + " guilds and " + str(bot.channels.size()) + " channels")

	# Set the presence of the bot
	bot.set_presence({
		"activity": {
			"type": "Game",
			"name": "Godot Engine"
		}
	})


# Called when the bot receives a message
func _on_DiscordBot_message_create(bot: DiscordBot, message: Message, channel: Dictionary):
	# Check if the user sending the message is a bot
	if message.author.bot:
		return

	# Check if the message content begins with the prefix
	if not message.content.begins_with(PREFIX):
		return

	var raw_content = message.content.lstrip(PREFIX)
	var tokens = generate_tokens(raw_content)
	var cmd = tokens[0].to_lower()
	tokens.remove(0) # Remove the command name from the tokens
	var args = tokens
	handle_command(bot, message, channel, cmd, args)



func generate_tokens(raw_content: String):
	"""
	This is a helper function which takes a string, and splits it using the space character into an Array
	Eg. "hello hi" -> ["hello", "hi"]
	Eg. "hello      hi" -> ["hello", "hi"]
	"""
	var tokens = []
	var r = RegEx.new()
	r.compile("\\S+") # Negated whitespace character class
	for token in r.search_all(raw_content):
		tokens.append(token.get_string())

	return tokens

func handle_command(bot: DiscordBot, message: Message, channel: Dictionary, cmd: String, args: Array):
	match cmd:
		"file":

			# Sending a local image file. Here we will use the icon.png
			var file = File.new()
			file.open("res://icon.png", File.READ)

			# Next we need to get the raw bytes of the file as a PoolByteArray
			var bytes = file.get_buffer(file.get_len())

			# Now we send the file
			bot.send(message, {
				"files": [
					{
						"name": "icon.png", # Name of the file with extension
						"media_type": "image/png", # The MIME type of the file
						"data": bytes # The raw bytes of the file
					}
				]
			})

			# Sending a screenshot of the game

			# First we get the screenshot of the viewport
			var image = get_viewport().get_texture().get_data()
			image.flip_y() # Flip on Y-Axis
			var bytes2 = image.save_png_to_buffer() # Convert the image to raw png bytes

			# Send the image
			bot.send(message, "Screenshot of the game", {
				"files": [
					{
						"name": "screenshot.png",
						"media_type": "image/png",
						"data": bytes2
					}
				]
			})
