let records = [];
let recordCounter = 0;

async function addRecord(patientId, ipfsCID) {
    recordCounter++;

    const record = {
        id: recordCounter.toString(),
        patientId: patientId,
        ipfsCID: ipfsCID,
        timestamp: Math.floor(Date.now() / 1000).toString(),
        addedBy: "0xMOCK_ADDRESS"
    };

    records.push(record);

    console.log("Mock blockchain record added:");
    console.log(record);

    return `mock-tx-${recordCounter}`;
}

async function getRecords(patientId) {
    return records.filter(
        record => record.patientId === patientId
    );
}

module.exports = {
    addRecord,
    getRecords
};
