// Description:
//   Utility commands that are useful when piped output from other commands.
//
// Commands:
//   hubot match /regexp/ - Pass through regexp matches.
//   hubot grep /regexp/ - Pass through lines containing regexp matches.
//   hubot s /regexp/ "replacement" - Replace regexp matches with the substitution text.
//   hubot loud - WHAT SPEAK UP I CAN'T HEAR YOU
//   hubot quiet - shhhhhh
//   hubot devnull - File complaints here
//
// Author:
//   smashwilson

function parseDelimited(delimiter, text) {
  let escaped = false;

  // Skip initial whitespace.
  let start = text.search(/\S/);
  if (start === -1) {
    start = 0;
  }

  // If the next character is the delimiter character, we'll read a delimited string. Otherwise,
  // we'll read until the next whitespace.
  const isDelimited = text[start] === delimiter;
  if (isDelimited) {
    start += 1;
  }

  for (let i = start; i <= text.length; i++) {
    if (escaped) {
      escaped = false;
      continue;
    }

    const letter = text[i];
    if (letter === "\\") {
      escaped = true;
      continue;
    }

    if (
      (isDelimited && letter === delimiter) ||
      (!isDelimited && letter.match(/\s/))
    ) {
      const next = i + 1;
      return [null, text.slice(start, i), text.slice(next)];
    }
  }

  return [new Error(`Unterminated ${delimiter}`), null, null];
}

function parseRegexp(text) {
  try {
    const [err, pattern, left] = parseDelimited("/", text);
    const rx = new RegExp(pattern, "gi");
    return [err, rx, left];
  } catch (e) {
    return [e, null, null];
  }
}

module.exports = function (robot) {
  const inputFrom = (msg) => {
    if (msg.match[1] != null && msg.match[1].trim().length > 0) {
      return msg.match[1];
    } else {
      return robot.mostRecent(msg) || "";
    }
  };

  robot.respond(/match\s*([^]*)/im, function (resp) {
    let [err, rx, left] = parseRegexp(m);
    if (err != null) {
      resp.send(err.message);
      return;
    }

    if (left.trim().length === 0) {
      left = robot.mostRecent(resp);
    }

    const results = left.match(rx);
    if (results == null) {
      return;
    }
    return results.map((result) => resp.send(result));
  });

  robot.respond(/grep ([^]*)/im, function (resp) {
    let [err, rx, left] = parseRegexp(resp.match[1]);
    if (err != null) {
      resp.send(err.message);
      return;
    }

    if (left.trim().length === 0) {
      left = robot.mostRecent(resp);
    }

    left = left.replace(/^\s*/, "");

    for (const line of left.split(/\n/)) {
      if (line.search(rx) !== -1) {
        resp.send(line);
      }
    }
  });

  robot.respond(/s ([^]*)/im, function (resp) {
    let replacement;
    let [err, rx, left] = parseRegexp(resp.match[1]);
    if (err != null) {
      resp.send(err.message);
      return;
    }

    [err, replacement, left] = parseDelimited('"', left);
    if (err != null) {
      resp.send(err.message);
      return;
    }

    if (left.trim().length === 0) {
      left = robot.mostRecent(resp);
    }

    left = left.replace(/^\s*/, "");

    left = left.replace(rx, replacement);
    return resp.send(left);
  });

  robot.respond(/loud\s*([^]*)/im, (resp) =>
    resp.send(inputFrom(resp).toUpperCase())
  );

  robot.respond(/quiet\s*([^]*)/im, (resp) =>
    resp.send(inputFrom(resp).toLowerCase())
  );
};

// Fun fact: devnull doesn't even need to exist
