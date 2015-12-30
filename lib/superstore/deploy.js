var git = require('./git');
var shellOut = require('./shell-out');
var VError = require('verror');
var _ = require('lodash');

function deployCmd(cmd, opts, cb) {
    git.ensureUpToDate(function (err) {
        if (err) {
            return cb(err);
        }

        var envVars = {
            SHA: opts.sha || '',
            SERVICES: opts.services.replace(/ /g, '') || '',
            ENV: opts.env || ''
        };

        shellOut('./deploy/' + cmd, {
            env: _.extend(process.env, envVars),
            cwd: git.workingCopy
        }, function (err) {
            if (err) {
                return cb(new VError(err, 'Error running %s', cmd))
            } else {
                return cb();
            }
        });
    });
}

module.exports = {
    deployCmd: deployCmd
};
