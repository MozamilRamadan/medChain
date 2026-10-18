
const { ethers } = require("ethers");
require("dotenv").config();

const contractABI = [
    "function addRecord(string patientId, string ipfsCID)",
    "function getRecords(string patientId) view returns (tuple(uint256 id, string patientId, string ipfsCID, uint256 timestamp, address addedBy)[])"
];

console.log(">>> blockchainService.js LOADED");

const rpcUrl = process.env.RPC_URL;
const privateKey = process.env.PRIVATE_KEY;
const contractAddress = process.env.CONTRACT_ADDRESS;

if (!rpcUrl || !privateKey || !contractAddress) {
    throw new Error(
        "Missing RPC_URL, PRIVATE_KEY, or CONTRACT_ADDRESS in backend/.env"
    );
}

if (!ethers.isAddress(contractAddress)) {
    throw new Error("Invalid CONTRACT_ADDRESS in backend/.env");
}

const provider = new ethers.JsonRpcProvider(rpcUrl);
const wallet = new ethers.Wallet(privateKey, provider);

console.log("Local blockchain wallet:", wallet.address);
console.log("MedChain contract:", contractAddress);

const contract = new ethers.Contract(
    contractAddress,
    contractABI,
    wallet
);

async function addRecord(patientId, ipfsCID) {
    const transaction = await contract.addRecord(
        patientId,
        ipfsCID
    );

    const receipt = await transaction.wait();

    if (!receipt || receipt.status !== 1) {
        throw new Error("MedChain blockchain transaction failed");
    }

    console.log("Blockchain transaction confirmed:", receipt.hash);

    return receipt.hash;
}

async function getRecords(patientId) {
    console.log("Contract:", contractAddress);
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
