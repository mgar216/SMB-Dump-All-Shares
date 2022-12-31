#!/bin/bash
if [[ -z $1 ]];
then
    echo -n "Usage: sdas target [username] [password]"
    exit 1
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color
    echo -e -n "\n"
    echo -e "\t${GREEN}----------------------------${NC}"
    echo -e "\t${GREEN}---SMB -- DUMP ALL SHARES---${NC}"
    echo -e "\t${GREEN}----------------------------${NC}"
    echo -e -n "\n"
    [[ -d "smb_dump" ]] || mkdir "smb_dump" 2> /dev/null
    cd "smb_dump"
    smbmap_cmd="-H $1"
fi

if [[ -z $2 ]];
then
    username=""
    smbmap_cmd="$smbmap_cmd -u 'a'"
else
    username="$2"
    echo -e "${GREEN}[*]${NC} Using Username: ${GREEN}$username${NC}"
    smbmap_cmd="$smbmap_cmd -u $2"
fi

if [[ -z $3  ]];
then
    password=""
    smbmap_cmd="$smbmap_cmd -p 'a'"
else
    password="$3"
    echo -e "${GREEN}[*]${NC} Using Password: ${GREEN}$password${NC}"
    smbmap_cmd="$smbmap_cmd -p $3"
fi

echo -e -n "\n"

all_shares=$(smbclient -L //"$1" -U="$username" --password="$password" -g -d 0 | grep -oP '\|.*\|' | tr -d '|')

OLDIFS=$IFS
IFS=$'\n'

echo -e "${GREEN}[+]${NC} Found the following Shares:"
for i in $all_shares; do
    echo -e "\t//$1/${GREEN}$i${NC}"
done

IFS=$OLDIFS

echo -e -n "\n"
echo -e "${GREEN}[+]${NC} Checking READ/WRITE Permissions:"
smbmap_results=$(smbmap $smbmap_cmd | tail -n+2)
echo -e "${GREEN}$smbmap_results${NC}"
echo -e -n "\n"

echo -e "${GREEN}[*]${NC} Dumping all available Shares for: ${GREEN}$1${NC}"
echo -e -n "\n"

OLDIFS=$IFS
IFS=$'\n'

for i in $all_shares; do
    [[ -d "$i" ]] || mkdir "$i" 2> /dev/null
    cd "$i"
    echo -e "${GREEN}[+]${NC} Dumping Share: ${GREEN}$i${NC}"
    status=$(smbclient //"$1"/"$i" -U="$username" --password="$password" -c "prompt off; recurse on; mget *")
    cd ../
    if [ "$status" == "NT_STATUS_NO_SUCH_FILE listing \*" ]
    then
        rm -rf "$i"
        echo -e "${RED}[-]${NC} Could not connect to ${RED}$i${NC} or Share was empty."
        echo -e -n "\n"
    elif [[ -d "$status" ]]
    then
        echo "${RED}[-]${NC} An Error Occurred when Accessing the Share."
        echo -e -n "\n"
    elif [[ $status =~ "NT_STATUS_IO_TIMEOUT" ]]
    then
        echo -e "${RED}[-]${NC} Timeout Error while Retrieving Files."
        echo -e -n "\n"
    elif [[ $status =~ "NT_STATUS_ACCESS_DENIED" ]]
    then
        echo -e "${RED}[-]${NC} READ ACCESS is Denied for ${RED}$i${NC}"
        echo -e -n "\n"
    elif [[ $status == "" ]]
    then
        echo -e "${RED}[-]${NC} Unknown Error when Accessing ${RED}$i${NC}"
        echo -e -n "\n"
    else
        echo "Debug: $status."
        echo -e -n "\n"
    fi
done
IFS=$OLDIFS
