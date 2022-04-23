pragma solidity >=0.4.22 <0.6.0;
pragma experimental ABIEncoderV2;
contract DataStore {
    // 所有命名空间的总表
    mapping (bytes32 => dataStore) public dataTable;
    // 每一个命名空间都是一个结构体
    struct dataStore {
        mapping (bytes32 => dataMsg) dataList;
        address creator;
        uint256 createTime;
        mapping (address => priority) managers;
        bool isPrivate;
        bool isSetup;
    }
    // 消息可以携带元数据
    struct dataMsg {
        string dataDetail;
        address creator;
        uint256 createTime;
        bool isSetup;
    }
    // 数据存储事件
    event DataSave(address user, bytes32 storeAddr, bytes32 dataTitle, uint256 time);
    // 权限范围
    enum priority { read, write }

    // 创建一个data命名空间
    function createStore(bytes32 identifier, bool isPrivate, address[] memory managers) public {
        dataStore storage unCreatedStore = dataTable[identifier];
        require(
            !unCreatedStore.isSetup,
            "当前命名空间已存在"
        );
        unCreatedStore.creator = msg.sender;
        unCreatedStore.isPrivate = isPrivate;
        unCreatedStore.isSetup = true;
        for (uint i = 0; i < managers.length; i++ ) {
            address manager = managers[i];
            unCreatedStore.managers[manager] = priority.write;
        }
        unCreatedStore.createTime = now;
        dataTable[identifier] = unCreatedStore;
    }
    // 向命名空间中写数据
    function set(bytes32 identifier, address user, bytes32 dataTitle, string memory dataDetail) public returns (bool) {
        dataStore storage Store = dataTable[identifier];
        require(
            msg.sender == user,
            "消息发送者必须是写入者"
        );
        require(
            Store.isSetup,
            "只能向存在的数据表格中表写数据"
        );
        require(
            Store.managers[user] >= priority.write,
            "用户必须具有相应权限"
        );
        require(
            !Store.dataList[dataTitle].isSetup,
            "已经存在重名消息头, 请更换消息头名重试"
        );
        Store.dataList[dataTitle].dataDetail = dataDetail;
        Store.dataList[dataTitle].creator = user;
        Store.dataList[dataTitle].createTime = now;
        Store.dataList[dataTitle].isSetup = true;
                
        emit DataSave(user, identifier, dataTitle, dataTable[identifier].dataList[dataTitle].createTime);
        return true;
    }
    // 从命名空间中读数据
    function get(bytes32 identifier, bytes32 dataTitle) public view returns (dataMsg memory Msg) {
        dataStore storage Store = dataTable[identifier];
        require(
            Store.managers[msg.sender] >= priority.read,
            "用户必须具有相应权限"
        );
        require(
            Store.dataList[dataTitle].isSetup,
            "没有找到查询的数据"
        );
        return dataTable[identifier].dataList[dataTitle];
    }
}