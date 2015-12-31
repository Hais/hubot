var async = require('async');
var VError = require('verror');
var shellOut = require('./shell-out');
var util = require('util');
var fs = require('fs');

var creds = 'ss-deploybot:d3cac58d1e65fe3fbef00deb4a81ee90121425d7';
var repo = 'socialsuperstore/infrastructure';
var workingCopy = '/tmp/' + repo;

function cloneRepo(cb) {
    if (!fs.existsSync(workingCopy)) {
        var cmd = util.format('git clone https://%s@github.com/%s %s', creds, repo, workingCopy);
        shellOut(cmd, {}, function (err) {
            if (err) {
                return cb(new VError(err, 'Error cloning %s git repo', repo));
            } else {
                return cb();
            }
        });
    } else {
        return cb();
    }
}

function updateRepo(cb) {
    var cmd = 'git fetch origin master && git reset --hard origin/master';
    shellOut(cmd, {
        cwd: workingCopy
    }, function (err, stdout, stderr) {
        if (err) {
            return cb(new VError(err, 'Error updating %s git repo', repo));
        } else {
            return cb();
        }
    });
}

function ensureUpToDate(cb) {
    async.waterfall([
        cloneRepo,
        updateRepo
    ], function (err) {
        if (err) {
            return cb(err);
        } else {
            return cb();
        }
    });
}

module.exports = {
    ensureUpToDate: ensureUpToDate,
    workingCopy: workingCopy,
    creds: creds
};
