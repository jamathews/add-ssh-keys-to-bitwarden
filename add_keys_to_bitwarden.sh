#!/usr/bin/env bash

# defined these before running:
# BW_CLIENTID
# BW_CLIENTSECRET
# TARGET_FOLDER_ID

bw login --apikey
export BW_SESSION=$(bw unlock --raw)
for pub in ~/.ssh/*.pub
do
	export NOTE_NAME="SSH-Key-from-$(hostname)--$(basename ${pub})"
	priv=$(dirname ${pub})/$(basename ${pub} .pub)
	if [[ -f ${pub} ]] && [[ -f ${priv} ]]; then
		EXISTING_NOTE=$(bw list items --search ${NOTE_NAME})
		if [[ ${EXISTING_NOTE} == "[]" ]]; then
			echo "Creating ${NOTE_NAME}"
			NEW_NOTE_ID=$(bw get template item | jq '.type = 2 | .secureNote.type = 0 | .notes = "ssh key pair" | .name = env.NOTE_NAME | .folderId = env.TARGET_FOLDER_ID' | bw encode | bw create item | jq '.id' | tr -d \")
			echo "NEW_NOTE_ID=${NEW_NOTE_ID}"
			bw create attachment --file ${pub} --itemid ${NEW_NOTE_ID}
			bw create attachment --file ${priv} --itemid ${NEW_NOTE_ID}
		else
			echo "Found ${NOTE_NAME}:\n${EXISTING_NOTE}"
		fi
	else
		echo "${pub} or ${priv} doesn't exist!" 
	fi
done

bw logout
