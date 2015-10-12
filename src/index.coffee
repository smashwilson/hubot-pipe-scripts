# Description:
#   Utility commands that are useful when piped output from other commands.
#
# Commands:
#   hubot match /regexp/ - Pass through regexp matches.
#   hubot grep /regexp/ - Pass through lines containing regexp matches.
#   hubot s /regexp/ "replacement" - Replace regexp matches with the substitution text.
#   hubot loud - WHAT SPEAK UP I CAN'T HEAR YOU
#   hubot quiet - shhhhhh
#   hubot devnull - File complaints here
#
# Author:
#   smashwilson

parseDelimited = (delimiter, text) ->
  pattern = ""
  escaped = false

  unless text[0] is delimiter
    return [new Error("Text must begin with #{delimiter}"), null, null]

  for i in [1...text.length]
    if escaped
      escaped = false
      continue

    letter = text[i]
    if letter is "\\"
      escaped = true
      continue

    if letter is delimiter
      next = i + 1
      return [null, text[1...i], text[next..]]

  return [new Error("Unterminated #{delimiter}"), null, null]

parseRegexp = (text) ->
  try
    [err, pattern, left] = parseDelimited "/", text
    rx = new RegExp(pattern, 'gi')
    [err, rx, left]
  catch e
    [e, null, null]

module.exports = (robot) ->

  robot.respond /match (.*)/, (resp) ->
    [err, rx, left] = parseRegexp resp.match[1]
    if err?
      resp.send err.message
      return

    results = left.match rx
    return unless results?
    resp.send result for result in results
