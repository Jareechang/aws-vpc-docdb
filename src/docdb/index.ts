import mongodb from 'mongodb';

interface DBConnectionOptions {
    /*
     * TLS cert
     * */
    ca: string[];
    /*
     * DB port 
     * */
    port: string;
    /*
     * DB endpoint 
     * */
    endpoint: string;
    username: string;
    password: string;
    databaseName: string;
}

class DocumentDBWrapper {
    private client : any = null;
    private databaseName : string = '';

    constructor(databaseName: string) {
        this.databaseName = databaseName;
    }

    public async connect(
        connectionOptions: DBConnectionOptions
    ): Promise<void> {
        const {
            ca,
            port,
            username,
            password,
            endpoint
        } = connectionOptions;
        const client : any = await mongodb.MongoClient.connect(
`mongodb://${username}:${password}@${endpoint}:${port}/${this.databaseName}?ssl=true&replicaSet=rs0&readPreference=secondaryPreferred`, 
            { 
                sslValidate: true,
                sslCA: ca,
                useNewUrlParser: true,
                useUnifiedTopology: true
            }).catch((err: any) => console.log(err));
        this.client = client;
    }

    public async read(
        collection: string,
        query: any
    ): Promise<any> {
        let results : any = null;
        if (!this.client) {
            throw new Error(
                'this.client does not exist, please call connect() with the correct option'
            );
        }
        try {
            results = await this.client
                .db(this.databaseName)
                .collection(collection)
                .find(query)
                .toArray();
        } catch (ex) {
            console.error(
                `Failed to issue query ${query} on collection ${collection}. error: ${ex} `
            );
        }
        return results;
    }

    public async write(): Promise<boolean> {
        let response = false
        if (!this.client) {
            throw new Error(
                'this.client does not exist, please call connect() with the correct option'
            );
        }
        console.log('write DB....');
        return response;
    }
}

export {DocumentDBWrapper};
