require('ty')

(['apn', 'async', 'express', 'fb', 'querystring', 'redis', 'mysql', 'request'])
(['fs', 'crypto', 'http'])

('config.js')
('db.js')
('account.js')
('api.js')
('apns.js')
('race.js')

('hasOwnProperty', _hasOwnProperty)
('isArray', _isArray)
('dot', _dot)

()


function _hasOwnProperty(obj, name) {
    for(var i in obj)
        if(i == name) return true;
    return false;
}

function _isArray(obj) {
    if(Object.prototype.toString.apply(obj) == '[object Array]')
        return true;
    else
        return false;    
}

function _dot() {
    var res = '';
    for(var i in arguments)
        res+= '.' + arguments[i];
    return res.substr(1);
}