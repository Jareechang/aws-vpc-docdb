import mongodb from 'mongodb';
import {DocumentDBWrapper} from './docdb';

async function run() {
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
}

run();
