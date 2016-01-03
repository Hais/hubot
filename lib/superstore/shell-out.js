var exec = require('child_process').exec;

function runCmd(cmdStr, opts, cb) {
    var runningCmd = exec(cmdStr, opts, function (err, stdout, stderr) {
        if (err) {
            process.stderr.write(stdout);
            process.stderr.write(stderr);
            return cb(err);
        } else {
            return cb(null, {
                stdout: stdout,
                stderr: stderr
            });
        }
    });

    //commented out to stop spamming hubot logs,
    //- may be useful to uncomment if debugging
    //
    //runningCmd.stdout.pipe(process.stdout);
    //runningCmd.stderr.pipe(process.stderr);
}

module.exports = runCmd;
