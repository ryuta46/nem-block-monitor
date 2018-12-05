import {Decimal} from 'decimal.js'
import {Asset, AssetHttp, Block, BlockHeight, BlockHttp, ChainHttp} from "nem-library";

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


    static async getAmount(asset: Asset): Promise<Decimal>{
        const divisibility = await this.getAssetDivisibility(asset);
        return getDivided(asset.quantity, divisibility);
    }

    private static async getAssetDivisibility(asset: Asset): Promise<number>{
        // TODO: Load cache
        const assetHttp = new AssetHttp();
        const assetDefinition = await assetHttp.getAssetDefinition(asset.assetId).toPromise();
        return assetDefinition.properties.divisibility;
    }
}

function getDivided(value: number, divisibility: number): Decimal {
    return new Decimal(value).div(10 ** divisibility);
}
