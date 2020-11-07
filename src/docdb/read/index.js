const MongoClient = require('mongodb').MongoClient;
const f = require('util').format;
const fs = require('fs');
const path = require('path');

//Specify the Amazon DocumentDB cert
const ca = [
    fs.readFileSync(path.resolve(__dirname, "../../", "rds-combined-ca-bundle.pem"))
];
const databaseName = 'test';
const collectionName = 'info';

exports.handler = async function(event, context) {
    //Create a MongoDB client, open a connection to Amazon DocumentDB as a replica set, 
    //  and specify the read preference as secondary preferred
    var client = await MongoClient.connect(
`mongodb://${process.env.db_user}:${process.env.db_password}@dev.cluster-cuiedb1khzug.us-east-1.docdb.amazonaws.com:27017/${databaseName}?ssl=true&replicaSet=rs0&readPreference=secondaryPreferred`, 
        { 
            sslValidate: true,
            sslCA:ca,
            useNewUrlParser: true,
            useUnifiedTopology: true
        }).catch(err => console.log(err));

    console.log('Starting db connection...');
    try { 

        //Specify the database to be used
        let db = client.db(databaseName);

        //Specify the collection to be used

        const results = await db.collection(collectionName).find({}).toArray();

        console.log('result: ', results);

    } catch (ex) {
        console.error('DB execution failed: ', ex);
    }

}


