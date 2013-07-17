queue-bort
==========

Install and run:
----------------

- clone repo
- `cp server/config.js.coffee.example server/config.js.coffee`
- fill in values in `server/config.js.coffee`
- install Meteor: `curl https://install.meteor.com | /bin/sh` (see http://docs.meteor.com)
- install Meteorite using NPM: `npm install -g meteorite`
- run server on port XXXX: `mrt -p XXXX`
- to run with a different host URL than `localhost`, set env var ROOT_URL (for allowing remote users to log in via Github); e.g., `ROOT_URL=www.example.com:5100 mrt -p 5100`
