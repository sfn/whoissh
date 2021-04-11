#!/bin/bash

# A useless, unusable, incomplete, badly coded and poorly designed 
# bash rewrite of the standard Linux whois command
# URL: https://github.com/sfn/whoissh

# General variables
VERSION="0.1.0"
SLOGAN="The useless whois client you'll never need or want to use"
AUTHOR="sfn - https://github.com/sfn/whoissh"
WHOIS_HOST=""
WHOIS_PORT="43"
GUESS_WHOIS_SERVER=1
VERBOSE=0

# Some whois servers, but not all of them
declare -A WHOIS_SERVERS
WHOIS_SERVERS[com]="whois.verisign-grs.com"
WHOIS_SERVERS[net]="whois.verisign-grs.com"
WHOIS_SERVERS[org]="whois.pir.org"
WHOIS_SERVERS[eu]="whois.eu"
WHOIS_SERVERS[it]="whois.nic.it"

# Display the useless help
# The help text is somehow copied from the standard Linux whois command 
function help() {
    echo "Usage: ${0} [OPTION]... DOMAINNAME..."
    echo
cat << HELP-DOC
-h HOST, --host HOST   connect to server HOST
-p PORT, --port PORT   connect to PORT
      --help           display this help and exit
      --version        output version information and exit
      --verbose        explain what is being done
HELP-DOC
}

# Guess the whois server to use
# I'm lazy and so I fall back to $TLD.whois-servers.net
function guess_whois_server() {
    TLD=`echo $1 | rev | cut -d "." -f1 | rev`
    if [ ${WHOIS_SERVERS["$TLD"]+_} ]
    then
        WHOIS_HOST=${WHOIS_SERVERS["$TLD"]}
        WHOIS_PORT=43
    else
        WHOIS_HOST=${TLD}".whois-servers.net"
        WHOIS_PORT=43
    fi
}

if [[ $# -le 0 ]]; then
    help
    exit 2
fi

# Parse options
OPTIONS=$(getopt -n "$0"  -o "h:p:" --long "host:,port:,verbose,help,version"  -- "$@")

if [[ $? -ne 0 ]]
then
    help
    exit 2
fi

eval set -- "$OPTIONS"

while true
do
  case $1 in
    -h|--host)
        shift
        WHOIS_HOST=$1
        GUESS_WHOIS_SERVER=0
        ;;
    -p|--port)
        shift
        WHOIS_PORT=$1
        ;;
    --verbose)
        VERBOSE=1
	;;
    --help)
        echo $SLOGAN 
        help
        exit 0
        ;;
    --version)
	echo "$0 - ${SLOGAN}" 
        echo "Version ${VERSION}"
        echo
        echo $AUTHOR
        exit 0
        ;;
    --)
        shift
        break;;
  esac
shift
done

# The query to send to the whois server
QUERY=${@: -1}

# If the whois server to send the query to isn't set via option, try to guess it
if [[ $GUESS_WHOIS_SERVER -eq 1 ]]
then
    guess_whois_server $QUERY
fi

# Don't really need this, just copying what standard whois does
if [[ $VERBOSE -eq 1 ]]
then
    echo "Using server ${WHOIS_HOST}"
    echo 'Query string: "'${QUERY}'"'
    echo
fi

# Check if connection to the whois server goes wrong
(echo >/dev/tcp/${WHOIS_HOST}/${WHOIS_PORT}) &>/dev/null
if [[ $? -ne 0 ]]
then
   echo "Something went wrong"
   exec 10>&-
   exec 10<&-
   exit 1
fi

# Send the query to the whois server
exec 10<>/dev/tcp/${WHOIS_HOST}/${WHOIS_PORT}
echo -e "${QUERY}\r\n" >&10 
cat <&10 # Print the response
exec 10>&-
exec 10<&-
exit 0
