import mongodb from 'mongodb';
//import f from 'util';
import * as fs from 'fs';
import path from 'path';
import {DocumentDBWrapper} from './docdb';

//Specify the Amazon DocumentDB cert
const ca = [
    fs.readFileSync(path.resolve(__dirname, "rds-combined-ca-bundle.pem"))
];

const databaseName = 'test';
const collectionName = 'info';

exports.handler = async function(event: any, context: any) {
    const operation : string = process.env.DB_OPERATION || '';
    const connectionOptions : any = null;
    const documentDBWrapper : any = new DocumentDBWrapper(
        connectionOptions
    );
    switch (operation) {
        case 'read':
            await documentDBWrapper.read();
            break;
        case 'write':
            await documentDBWrapper.write();
            break;
        default:
            console.log(
                `No Operation provided, please set process.env.DB_OPERATION.`
            );
    }
    //Create a MongoDB client, open a connection to Amazon DocumentDB as a replica set, 
    //  and specify the read preference as secondary preferred
    var client : any = await mongodb.MongoClient.connect(
`mongodb://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_ENDPOINT}:27017/${databaseName}?ssl=true&replicaSet=rs0&readPreference=secondaryPreferred`, 
        { 
            sslValidate: true,
            sslCA:ca,
            useNewUrlParser: true,
            useUnifiedTopology: true
        }).catch((err: any) => console.log(err));

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
