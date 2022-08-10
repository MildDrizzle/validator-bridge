// const abiDecoder = require("abi-decoder");
import abiDecoder from "abi-decoder"
import { ABI } from "./constants";

const initDecoder = () => abiDecoder.addABI(ABI);

const decodeData = data => abiDecoder.decodeMethod(data);
// const testData =
//   "0x5ae401dc0000000000000000000000000000000000000000000000000000000062f29071000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000000e4472b43f3000000000000000000000000000000000000003eb17e57ff809dd7463f3700000000000000000000000000000000000000000000000000000742d8b2378373ac000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000002000000000000000000000000cc1c0fbaecf0fe1c4703d77ec284cdf8a06253c5000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004449404b7c0000000000000000000000000000000000000000000000000742d8b2378373ac0000000000000000000000001b833bf1a0094a941a208bf8799f93998625d54300000000000000000000000000000000000000000000000000000000";
// const decodedData = abiDecoder.decodeMethod(testData);
// console.log(decodedData);


export {initDecoder, decodeData}