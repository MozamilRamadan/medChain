const { PinataSDK } = require("pinata");
require("dotenv").config();

const pinata = new PinataSDK({
    pinataJwt: process.env.PINATA_JWT,
});


async function uploadRecord(recordData) {

    const result = await pinata.upload.public.json(recordData);

    console.log("Uploaded to IPFS:", result.cid);

    return result.cid;
}


async function testPinata() {

    const result = await pinata.upload.public.json({
        name: "MedChain Test",
        message: "Hello IPFS",
    });

    console.log("CID:", result.cid);

    return result.cid;
}


module.exports = {
    uploadRecord,
    testPinata
};