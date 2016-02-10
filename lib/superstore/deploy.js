var git = require('./git');
var shellOut = require('./shell-out');
var VError = require('verror');
var _ = require('lodash');
var request = require('request');
var async = require('async');
var util = require('util');
var exec = require('child_process').exec;

function lookupCommit(opts, cb) {
    var baseUrl = util.format('https://%s@api.github.com', git.creds);
    var repo = 'socialsuperstore/superstore'
    var version = opts.version;

    var url = util.format('%s/repos/%s/commits/%s', baseUrl, repo, version)
    request({
        url: url,
        json: true,
        headers: {
            'User-Agent': 'hubot'
        }
    }, function (err, res, body) {
        if (err) {
            return cb(new VError(
                err, 'Error looking up superstore version "%s"', version));
        }

        if (res.statusCode === 404) {
            return cb(new VError('Superstore version "%s" not found', version));
        }

        if (res.statusCode !== 200) {
            return cb(new VError(
                'Got %s when looking up superstore version "%s"',
                res.statusCode, version));
        }

        return cb(null, body);
    });
}

function assertImageExists(repo, tag, cb) {
    var quayToken = 'YFYS5pev3w4NUutjO4oi3TUxZoHoVGhfHPjVqdUs';
    var url = util.format(
        'https://quay.io/api/v1/repository/%s/tag/%s/images',
        repo, tag);

    request({
        url: url,
        json: true,
        headers: {
            'Authorization': 'Bearer ' + quayToken
        }
    }, function (err, res, body) {
        if (err) { return cb(err); }
        if (res.statusCode !== 200) {
            return cb(new VError('Could not find docker image %s:%s', repo, tag));
        }

        return cb();
    });
}

function assertImagesExist(opts, commitDetails, cb) {
    var calls = _.map(opts.apps, function (s) {
        var repo = 'socialsuperstore/superstore-' + s;
        var tag = commitDetails.sha.slice(0, 7);
        return assertImageExists.bind(null, repo, tag);
    })

    return async.waterfall(calls, function (err) {
        if (err) { return cb(err); }

        return cb(null, commitDetails);
    });
}

function deployCmd(cmd, opts, commitDetails, cb) {
    var envVars = {
        SUPPRESS_INFO: 't',
        SHA: commitDetails.sha.slice(0, 7),
        APPS: (opts.apps || []).join(','),
        ENV: opts.env || ''
    };

    shellOut('./deploy/' + cmd, {
        env: _.extend({}, process.env, envVars),
        cwd: git.workingCopy
    }, function (err, stdout, stderr) {
        if (err) {
            return cb(new VError(err, 'Error running %s', cmd))
        } else {
            return cb(null, {
                commitDetails: commitDetails,
                stdout: stdout,
                stderr: stderr
            });
        }
    });
}

function buildUrls(opts) {
    var darkStr = opts.isDark ? '-dark' : '';

    return _.transform(opts.apps, function (acc, s) {
        if (s === 'app') {
            if (opts.env == 'live') {
                if (opts.isDark) {
                    acc[s] = 'https://dark.socialsuperstore.com';
                } else {
                    acc[s] = 'https://socialsuperstore.com';
                }
            } else {
                if (opts.isDark) {
                    acc[s] = util.format('https://%s-dark.socialsuperstore.com', opts.env);
                } else {
                    acc[s] = util.format('https://%s.socialsuperstore.com', opts.env);
                }
            }
        } else {
            if (opts.env == 'live') {
                if (opts.isDark) {
                    acc[s] = util.format('https://%s-dark.socialsuperstore.com', s);
                } else {
                    acc[s] = util.format('https://%s.socialsuperstore.com', s);
                }
            } else {
                if (opts.isDark) {
                    acc[s] = util.format('https://%s-%s-dark.socialsuperstore.com', opts.env, s);
                } else {
                    acc[s] = util.format('https://%s-%s.socialsuperstore.com', opts.env, s);
                }
            }
        }
    }, {});
}

function createRC(opts, cb) {
    async.waterfall([
        git.ensureUpToDate,
        lookupCommit.bind(null, opts),
        assertImagesExist.bind(null, opts),
        deployCmd.bind(null, 'create-rc', opts)
    ], cb);
}

function deleteRC(opts, cb) {
    async.waterfall([
        git.ensureUpToDate,
        lookupCommit.bind(null, opts),
        deployCmd.bind(null, 'delete-rc', opts)
    ], cb);
}

function migrateDB(opts, cb) {
    async.waterfall([
        git.ensureUpToDate,
        lookupCommit.bind(null, opts),
        deployCmd.bind(null, 'migrate-db', opts)
    ], cb);
}

function pointDark(opts, cb) {
    async.waterfall([
        git.ensureUpToDate,
        lookupCommit.bind(null, opts),
        deployCmd.bind(null, 'point-dark', opts)
    ], function (err, res) {
        if(err) { return cb(err); }

        opts.isDark = true;
        var result = {
            commitDetails: res.commitDetails,
            urls: buildUrls(opts)
        };

        cb(null, result);
    });
}

function pointLight(opts, cb) {
    async.waterfall([
        git.ensureUpToDate,
        lookupCommit.bind(null, opts),
        deployCmd.bind(null, 'point-light', opts)
    ], function (err, res) {
        if(err) { return cb(err); }

        opts.isDark = false;
        var result = {
            commitDetails: res.commitDetails,
            urls: buildUrls(opts)
        };

        cb(null, result);
    })
}

function kubectl(env, clusters, args, cb) {
    async.waterfall([
        git.ensureUpToDate
    ], function (err, res) {
        if (err) { return cb(err); }

        shellOut('./deploy/kube-wrapper ' + args + ' | column -t -c 80', {
            env: _.extend({}, process.env, {
                SUPPRESS_INFO: 't',
                ENV: env || '',
                CLUSTERS: (clusters.join(",")) || 'a1,b1'
            }),
            cwd: git.workingCopy
        }, function (err, stdout, stderr) {
            if (err) {
                return cb(err, stderr);
            }

            return cb(null, stdout, stderr);
        });
    });
}

module.exports = {
    createRC: createRC,
    deleteRC: deleteRC,
    pointDark: pointDark,
    pointLight: pointLight,
    kubectl: kubectl,
    migrateDB: migrateDB
};
