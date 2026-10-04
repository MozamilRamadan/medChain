console.log("TEST STARTED");

const { addRecord } = require("./services/blockchainService");

console.log("Service loaded");

addRecord(
    "PATIENT001",
    "bafkreiaxwgskjmjwst22vnougne5hvusgizaiyqbtxuvqonjs26nfvgexa"
)
    .then((txHash) => {
        console.log("Transaction Hash:", txHash);
    })
    .catch((error) => {
        console.error("ERROR:", error);
    });