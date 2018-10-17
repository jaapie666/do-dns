#!/bin/bash

# Script and functions to list and manipulate DNS records hosted by Digital Ocean

# Location of configuration file

CONFIG_DIR=$HOME/.config/do-dns/do-dns.config

DIGITALOCEAN_URL="https://api.digitalocean.com/v2"

# Utility functions and variables

source $CONFIG_DIR

DO_TMP='/tmp/do-dns.tmp'

DO_DNS_COMMAND=$1  #list domains or records
DIGITALOCEAN_DOMAIN=$2 #domain name

# Functions


api-request()   # request information using the API
{
   curl -s -X GET \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
           "$DIGITALOCEAN_URL" > $DO_TMP
}

records()   # List the records for a particular domain
{ 
  if [ -z "$DIGITALOCEAN_DOMAIN" ]
  then
    echo No domain given
    exit
  else
    
    DIGITALOCEAN_URL="$DIGITALOCEAN_URL/domains/$DIGITALOCEAN_DOMAIN/records"

    api-request
    
    echo -e "\n             Domain Records for $DIGITALOCEAN_DOMAIN:"
    echo --
    clean_output ${FUNCNAME[0]}
  fi
}

domains()    # List the domains hosted by Digital Ocean on this API token
{
  DIGITALOCEAN_URL="$DIGITALOCEAN_URL/domains"
  api-request
  clean_output ${FUNCNAME[0]}
}

clean_output()  # Make the output of the curl command look real nice
{  
  GREP_ARG=''

  if [ "$1" == 'records' ] || [ "$1" == 'record' ]
  then
    GREP_ARG='-C 1 --context=1 name'
  elif [ "$1" == 'domains' ] || [ "$1" == 'domain' ]
  then
    GREP_ARG='-e name'
  else
    echo 'Error in cleanOutput(): GREP_ARG not properly set'
    echo exiting  #actually exit here in real script
  fi
  
    cat $DO_TMP | json_reformat | grep $GREP_ARG | sed s'/[",]/ /g' | sed s'/ :  /: /'
}

  if [ -z "$1" ]
  then
    echo No command given
    exit
  fi
  $1

  rm $DO_TMP
