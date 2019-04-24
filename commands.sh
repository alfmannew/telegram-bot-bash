#!/bin/bash
# file: commands.sh
# do not edit this file, instead place all your commands in mycommands.sh

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.70-dev2-18-g097a841
#
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# adjust your language setting here, e.g.when run from other user or cron.
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing



if [ "$1" != "source" ]; then
  # to change the default info message overwrite bashbot_info in mycommands.sh
  bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an interface for CLI programs.
It currently can send, recieve and forward messages, custom keyboards, photos, audio, voice, documents, locations and video files.
'

  # to change the default help messages overwrite in mycommands.sh
  bashbot_help='*Available commands*:
*• /start*: _Start bot and get this message_.
*• /info*: _Get shorter info message about this bot_.
*• /question*: _Start interactive chat_.
*• /cancel*: _Cancel any currently running interactive chats_.
*• /kickme*: _You will be autokicked from the chat_.
*• /leavechat*: _The bot will leave the group with this command _.
Written by Drew (@topkecleon), Daniil Gentili (@danogentili) and KayM(@gnadelwartz).
Get the code in my [GitHub](http://github.com/topkecleon/telegram-bot-bash)
'

  # load additional modules
  [ -r "modules/aliases.sh" ] && source "modules/aliases.sh"
  [ -r "modules/background.sh" ] && source "modules/background.sh"
  # ... more modules here ...

  # mycommands is the last "module" to source in
  # shellcheck source=./commands.sh
  [ -r "mycommands.sh" ] && source "mycommands.sh"

fi

if [ "$1" = "source" ];then
	# Set INLINE to 1 in order to receive inline queries.
	# To enable this option in your bot, send the /setinline command to @BotFather.
	INLINE="0"
	# Set to .* to allow sending files from all locations
	FILE_REGEX='/home/user/allowed/.*'
else
	if ! tmux ls | grep -v send | grep -q "$copname"; then
		# interactive running?
		[ ! -z "${URLS[*]}" ] && {
			curl -s "${URLS[*]}" -o "$NAME"
			send_file "${CHAT[ID]}" "$NAME" "$CAPTION"
			rm -f "$NAME"
		}
		[ ! -z "${LOCATION[*]}" ] && send_location "${CHAT[ID]}" "${LOCATION[LATITUDE]}" "${LOCATION[LONGITUDE]}"

		# Inline
		if [ "$INLINE" = 1 ]; then
			# inline query data
			iUSER[FIRST_NAME]="$(echo "$res" | sed 's/^.*\(first_name.*\)/\1/g' | cut -d '"' -f3 | tail -1)"
			iUSER[LAST_NAME]="$(echo "$res" | sed 's/^.*\(last_name.*\)/\1/g' | cut -d '"' -f3)"
			iUSER[USERNAME]="$(echo "$res" | sed 's/^.*\(username.*\)/\1/g' | cut -d '"' -f3 | tail -1)"
			iQUERY_ID="$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -1)"
			iQUERY_MSG="$(echo "$res" | sed 's/^.*\(inline_query.*\)/\1/g' | cut -d '"' -f5 | tail -6 | head -1)"

			# Inline examples
			if [[ "$iQUERY_MSG" = "photo" ]]; then
				answer_inline_query "$iQUERY_ID" "photo" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg" "http://blog.techhysahil.com/wp-content/uploads/2016/01/Bash_Scripting.jpeg"
			fi

			if [[ "$iQUERY_MSG" = "sticker" ]]; then
				answer_inline_query "$iQUERY_ID" "cached_sticker" "BQADBAAD_QEAAiSFLwABWSYyiuj-g4AC"
			fi

			if [[ "$iQUERY_MSG" = "gif" ]]; then
				answer_inline_query "$iQUERY_ID" "cached_gif" "BQADBAADIwYAAmwsDAABlIia56QGP0YC"
			fi
			if [[ "$iQUERY_MSG" = "web" ]]; then
				answer_inline_query "$iQUERY_ID" "article" "GitHub" "http://github.com/topkecleon/telegram-bot-bash"
			fi
		fi & # note the & !
	fi
	case "$MESSAGE" in
		################################################
		# DEFAULT commands start here, edit messages only
		'/info')
			_markdown_message "${bashbot_info}"
			;;
		'/start')
			send_action "${CHAT[ID]}" "typing"
			_is_botadmin && _markdown_message "You are *BOTADMIN*."
			if _is_allowed "start" ; then
				_markdown_message "${bot_help}"
			else
				_message "You are not allowed to start Bot."
			fi
			;;
			
		'/leavechat') # bot leave chat if user is admin in chat
			if _is_admin ; then 
				_markdown_message "*LEAVING CHAT...*"
   				_leave
			fi
     			;;
     			
     		'/kickme')
     			_kick_user "${USER[ID]}"
     			_unban_user "${USER[ID]}"
     			;;
     			
		'/cancel')
			checkprog
			if [ "$res" -eq 0 ] ; then killproc && _message "Command canceled.";else _message "No command is currently running.";fi
			;;
		*)	# forward other messages to optional dispatcher
			_is_function startproc && if tmux ls | grep -v send | grep -q "$copname"; then inproc; fi # interactive running
			_is_function mycommands && mycommands
			;;
	esac
fi
