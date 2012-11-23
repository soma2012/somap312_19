eval(global.ty());

var server;

var api = {
    'account-register': function(arg, cb) {
        async.waterfall([
            function(cb) {
                /* check arguments */

                if(arg.accesstoken)
                {
                    account.auth(arg.accesstoken, function(uid) {
                        if(uid) {
                            account.get(uid, function(usr) {
                                cb({
                                    state: 0,
                                    uid: uid,
                                    passkey: usr.passkey
                                });
                            });
                        }
                        else {
                            cb(null);
                        }
                    });
                }
                else cb(null);
            },

            function(cb) {
                /* register account */

                account.register(function(uid, passkey) {
                    cb(null, uid, passkey);
                });
            },

            function(uid, passkey, cb) {
                /* link facebook */

                if(!arg.accesstoken)
                    cb(null, uid, passkey);
                else
                    account.facebook.link(uid, arg.accesstoken, function(err) {
                        if(err)
                            cb(err);
                        else
                            cb(null, uid, passkey);
                    });
            }
        ],

        function(err, uid, passkey) {
            if(err)
            {
                cb(err);
            }
            else
            {
                cb({
                    state: 0,
                    uid: uid,
                    passkey: passkey
                });
            } 
        });
    },

    'account-linked-facebook': function(arg, cb) {

    },

    'account-auth': function(arg, cb) {
        function _cb(uid) {
            if(uid)
            {
                account.session.make(uid, function(sid) {
                    cb({
                        state: 0,
                        sessid: sid
                    });

                    if(arg.devicetoken) {
                        account.session.update(sid, {
                            devicetoken: arg.devicetoken
                        });
                    }
                });
            }
            else
                cb({
                    state: 1,
                    msg: 'LOGIN FAILED'
                });
        }

        if(arg.uid)
            account.auth(arg.uid, arg.psk, _cb);
        else if(arg.accesstoken)
            account.auth(arg.accesstoken, _cb);
    },

    'account-profile-get': function(arg, cb) {
        if(!arg._uid)
        {
            cb({
                state: 1,
                msg: 'SESSION DOES NOT EXIST'
            });

            return;
        }

        account.get(arg._uid, function(usr) {
            if(usr)
            {
                if(!arg.fields)
                    arg.fields = 'nick,email,picture';

                var fields = arg.fields.split(',');
                var results = {state: 0};
                
                for(var i in fields)
                {
                    switch(fields[i])
                    {
                    case 'nick':
                        results.nick = usr.nick;
                        break;
                    case 'picture':
                        results.picture = usr.pictureurl;
                        break;
                    case 'email':
                        results.email = usr.email;
                        break;
                    }
                }

                cb(results);
            }
            else
                cb({
                    state: 1,
                    msg: 'ACCOUNT ERROR'
                });
        });
    },

    'account-profile-set': function(arg, cb) {
        if(!arg._uid)
        {
            cb({
                state: 1,
                msg: 'SESSION DOES NOT EXIST'
            });

            return;
        }

        var changes = {};
        var uid = arg._uid;

        for(var i in arg)
        {
            switch(i)
            {
            case 'nick':
            case 'email':
                changes[i] = arg[i];
                break;
            case 'picture':
                var dataBuffer = new Buffer(arg[i], 'base64');

                require("fs").writeFile('./pictures/' + uid + '.jpg', dataBuffer);

                changes.pictureurl = 'http://bicy.kr/pictures/' + uid + '.jpg';
                break;
            }
        }

        account.update(uid, changes);

        cb({
            state: 0
        });
    },

    'account-friend-list': function(arg, cb) {
        if(!arg._uid)
        {
            cb({
                state: 1,
                msg: 'SESSION DOES NOT EXIST'
            });

            return;
        }

        async.waterfall([
            function(cb) {
                account.friend.facebook(arg._uid, function(res) {
                    cb(null, res);
                });
            },

            function(res, cb) {
                account.get(res, function(res) {
                    var results = [];

                    for(var i in res)
                    {
                        results.push({
                            uid: res[i].uid,
                            nick: res[i].nick,
                            picture: res[i].pictureurl
                        });
                    }

                    cb(null, results);
                });
            }
        ],

        function(err, results) {
            cb({
                state: 0,
                friends: results
            });
        });
    },

    'race-create': function(arg, cb) {
        async.waterfall([
            function(cb) {
                if(arg._usr.raceno == 0)
                    cb(null);
                else
                    cb(true);
            },

            function(cb) {
                race.create(arg._uid, function(no) {
                    if(no)
                        cb(null, {
                            state: 0,
                            no: no
                        });
                    else
                        cb(true);
                });
            }
        ],

        function(err, results) {
            if(err)
                cb({
                    state: 1,
                    msg: 'ALREADY RACE'
                });
            else
                cb(results);
        });
    },

    'race-invite': function(arg, cb) {
        var raceNo;

        async.waterfall([
            function(cb) {
                if(arg._usr.raceno == 0) { // 레이스에 참가중이 아니다?
                    race.create(arg._uid, function(no) {
                        if(no) {
                            arg._usr.raceno = no;
                            cb(null);
                        }
                        else
                            cb({
                                state: 1,
                                msg: 'RACE CREATE RROR'
                            });
                    });
                }
                else {
                    cb(null);
                }
            },

            function(cb) {
                race.invite(arg._uid, arg._usr.raceno, arg.targets, function(err) {
                    if(err)
                        cb({
                            state: 1,
                            msg: err
                        });
                    else
                        cb({
                            state: 0
                        });
                });
            }
        ],

        function(res) {
            cb(res);
        });
    },

    'race-join': function(arg, cb) {
        race.join(arg._uid, arg.no, function(err) {
            if(err)
                cb({
                    state: 1,
                    msg: err
                });
            else
                cb({
                    state: 0
                });
        });
    },

    'race-end': function(arg, cb) {
        if(arg._usr.raceno == 0) {
            cb({
                state: 1,
                msg: 'RACE NOT JOINED'
            });

            return;
        }

        race.end(arg._uid, arg._usr.raceno, function(err) {
            if(err)
                cb({
                    state: 1,
                    msg: err
                });
            else
                cb({
                    state: 0
                });
        });
    },

    'race-info': function(arg, cb) {
        if(arg._usr.raceno == 0) {
            cb({
                state: 1,
                msg: 'RACE NOT JOINED'
            });

            return;
        }
        else {
            async.waterfall([
                function(cb) {
                    race.participant(arg._usr.raceno, function(res) {
                        for(var i in res)
                            if(res[i] == arg._uid)
                                delete res[i];

                        cb(null, res);
                    });
                },

                function(res, cb) {
                    account.get(res, function(res) {
                        var results = [];

                        for(var i in res)
                        {
                            results.push({
                                uid: res[i].uid,
                                nick: res[i].nick,
                                picture: res[i].pictureurl
                            });
                        }

                        cb(null, results);
                    });
                }
            ],

            function(err, result) {
                cb({
                    state: 0,
                    participants: result
                });
            });
        }
    },

    'race-summary': function(arg, cb) {
        if(arg._usr.raceno == 0) {
            cb({
                state: 1,
                msg: 'RACE NOT JOINED'
            });

            return;
        }

        var metadata, funcs;

        async.parallel({
            metadata: function(cb) {
                race.metadata(arg._uid, arg._usr.raceno, function(metadata) {
                    cb(null, metadata);
                });
            },

            participant: function(cb) {
                race.participant(arg._usr.raceno, function(participant) {
                    cb(null, participant);
                });
            }
        },

        function(err, results) {
            funcs = [];
            metadata = results.metadata;

            for(var i in results.participant)
            {
                if(results.participant[i] != arg._uid)
                {
                    (function(uid){
                        funcs.push(function(cb) {
                            if("undefined" == typeof metadata.last) metadata.last = {};
                            if("undefined" == typeof metadata.last[uid]) metadata.last[uid] = 0;

                            async.waterfall([
                                function(cb) {
                                    race.record.length(uid, arg._usr.raceno, function(length) {
                                        if(length > metadata.last[uid])
                                            cb(null, length);
                                        else
                                            cb(true);
                                    });
                                },

                                function(length, cb) {
                                    race.record.range(uid, arg._usr.raceno, metadata.last[uid], length, function(res) {
                                        cb(null, res);
                                    });

                                    metadata.last[uid] = length;
                                }
                            ],

                            function(err, results) {
                                if(err)
                                    cb(null);
                                else
                                    cb(null, {
                                        uid: uid,
                                        pos: results
                                    });
                            });
                        });
                    })(results.participant[i]);
                }
            }

            async.parallel(funcs, function(err, res) {
                var result = [];

                for(var i in res)
                    if(res[i])
                        result.push(res[i]);

                cb({
                    state: 0,
                    summary: result
                });

                race.metadata(arg._uid, arg._usr.raceno, metadata);
            });
        });
    },

    'race-record': function(arg, cb) {
        race.record.push(arg._uid, arg._usr.raceno, arg.pos);

        cb({
            state: 0
        });
    },

    'cache-clear': function(arg, cb) {
        db.redis.keys('cache.*', function(err, res) {
            for(var i in res)
                db.redis.del(res[i]);
        });

        cb({
            state: 0
        });
    },

    'push-test': function(arg, cb) {
        //4d304e8d 06bd4e37 c1640b89 741c8705 619ebad1 95cddc2f 0b13b049 5f57d67c
        var device = apns.device('4d304e8d06bd4e37c1640b89741c8705619ebad195cddc2f0b13b0495f57d67c');
        
        setInterval(function(){
        apns.notification(device, {
            alert: '우하하하하하하',
            payload: {'messageFrom': 'Caroline'}
        });
    }, 1000)

        cb({
            state: 0,
            devicetoken: device.token.toString('base64')
        })
    },

    'race-clear': function(arg, cb) {
        db.mysql.query("TRUNCATE TABLE  `race`");
        db.mysql.query("TRUNCATE TABLE  `race_participant`");
        db.mysql.query("UPDATE `account` SET `raceno` = '0'");
        api['cache-clear'](arg, function(){});
        db.redis.keys('race.*', function(err, res) {
            for(var i in res)
                db.redis.del(res[i]);
        });

        cb({
            state: 0
        });
    }
};

ty(function() {
    console.log('API Initialize');

    var app = express();

    function apiCall(name, arg, cb) {
        function call() {
            api[name](arg, function(result) {
                cb(result);
            });
        }

        for(var i in arg)
            if(i.substr(0, 1) == '_')
                delete arg[i];

        if(arg.sid)
        {
            account.session.get(arg.sid, function(usr) {
                if(usr == null)
                    cb({
                        state: 1,
                        msg: 'SESSION DOES NOT EXISTs'
                    });
                else
                {
                    arg._uid = usr.uid;
                    arg._usr = usr;
                    call();
                }
            });
        }
        else call();
    }

    app.use(express.bodyParser());

    app.use(function(req, res, next) {
        res.header('Content-Type', 'application/json');
        next();
    });

    app.get('/', function(req, res) {
        res.send('this page is api');
    });

    app.post('/', function(req, res) {
        var parse = req.body;

        if(isArray(parse))
        {
            var results = Array();
            var resCount = 0;

            for(var i in parse)
            {
                if(i == 0 && !("type" in parse[i]))
                {
                    for(var j in parse)
                        for(var k in parse[i])
                            parse[j][k] = parse[i][k];

                    results[i] = {state: 0};
                }

                (function(i){
                    if("type" in parse[i] && "function" == typeof api[parse[i].type])
                    {
                        apiCall(parse[i].type, parse[i], function(result) {
                            results[i] = result;
                            resCount++;

                            if(resCount == parse.length)
                                res.send(JSON.stringify(results));
                        });
                    }
                    else if(i > 0)
                    {
                        results[i] = {state: 1, msg: 'INVALID TYPE'};
                        resCount++;

                        if(resCount == parse.length)
                            res.send(JSON.stringify(results));
                    }
                })(i);
            }
        }
        else
        {
            var result;

            if("type" in parse && "function" == typeof api[parse.type])
                apiCall(parse.type, parse, function(result) {
                    res.send(result);
                });
            else
                res.send({state: 1, msg: 'INVALID TYPE'});
        }
    });

    app.get('/:type', function(req, res) {
        var type = req.params.type;
        var result;

        if("function" == typeof api[type])
            apiCall(type, {}, function(result) {
                res.send(result);
            });
        else
            res.send({state: 1, msg: 'INVALID TYPE'});
    });

    app.get('/:type/:arg', function(req, res) {
        var type = req.params.type;
        var arg = querystring.parse(req.params.arg);
        var result;

        if("function" == typeof api[type])
            apiCall(type, arg, function(result) {
                res.send(result);
            });
        else
            res.send({state: 1, msg: 'INVALID TYPE'});
    });

    server = http.createServer(app).listen(8080);

    ty('model', api);
})

ty(function() {
    console.log('API Unload..')
    if(server) server.close();
})