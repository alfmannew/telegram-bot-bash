#!/bin/bash
# file: question.sh
# example for an interactive chat, run with startproc question.sh

# This file is public domain in the USA and all free countries.
# Elsewhere, consider it to be WTFPLv2. (wtfpl.net/txt/copying)

#### $$VERSION$$ v0.96-dev-7-g0153928

# adjust your language setting here
# https://github.com/topkecleon/telegram-bot-bash#setting-up-your-environment
export 'LC_ALL=C.UTF-8'
export 'LANG=C.UTF-8'
export 'LANGUAGE=C.UTF-8'

unset IFS
# set -f # if you are paranoid use set -f to disable globbing

echo "Why hello there.
Would you like some tea (y/n)?"
read -r answer
[[ $answer =~ ^([yY][eE][sS]|[yY])$ ]] && echo "OK then, here you go: http://www.rivertea.com/blog/wp-content/uploads/2013/12/Green-Tea.jpg" || echo "OK then."
until [ "$SUCCESS" = "y" ] ;do
	echo 'Do you like Music? mykeyboardstartshere "Yass!" , "No"'
	read -r answer
	case $answer in
		'Yass!') echo "Goody! mykeyboardendshere";SUCCESS=y;;
		'No') echo "Well that's weird. mykeyboardendshere";SUCCESS=y;;
		'') echo "empty answer!" && exit;;
		*) SUCCESS=n;;
	esac
done
exit
