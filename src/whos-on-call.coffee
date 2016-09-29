# Description:
#   Change Channel Header based on who is on-call on pagerduty
#
# Configuration
#   WHOS_ON_CALL_API_KEY
#   WHOS_ON_CALL_WEBHOOK_SECRET
#   WHOS_ON_CALL_SCHEDULE_ID
#   WHOS_ON_CALL_HEADER_TEMPLATE
#
# Notes:
#   WHOS_ON_CALL_API_KEY: Pagerduty API key
#   WHOS_ON_CALL_WEBHOOK_SECRET: Random string for validating webhook request authenticity
#   WHOS_ON_CALL_SCHEDULE_ID: Pagerduty Schedule ID string - fetch this using the Pagerduty API, or try scraping it off the site using developer tools
#   WHOS_ON_CALL_HEADER_TEMPLATE: Default template text to use when updating a channel header
#
# Author
#   Christopher De Cairos

API_KEY = process.env.WHOS_ON_CALL_API_KEY
WEBHOOK_SECRET = process.env.WHOS_ON_CALL_WEBHOOK_SECRET
SCHEDULE_ID = process.env.WHOS_ON_CALL_SCHEDULE_ID
DEFAULT_HEADER_TEMPLATE = process.env.WHOS_ON_CALL_HEADER_TEMPLATE
PAGERDUTY_SCHEDULE_REQUEST_URI = "https://api.pagerduty.com/oncalls?schedule_ids[]=#{SCHEDULE_ID}"

module.exports = (robot) ->

  currentOnCallEngineer = ""

  robot.router.post '/webhook/on-call/:channel', (req, res) ->

    res.end ""

    requestSecret = req.body.secret

    unless requestSecret == WEBHOOK_SECRET
      return robot.logger.error "Invalid hook received"

    channel = req.params.channel
    headerTemplate = if req.body.header? then req.body.header else DEFAULT_HEADER_TEMPLATE

    robot.http(PAGERDUTY_SCHEDULE_REQUEST_URI)
      .header("Authorization", "Token token=#{API_KEY}")
      .get() (err, res, body) ->

        if err?
          return robot.logger.error err

        try
          json = JSON.parse body
        catch error
          return robot.logger.error error

        onCallEngineer = json.oncalls[0].user.summary

        return unless onCallEngineer != currentOnCallEngineer

        robot.logger.info "Updating on call engineer to: #{onCallEngineer}"

        currentOnCallEngineer = onCallEngineer

        header = headerTemplate.replace("$ENGINEER", currentOnCallEngineer)

        robot.adapter.changeHeader(channel, header)


