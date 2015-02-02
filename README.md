# Ruby Distributed File Server

Requires Ruby and the sqlite3 gem(sudo gem install sqlite3).

## File Server

The file server uses th upload/download model. Multiple instances can be created. They join the network by sending a 'join' request to the directory service.

## Directory Server

The directory server has an sqlite3 database of all the connected file servers and a table containing filenames and the server they can be located at.

## Client Proxy

The client proxy contains methods for uploading and downloding a file. It handles the interaction with the directory server and the file server.