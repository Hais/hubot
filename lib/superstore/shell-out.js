var exec = require('child_process').exec;

function runCmd(cmdStr, opts, cb) {
    var runningCmd = exec(cmdStr, opts, function (err) {
        if (err) {
            return cb(err);
        } else {
            return cb();
        }
    });

    runningCmd.stdout.pipe(process.stdout);
    runningCmd.stderr.pipe(process.stderr);
}

module.exports = runCmd;
