# hubot-pipe scripts

[![Greenkeeper badge](https://badges.greenkeeper.io/smashwilson/hubot-pipe-scripts.svg)](https://greenkeeper.io/)

Utility scripts for use with [hubot-pipe](https://github.com/smashwilson/hubot-pipe), like `grep` for text search, or `s` for simple regexp substitution. See [`src/index.coffee`](src/index.coffee) for the full list.

## Installing

1. Add `hubot-pipe-scripts` to your `package.json` with `npm install --save hubot-pipe-scripts`:

  ```json
    "dependencies": {
      "hubot-pipe-scripts": "~0.0.1"
    },
  ```
2. Require the module in `external-scripts.json`:

  ```json
  ["hubot-pipe-scripts"]
  ```
3. Run `npm update` and restart your Hubot.
