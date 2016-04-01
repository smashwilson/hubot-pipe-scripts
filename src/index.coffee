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

  # Skip initial whitespace.
  start = text.search /\S/
  start = 0 if start is -1

  # If the next character is the delimiter character, we'll read a delimited string. Otherwise,
  # we'll read until the next whitespace.
  isDelimited = text[start] is delimiter
  start += 1 if isDelimited

  for i in [start...text.length]
    if escaped
      escaped = false
      continue

    letter = text[i]
    if letter is "\\"
      escaped = true
      continue

    if (isDelimited and letter is delimiter) or (!isDelimited and letter.match /\s/)
      next = i + 1
      return [null, text[start...i], text[next..]]

  return [new Error("Unterminated #{delimiter}"), null, null]

parseRegexp = (text) ->
  try
    [err, pattern, left] = parseDelimited "/", text
    rx = new RegExp(pattern, 'gi')
    [err, rx, left]
  catch e
    [e, null, null]

module.exports = (robot) ->

  inputFrom = (msg) ->
    if msg.match[1]? && msg.match[1].trim().length > 0
      msg.match[1]
    else
      robot.mostRecent(msg) || ''

  robot.respond /match\s*([^]*)/im, (resp) ->
    [err, rx, left] = parseRegexp m
    if err?
      resp.send err.message
      return

    unless left.trim().length > 0
      left = robot.mostRecent(resp)

    results = left.match rx
    return unless results?
    resp.send result for result in results

  robot.respond /grep ([^]*)/im, (resp) ->
    [err, rx, left] = parseRegexp resp.match[1]
    if err?
      resp.send err.message
      return

    unless left.trim().length > 0
      left = robot.mostRecent(resp)

    left = left.replace /^\s*/, ""

    for line in left.split /\n/
      resp.send line if line.search(rx) isnt -1

  robot.respond /s ([^]*)/im, (resp) ->
    [err, rx, left] = parseRegexp resp.match[1]
    if err?
      resp.send err.message
      return

    [err, replacement, left] = parseDelimited '"', left
    if err?
      resp.send err.message
      return

    unless left.trim().length > 0
      left = robot.mostRecent(resp)

    left = left.replace /^\s*/, ""

    left = left.replace rx, replacement
    resp.send left

  robot.respond /loud\s*([^]*)/im, (resp) ->
    resp.send inputFrom(resp).toUpperCase()

  robot.respond /quiet\s*([^]*)/im, (resp) ->
    resp.send inputFrom(resp).toLowerCase()

  # Fun fact: devnull doesn't even need to exist
