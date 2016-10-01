[![Build Status](https://travis-ci.org/cadecairos/hubot-whos-on-call-mattermost.svg)](https://travis-ci.org/cadecairos/hubot-whos-on-call-mattermost)
[![npm version](https://badge.fury.io/js/hubot-whos-on-call-mattermost.svg)](http://badge.fury.io/js/hubot-whos-on-call-mattermost)
[![dependencies](https://david-dm.org/cadecairos/hubot-whos-on-call-mattermost.svg)](https://david-dm.org/cadecairos/hubot-whos-on-call-mattermost)

[![npm stats](https://nodei.co/npm/hubot-whos-on-call-mattermost.png?downloads=true)](https://nodei.co/npm/hubot-whos-on-call-mattermost)

# hubot-whos-on-call-mattermost

This script adds a webhook to hubot that can be called periodically to update a [Mattermost](https://mattermost.org) channel's header text with the name of the on-call engineer via pagerduty.

Sadly, Pagerduty doesn't have a webhook event for a change in schedule, so a cron job of some kind will need to trigger the script periodically. The header isn't updated if the on-call engineer hasn't changed.

See [`src/whos-on-call.coffee`](src/whos-on-call.coffee) for full documentation.

**NOTE: This script requires at least version 3.4.0 of [hubot-matteruser](https://www.npmjs.com/package/hubot-matteruser)**

## Installation

`npm install hubot-whos-on-call-mattermost`

Then add **hubot-whos-on-call-attermost** to your `external-scripts.json`:

```json
[
  "whos-on-call-mattermost"
]
```

## Triggering the script

Make an HTTP POST request to `{HUBOT_HOST}/webhook/on-call/:channel_name`

The post body must contain a key called `secret` that should match the environment variable `WHOS_ON_CALL_WEBHOOK_SECRET`. This will ensure only authorized clients can trigger the script.

The post body can optionally contain a `header` key that specifies the text to set the header to. The string `$ENGINEER` in this variable will be replaced with the on-call engineer's name (as given by pagerduty). Not specifying this value will trigger the use of the `WHOS_ON_CALL_HEADER_TEMPLATE` environment variable.
