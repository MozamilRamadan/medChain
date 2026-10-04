// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MedChain {

    struct MedicalRecord {
        uint256 id;
        string patientId;
        string ipfsCID;
        uint256 timestamp;
        address addedBy;
    }

    uint256 private recordCounter;

    mapping(string => MedicalRecord[]) private patientRecords;

    event RecordAdded(
        uint256 id,
        string patientId,
        string ipfsCID,
        uint256 timestamp,
        address addedBy
    );

    function addRecord(
        string memory patientId,
        string memory ipfsCID
    ) public {
        recordCounter++;

        MedicalRecord memory newRecord = MedicalRecord({
            id: recordCounter,
            patientId: patientId,
            ipfsCID: ipfsCID,
            timestamp: block.timestamp,
            addedBy: msg.sender
        });

        patientRecords[patientId].push(newRecord);

        emit RecordAdded(
            recordCounter,
            patientId,
            ipfsCID,
            block.timestamp,
            msg.sender
        );
    }

    function getRecords(
        string memory patientId
    ) public view returns (MedicalRecord[] memory) {
        return patientRecords[patientId];
    }
}