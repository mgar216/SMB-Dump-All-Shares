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
fi

if [[ -z $2 ]];
then
    username=""
else
    username="$2"
    echo -e "${GREEN}[*]${NC} Using Username: ${GREEN}$username${NC}"
    echo -e -n "\n"
fi

if [[ -z $3  ]];
then
    password=""
else
    password="$3"
    echo -e "${GREEN}[*]${NC} Using Password: ${GREEN}$password${NC}"
    echo -e -n "\n"
fi


all_shares=$(smbclient -L //"$1" -U="$username" --password="$password" 2> /dev/null | awk '{ print $1 }' | tail -n+4 | head -n+2)
echo -e "${GREEN}[*]${NC} Dumping all Shares for: ${GREEN}$1${NC}"
echo -e -n "\n"
for i in $all_shares; do
    [[ -d "$i" ]] || mkdir "$i" 2> /dev/null
    cd "$i"
    echo -e "${GREEN}[+]${NC} Dumping Share: ${GREEN}$i${NC}"
    status=$(smbclient //"$1"/"$i" -U="" --password="" -c "prompt off; recurse on; mget *")
    cd ../
    if [ "$status" == "NT_STATUS_NO_SUCH_FILE listing \*" ]
    then
        rm -rf "$i"
        echo -e "${RED}[-]${NC} Could not connect to ${RED}$i${NC} or Share was empty."
        echo -e -n "\n"
    else
        echo -e -n "\n"
    fi
done
