extends Control

"""
Bot which displays the user's avatar
and guild icon.
The bot has a a single command: gd.image
"""

var PREFIX = "gd."

func _ready():
	print("Avatars And Icons Bot")
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
		"image":
			print("Sending avatar now")
			# Getting the raw bytes of the avatar of the user
			# Make sure to use yield so we wait till the avatar is fetched
			var avatar_bytes = yield(message.author.get_display_avatar({"size": 128}), "completed")
			# Now we send the file
			bot.reply(message, "Your avatar is", {
				"files": [
					{
						"name": "avatar.png",
						"media_type": "image/png",
						"data": avatar_bytes
					}
				]
			})

			# Getting the raw bytes of the icon of the guild of the user
			# Make sure to use yield so we wait till the icon is fetched
			var guild_icon_bytes = yield(bot.get_guild_icon(message.guild_id, 128), "completed")
			bot.send(message, "The Guild Icon", {
				"files": [
					{
						"name": "guild_icon.png",
						"media_type": "image/png",
						"data": guild_icon_bytes
					}
				]
			})


			# Show the avatar and guild icon in the Godot game

			# First we need to convert the raw png bytes to an Image then an ImageTexture
			# For this we use the Helpers.to_png_image() and Helpers.to_image_texture()

			var avatar_texture = Helpers.to_image_texture(Helpers.to_png_image(avatar_bytes))
			$Avatar.texture = avatar_texture

			var guild_icon_texture = Helpers.to_image_texture(Helpers.to_png_image(guild_icon_bytes))
			$GuildIcon.texture = guild_icon_texture
