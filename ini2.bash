#!/bin/bash

# Function: get_config_list config_file
# Purpose : Print the list of configs from config file
get_config_list()
{
   typeset config_file=$1

   awk -F '[][]' '
      NF==3 && $0 ~ /^\[.*\]/ { print $2 }
   ' ${config_file}
}

# Function : set_config_vars config_file config [var_prefix]
# Purpose  : Set variables (optionaly prefixed by var_prefix) from config in config file
set_config_vars()
{
   typeset config_file=$1
   typeset config=$2
   typeset var_prefix=$3
   typeset config_vars
   declare -a ini

   local config_vars=$( 
        awk -F= -v Config="${config}" -v Prefix="${var_prefix}" '
        BEGIN { 
           Config = toupper(Config);
           patternConfig = "\\[" Config "]";
        }
        toupper($0)  ~ patternConfig,(/\[/ && toupper($0) !~ patternConfig)  { 
           if (/\[/ || NF <2) next;
           sub(/^[[:space:]]*/, "");
           sub(/[[:space:]]*=[[:space:]]/, "=");
           print Prefix $0;
        } ' ${config_file} )
   #echo "${config_vars}"
   ini["$config"]="${config_vars}"
   #eval "${config_vars}"
}

#
# Set variables for all config from config file
#
file=config.ini
for cfg in $(get_config_list ${file})
do
   #echo "--- Configuration [${cfg}] ---"
   unset $(set | awk -F= '/^cfg_/  { print $1 }') cfg_
   set_config_vars ${file} ${cfg} cfg_
   echo ini["set_1"]
   set | grep ^cfg_
done


