import {
    AccountHttp,
    Address,
    Asset,
    AssetHttp,
    Block,
    BlockHeight,
    BlockHttp,
    ChainHttp,
    Transaction
} from "nem-library";

export class NisApi {
    static async getBlockHeight(): Promise<BlockHeight> {
        const chainHttp = new ChainHttp();
        return chainHttp.getBlockchainHeight().toPromise();
    }

    static async getBlockByHeight(height: BlockHeight): Promise<Block> {
        const blockHttp = new BlockHttp();
        return blockHttp.getBlockByHeight(height).toPromise();
    }

    static async getBlocksInRange(startHeight: BlockHeight, endHeight: BlockHeight): Promise<Block[]> {
        const tasks = Array.from(Array(1 + endHeight - startHeight).keys())
            .map(value => value + startHeight )
            .map( height => this.getBlockByHeight(height));

        return Promise.all(tasks);
    }

    static async getIncomingTransactions(address: Address, id: number = undefined): Promise<Transaction[]> {
        const accountHttp = new AccountHttp();
        if (id) {
            return accountHttp.incomingTransactions(address, {id: id}).toPromise();
        } else {
            return accountHttp.incomingTransactions(address).toPromise();
        }

    }

    static async getAssetDivisibility(asset: Asset): Promise<number>{
        const assetHttp = new AssetHttp();
        const assetDefinition = await assetHttp.getAssetDefinition(asset.assetId).toPromise();
        return assetDefinition.properties.divisibility;
    }
}

