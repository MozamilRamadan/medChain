const { ethers } = require("ethers");
require("dotenv").config();

const contractABI = [
    "function addRecord(string patientId, string ipfsCID)",

    "function getRecords(string patientId) view returns (tuple(uint256 id, string patientId, string ipfsCID, uint256 timestamp, address addedBy)[])"
];
console.log(">>> blockchainService.js LOADED");
const provider = new ethers.JsonRpcProvider(
    process.env.RPC_URL
);

const wallet = new ethers.Wallet(
    process.env.PRIVATE_KEY,
    provider,
);

console.log("Blockchain wallet:++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
console.log("Blockchain wallet:", wallet.address);

const contract = new ethers.Contract(
    process.env.CONTRACT_ADDRESS,
    contractABI,
    wallet
);


async function addRecord(patientId, ipfsCID) {

    const transaction = await contract.addRecord(
        patientId,
        ipfsCID
    );

    const receipt = await transaction.wait();

    return receipt.hash;
}


async function getRecords(patientId) {

    console.log("Contract:", process.env.CONTRACT_ADDRESS);
    console.log("Patient ID:", patientId);

    const records = await contract.getRecords(patientId);

    return records.map(record => ({
        id: record.id.toString(),
        patientId: record.patientId,
        ipfsCID: record.ipfsCID,
        timestamp: record.timestamp.toString(),
        addedBy: record.addedBy
    }));
}


module.exports = {
    addRecord,
    getRecords
};