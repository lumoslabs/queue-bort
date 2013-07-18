queue-bort
==========

Install and run:
----------------

- install Meteor: `curl https://install.meteor.com | /bin/sh` (see http://docs.meteor.com)
- install Meteorite using NPM: `npm install -g meteorite`
- clone queue-bort repo
- `cp server/config.js.coffee.example server/config.js.coffee`
- fill in values in `server/config.js.coffee`
- `cp qb.example qb`
- fill in ROOT_URL and PORT in `qb`
- `chmod +x qb`
- run: `./qb`
- configure OAuth with "Configure GitHub Login" button in upper right
