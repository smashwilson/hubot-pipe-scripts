const fs = require('fs');
const path = require('path');

module.exports = function(robot, scripts) {
  const scriptsPath = path.resolve(__dirname, 'src');
  const scriptSet = new Set(scripts);

  return fs.exists(scriptsPath, function(exists) {
    if (!exists) {
      return;
    }

    for (const script of fs.readdirSync(scriptsPath)) {
      if (scriptSet.size > 0 && !scriptSet.has('*')) {
        if (scriptSet.has(script)) {
          robot.loadFile(scriptsPath, script);
        }
      } else {
        robot.loadFile(scriptsPath, script);
      }
    }
  });
};
