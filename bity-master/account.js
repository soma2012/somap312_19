eval(global.ty());

/*

Account Object Reference

account.get(uid, callback) - 해당 uid의 정보를 데이터베이스에 요청하여 가져옴
account.update(uid, changes) - 해당 uid의 정보를 업데이트
account.register(argument, callback) - 계정 만들기

facebook
  account.facebook.link(argument, callback) - 페이스북과 계정 연동
  account.facebook.friend(argument, callback) - 페이스북에서 친구 목록 가져옴
  account.facebook.picture(uid, accesstoken, callback) - 페이스북에서 사진 가져옴

session
  account.session.get(sid, callback) - 세션 아이디에서 uid를 얻어옴
  account.session.make(uid, callback) - uid가 담긴 세션을 만듬
  account.session.auth(uid, passkey, callback) - uid, passkey가 유효한지 확인한다
  account.session.facebook(accesstoken, callback) - 페이스북에 해당 계정과 연동된 uid를 반환한

*/

ty('get', function(uid, cb) {
    var uids;
    if(!isArray(uid)) uids = [uid];
    else uids = uid;

    var results = [];
    var fails = [];
    var funcs = [];

    for(var i in uids)    
        (function(i){
            funcs.push(function(cb) {
                db.redis.get('cache.account.' + uids[i], function(err, data) {
                    if(data)
                    {
                        results.push(JSON.parse(data));
                        cb(null);
                    }
                    else
                    {
                        fails.push(uids[i]);
                        cb(null);
                    }
                });
            });
        })(i);

    async.parallel(funcs, function(err, res) {
        if(fails.length > 0)
        {
            db.mysql.query(
                "SELECT * FROM `account` WHERE `uid` IN (" + fails.join() +")",
                function(err, res, fields) {
                    if(res)
                    {
                        for(var i in res)
                        {
                            results.push(res[i]);
                            db.redis.set('cache.account.' + res[i].uid, JSON.stringify(res[i]));
                        }
                        cb(isArray(uid)?results:results[0]);
                    }
                    else
                        cb(null);
                }
            );
        }
        else cb(isArray(uid)?results:results[0]);
    });
});

ty('update', function(uid, changes) {
    var sets = '';

    for(var i in changes)
        sets+= ', `' + i + '` = \'' + changes[i] + '\'';

    sets = sets.substr(1);

    db.mysql.query(
        "UPDATE `account` SET" + sets + " WHERE `uid` = ?",
        [uid]
    );

    db.redis.del('cache.account.' + uid);
});

ty('register', function(cb) {
    var md5 = crypto.createHash('md5');
    md5.update((new Date).getTime().toString());
    md5.update(Math.random().toString());
    md5.update(Math.random().toString());
    md5.update(Math.random().toString());

    var passkey = md5.digest('hex');

    db.mysql.query(
        "INSERT INTO `account` SET passkey = ?",
        [passkey]
    );

    db.mysql.query("SELECT LAST_INSERT_ID() AS `uid`", function(err, results, fields) {
        cb(results[0].uid, passkey);
    });
})

ty('auth', function() {
    if(arguments.length == 3)
    { // uid & passkey
        var uid = arguments[0];
        var passkey = arguments[1];
        var cb = arguments[2];

        db.mysql.query(
            "SELECT `uid` FROM `account` WHERE `uid` = ? AND `passkey` = ?",
            [uid, passkey],
            function(err, results, fields) {
                if(results.length > 0)
                    cb(uid);
                else
                    cb(null);
            }
        );
    }
    else if(arguments.length == 2)
    { // facebook
        var accesstoken = arguments[0];
        var cb = arguments[1];

        async.waterfall([
            function(cb) {
                db.mysql.query(
                    "SELECT `uid` FROM `account` WHERE `accesstoken` = ?",
                    [accesstoken],
                    function(err, results, fields) {
                        if(results.length > 0)
                            cb(null, results[0].uid);
                        else
                            cb(null, 0);
                    }
                );
            },

            function(uid, cb) {
                if(uid)
                    cb(null, uid);
                else
                    fb.api('me', {access_token: accesstoken, fields: ['id']}, function(res) {
                        if(res.id)
                        {
                            db.mysql.query(
                                "SELECT `uid` FROM `account` WHERE `fbid` = ?",
                                [res.id],
                                function(err, results, fields) {
                                    if(results.length > 0)
                                        cb(null, results[0].uid);
                                    else
                                        cb(null);
                                }
                            );
                        }
                    });
            }
        ],

        function(err, uid) {
            if(err)
                cb(null);
            else
                cb(uid);
        });
    }
});

ty('friend', {
    facebook: function(uid, cb) {
        db.mysql.query(
            "SELECT `account`.`uid` FROM `fb_friends` " +
            "INNER JOIN `account` ON (`fb_friends`.`fbid` = `account`.`fbid`) " +
            "WHERE `fb_friends`.`uid` = ? ",
            [uid],
            function(err, results, fields) {
                if(results)
                {
                    var res = [];
                    for(var i in results)
                        res.push(results[i].uid);
                    cb(res);
                }
                else cb(null);
            }
        );
    }
});

ty('session', {
    get: function(sid, cb) {
        db.redis.get('session:' + sid, function(err, data) {
            if(data)
            {
                var parse = JSON.parse(data);
                account.get(parse.uid, function(usr) {
                    cb(usr);
                });
            }
            else
            {
                cb(null);
            }
        });
    },

    update: function(sid, updates) {
        db.redis.get('session:' + sid, function(err, data) {
            if(data)
            {
                var parse = JSON.parse(data);
                for(var i in updates) {
                    parse[i] = updates[i];
                }
                db.redis.set('session:' + sid, JSON.stringify(parse));
            }
            else
            {
                cb(null);
            }
        });
    },

    make: function(uid, cb) {
        function makeSessionId()
        {
            var md5 = crypto.createHash('md5');
            md5.update((new Date).getTime().toString());
            md5.update(Math.random().toString());
            md5.update(Math.random().toString());
            md5.update(Math.random().toString());

            var sid = md5.digest('hex');

            db.redis.get('session:' + sid, function(err, data) {
                if(data == null)
                {
                    cb(sid);

                    db.redis.set('session:' + sid, JSON.stringify({
                        uid: uid
                    }));
                }
                else
                    makeSessionId();
            });
        }

        makeSessionId();
    }
});

ty('facebook', {
    link: function(uid, accesstoken, cb) {
        async.waterfall([
            function(cb) {
                /* check account */

                db.mysql.query(
                    "SELECT `accesstoken` FROM `account` WHERE `uid` = ?",
                    [uid],
                    function(err, results, fields) {
                        if(results.length != 1)
                            cb(true);
                        else if(results[0].facebook == 1)
                            cb(true);
                        else
                            cb(null);
                    }
                );
            },

            function(cb) {
                /* get facebook data */

                fb.api('me', {access_token: accesstoken, fields: ['id', 'name', 'email', 'picture', 'updated_time']}, function(res) {
                    cb(null, res);

                    account.facebook.friend(uid, accesstoken);
                    account.facebook.picture(uid, accesstoken);
                });

            },

            function(data, cb) {
                account.update(uid, {
                    fbid: data.id,
                    accesstoken: accesstoken,
                    nick: data.name,
                    email: data.email
                });

                cb(null);
            }
        ],

        function(err) {
            cb(null);
        });
    },

    friend: function(uid, accesstoken, cb) {
        fb.api('me/friends', {access_token: accesstoken}, function(res) {
            db.mysql.query(
                "DELETE FROM `fb_friends` WHERE `uid` = ?",
                [uid]
            );

            var values = '';
            for(var i in res.data)
                values+= ",('" + uid + "','" + res.data[i].id + "')";
            values = values.substr(1);

            db.mysql.query(
                "INSERT INTO `fb_friends` (`uid`, `fbid`) VALUES " + values
            );
        });
    },

    picture: function(uid, accesstoken, cb) {
        var filename = uid;
        var url  = 'https://graph.facebook.com/me/picture?type=large&access_token=' + accesstoken;
        var path = './pictures/' + filename + '.jpg';
        var uploadUrl = 'http://bicy.kr/pictures/' + filename + '.jpg';

        request(url).pipe(fs.createWriteStream(path));

        account.update(uid, {
            pictureurl: uploadUrl
        });
    }
});