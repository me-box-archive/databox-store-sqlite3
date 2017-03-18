# Databox Store SQLite3

A simple Databox store with an SQLite3 backend for testing

For debug purposes:

## Installation
	git clone https://github.com/me-box/databox-store-sqlite3.git
	cd databox-store-mock
	npm install --production

## Usage
	npm start

Default port is 8080, but can be overridden using the PORT environment variable, i.e.:

	PORT=8081 npm start

Then interface with http://localhost:8080/.

Environment variables that are normally passed by the container manager also need to be set, and DNS resolution (e.g. arbiter -> localhost for debug) needs to be done externally when not running in a container.

## API Endpoints

### /

#### Description

Method: POST

Updates the record of containers and the extent of their corresponding permissions (default none) maintained by the arbiter.

##### Body Parameters

###### query

Type: string

An SQLite3 query.

##### Response

###### Success

  - Number of entries in DB

###### Error

  - 400: Missing macaroon
  - 403: Invalid macaroon
