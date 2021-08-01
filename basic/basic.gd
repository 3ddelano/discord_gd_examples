extends Control

"""
Basic bot which receives messages
and responds with the same text.
"""

func _ready():
	var bot = $DiscordBot
	bot.TOKEN = "YOUR_TOKEN_HERE"

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

	var content = message.content

	# Check if the message has some text
	if content != "":
		# Send a message with the same content
		bot.send(message, content)
