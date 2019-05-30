#!/bin/bash
# file: commands.sh
# do not edit this file, instead place all your commands in mycommands.sh

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)
#
#### $$VERSION$$ v0.90-rc1-1-g46271cc
#

# adjust your language setting here, e.g.when run from other user or cron.
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

# to change the default info message overwrite bashbot_info in mycommands.sh
bashbot_info='This is bashbot, the Telegram bot written entirely in bash.
It features background tasks and interactive chats, and can serve as an interface for CLI programs.
It currently can send, recieve and forward messages, custom keyboards, photos, audio, voice, documents, locations and video files.
'

# to change the default help messages overwrite in mycommands.sh
bashbot_help='*Available commands*:
*• /start*: _Start bot and get this message_.
*• /help*: _Get this message_.
*• /info*: _Get shorter info message about this bot_.
*• /question*: _Start interactive chat_.
*• /cancel*: _Cancel any currently running interactive chats_.
*• /kickme*: _You will be autokicked from the chat_.
*• /leavechat*: _The bot will leave the group with this command _.
Written by Drew (@topkecleon), Daniil Gentili (@danogentili) and KayM(@gnadelwartz).
Get the code in my [GitHub](http://github.com/topkecleon/telegram-bot-bash)
'

# load modues on startup and always on on debug
if [ "${1}" = "source" ] || [[ "${1}" = *"debug"* ]] ; then
	# load all readable modules
	for modules in ${MODULEDIR:-.}/*.sh ; do
		# shellcheck source=./modules/aliases.sh
		[ -r "${modules}" ] && source "${modules}" "${1}"
	done
fi

# defaults to no inline and nonsense home dir
export INLINE="0"
export FILE_REGEX='/home/user/allowed/.*'


# load mycommands
# shellcheck source=./commands.sh
[ -r "${BASHBOT_ETC:-.}/mycommands.sh" ] && source "${BASHBOT_ETC:-.}/mycommands.sh"  "${1}"


if [ "${1}" != "source" ];then
    # detect inline commands....
    # no default commands, all processing is done in myinlines()
    if [ "$INLINE" != "0" ] && [ "${iQUERY[ID]}" != "" ]; then
    	# forward iinline query to optional dispatcher
	_exec_if_function myinlines

    # regular (gobal) commands ...
    # your commands are in mycommands() 
    else

	###################
	# user defined commands must placed in mycommands
	_exec_if_function mycommands

	# run commands if true (0) is returned or if mycommands dose not exist
	# shellcheck disable=SC2181
	if [ "$?" = "0" ] && [ "${CMD}" != "" ]; then
	    case "${CMD}" in
		################################################
		# GLOBAL commands start here, edit messages only
		'/info')
			_markdown_message "${bashbot_info}"
			;;
		'/start')
			send_action "${CHAT[ID]}" "typing"
			_is_botadmin && _markdown_message "You are *BOTADMIN*."
			if _is_botadmin || _is_allowed "start" ; then
				_markdown_message "${bashbot_help}"
			else
				_message "You are not allowed to start Bot."
			fi
			;;
			
		'/help')
			_markdown_message "${bashbot_help}"
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
			checkproc
			if [ "$res" -eq 0 ] ; then killproc && _message "Command canceled.";else _message "No command is currently running.";fi
			;;
		*)	# forward messages to optional dispatcher
			_exec_if_function send_interactive "${CHAT[ID]}" "${MESSAGE}"
			;;
	     esac
	fi
    fi 
fi
