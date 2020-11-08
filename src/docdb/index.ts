//interface ConnectionOptions {}

class DocumentDBWrapper {

    // @ts-ignore
    private connectionOptions : any = null;

    constructor(
        connectionOptions: any 
    ) {
        this.connectionOptions = connectionOptions;
    }

    public async read() {
        console.log('reading DB....');
    }

    public async write() {
        console.log('write DB....');
    }
}

export {DocumentDBWrapper};
