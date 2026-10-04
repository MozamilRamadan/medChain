const { ethers } = require("ethers");
require("dotenv").config();

const contractABI = [
    "function addRecord(string memory patientId, string memory ipfsCID) public",

    "function getRecords(string memory patientId) public view returns (tuple(uint256 id, string patientId, string ipfsCID, uint256 timestamp, address doctor)[])"
];

const provider = new ethers.JsonRpcProvider(
    process.env.RPC_URL
);

const wallet = new ethers.Wallet(
    process.env.PRIVATE_KEY,
    provider
);

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

    const records = await contract.getRecords(
        patientId
    );

    return records.map(record => ({
        id: record.id.toString(),
        patientId: record.patientId,
        ipfsCID: record.ipfsCID,
        timestamp: record.timestamp.toString(),
        doctor: record.doctor
    }));
}


module.exports = {
    addRecord,
    getRecords
};