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
    const documentDBWrapper : any = new DocumentDBWrapper(
        databaseName
    );

    try {
        await documentDBWrapper.connect({
            ca,
            port: '27017',
            endpoint: process.env.DB_ENDPOINT,
            username: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
        });
    } catch (ex) {
        console.error(
            'Failed to connect documentDB, error: ',
            ex.message
        );
        throw ex;
    }

    let results = null;
    switch (operation) {
        case 'read':
            results = await documentDBWrapper.read(collectionName, {});
            break;
        case 'insert':
            const currentData = new Date();
            results = await documentDBWrapper.insert({
                data: {
                    currentDate
                }
            });
            break;
        default:
            console.log(
                `No Operation provided, please set process.env.DB_OPERATION.`
            );
    }
    console.log('Results: ', results);
}
