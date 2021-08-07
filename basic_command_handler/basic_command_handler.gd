extends Control

"""
Bot which reponds only to messages
with start with a certain prefix.
The bot has a few commands
"""

# The prefix which all the received messages should start with,
# in order for the bot to respond to them.
var PREFIX = "gd."

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

	# Check if the message content begins with the prefix
	if not message.content.begins_with(PREFIX):
		return

	# Now we need to convert the rest of the message content
	# into two parts:
	# The first is a command name (cmd)
	# The second is the command arguments (args)

	# First we get the remaining string without the prefix
	var raw_content = message.content.lstrip(PREFIX)

	var tokens = generate_tokens(raw_content)

	# Now we get the command name from the tokens, and convert it to lowercase
	var cmd = tokens[0].to_lower()

	tokens.remove(0) # Remove the command name from the tokens

	# Now we get the Array of arguments for that command
	var args = tokens

	 # Note: We pass the bot, message and channel too
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
		"ping":
			# The ping command will send the latency of the bot
			# Example Usage: gd.ping

			var starttime = OS.get_ticks_msec() # Get the current epoch

			# Send a message and wait for the response
			var msg = yield(bot.reply(message, "Ping.."), "completed")

			# Get the latency of the bot
			var latency = str(OS.get_ticks_msec() - starttime)

			# Edit the sent message with the latency
			bot.edit(msg, "Pong! Latency is " + latency + "ms.")

		"say":
			# The say command will repeat whatever the user typed

			# We get the arguments joined using a whitespace characters
			print(args)
			var to_say = PoolStringArray(args).join(" ")

			bot.reply(message, "You said \"" + to_say + "\"")

	pass
