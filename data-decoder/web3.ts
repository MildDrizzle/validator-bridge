import Web3 from "web3";
import { AbiItem } from 'web3-utils'

import { CONTRACT_ADDRESS, BYTE_CODE } from "./constants";
import Abi from './abi.json'

let web3, contract;
const initContract = async () => {
   web3 = new Web3(
    new Web3.providers.HttpProvider("http://localhost:7545")
  );
  // Contract object
  contract = new web3.eth.Contract(Abi as  AbiItem[]);
  

  
};
export { initContract };
