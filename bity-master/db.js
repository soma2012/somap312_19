eval(global.ty());

ty(function() {
    var redisStore = redis.createClient(config.redis.port, config.redis.host);
    ty('redis', redisStore);

    var mysqlClient = mysql.createConnection({
        host     : config.mysql.host,
        user     : config.mysql.user,
        password : config.mysql.password
    });
    mysqlClient.connect();
    mysqlClient.query('USE ' + config.mysql.database);
    ty('mysql', mysqlClient);
});