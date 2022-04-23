## ETH 配置平台设计

## 1. 基础链配置

两个合约链: 数据合约+可重复配置升级的合约

1. 数据合约: 类似 TOS, 只提供 get 和 put 两个接口, 开放给另一个合约<br>

- save: <key, value>
  - 接受一个 json 格式的数据,
  - 多媒体格式: base64 转码，一般数据:json 化<br>
- get: 通过 key 来获取 value

2. 配置合约: 提供智能合约模板 + json 配置平台(或填写表单), 转化为智能合约代码, 连接到数据链，接口提供给用户（如有余力再做, 这个难度较大）

## 2. 平台基础结构

1. 基础功能
   - 通过前台启动和测试基础区块链(涉及到容器操作,可能相当耗时)
   - 通过前台配置智能合约并部署到区块链上
   - 实现一个数据展示平台, 查看区块链数据（区块链浏览器）
   - 通过设计，提供 token 的形式让用户能够利用自己的智能合约部署区块链应用
2. 技术栈
   1. 前端 react+nextjs (开发中)
   2. 后台 nodejs/Go （nodejs）
   3. 节点的数据发现采用 redis 发布订阅 （已完成）
   4. 链的部署采用 websocket(web3.js)/json RPC (已完成)
   1. 监控采用 Grafana? （否掉, 不现实）
3. 注意点
   1. 由于需要发行 token 等 payable 方法, 客户一般不会成为节点, 需要写一个自己的钱包(暂时可能用不着, 我认为部署者和用户都应该在我们的集群上使用服务, 因此都可以访问我们的节点集群, 因此不需要编写为每个应用额外的钱包, 使用我们的api即可)

#### 区块链搭建和初始化配置

使用 docker + genesis.json 来搭建

#### 基础模板

<li>基础合约：get + put 键值对 (put应该提供许多元信息, 时间戳, 哈希值, 上传人等)</li>
<li>增强合约：聚合查询, 统计, 定时任务
       数据库合约: 建立数据模型, 设置CURD方法, 数据权限（+ 账户合约）</li>
<li>账户合约: 指定数据空间, 管理员账户,验证账户, 设置账户, 配置账户权限, 生成账户</li>
<li>展示合约: 查看区块链上情况（包装基础api）</li>
<li>代币合约: 指定发代币数量, 单位，交易手续费等</li>

#### 组合示例

存证: 账户合约 + 提取并检查数据, 上传数据(基础合约的包装)
投票: 账户合约 + 增强合约

非合约相关接口

1. 申请成为节点 + 矿工, 直接加入以太坊网络
2. 申请新的以太币（应对交易费用不足的情况）
3. 参与应用的用户管理，应用状态管理

## 3. 进度目标

- [x] 搭建 Docker geth 集群(3x 虚拟节点)
- [x] 开发一个 master 主机，用来调用 docker 方法启动 docker 集群，监控 docker 内部的情况 + 查看以太坊运行情况
- [x] 为各个 nodejs 服务器开发 ethereum mangenment api 接口,  使其具备基本能力
- [ ] 使用 Compose 完成自动化部署，启用 consul 做服务发现和高可用集群
- [x] 使用 nodejs 编写 Docker api
- [x] 编写基础智能合约，测试后部署到集群
- [ ] 编写高层逻辑, 测试后封装成模板方法, 合约上链
- [x] 使用 egg 编写配置平台 api
- [ ] 编写前端交互逻辑

## 4. 文件结构

```
主目录结构
.
├── Readme.md
├── contracts                     目前的简单智能合约文件
│   ├── Basic.sol
│   └── DataStore.sol             目前的数据合约, 包含简单权限设置
├── data
├── dump.rdb
├── genesis                       当需要用puppeth自定义POA创世区块文件时，可以在这里执行
│   ├── eth_chain-harmony.json
│   └── eth_chain.json
├── images                        基础的以太坊镜像(已弃用)
│   └── BaseEthereum
├── master                        主目录
│   ├── backEnd                   暂未使用 
│   └── frontEnd                  主目录
└── production
    └── docker-compose.yml        生产环境下的docker-compose文件, 当需要部署的时候将这个文件复制到frontEnd中覆盖掉其中的docker-compose文件


主目录内部结构 /master/frontEnd

主目录控制台是一个在express服务器上运行的nextjs程序，
要启动起来, 请按以下步骤进行
1. 先安装最新稳定版的nodejs, 并在该目录下运行npm install
2. 将之前提到的production目录下的docker-compose.yml粘贴到此文件夹下, 覆盖原来的
3. 在命令行下输入 yarn dev-serverless
4. 打开localhost:3000 查看页面是否加载完毕
.
├── apis.js         一些调用docker api的方法
├── components      
├── config
├── docker-compose.yml      docker编排文件，需要被覆盖
├── next.config.js
├── node_master      主节点的对外服务器, 对外暴露端口7001, 可以通过http://127.0.0.1:7001访问(速度较慢, 启动完成后大约需要等待1分钟)
├── node_modules
├── node_slaver      子节点的对外服务器, 对外界没有暴露端口
├── package-lock.json
├── package.json
├── pages
├── server
├── server.js        控制台服务器的启动程序
├── start.sh
├── test.css
├── yarn-error.log
└── yarn.lock

```

## 5.容器配置

- 2x 以太坊节点(包含 egg 后端)
- 1x nginx 静态资源服务器 (用于静态资源映射和压缩等）
- 1x go api 服务器, 用于管理 docker 和以太坊节点 (否掉，时间不够)
- 1x redis 服务器, 用于提供数据存储服务
- 1x nodejs 静态资源服务器, 用于提供服务端渲染的静态资源


## 6.clone项目后的使用方法
1. 下载docker并安装
2. docker pull tomokokawase/node_master 
3. docker pull tomokokawase/node_slaver （这两部分会耗时较久, 建议挂vpn, 在公司内网等网速快的地方拉取）
4. 安装docker-compose, 麻烦参照一下官网的教程
5. 按照之前所说的进入master/fronted执行一系列操作
6. localhost启动之后, 现在可以
   1. 点击部署, 暂停和移除来对以太坊集群做相应操作
   2. 点击下发，向以太坊集群内部下发智能合约文件(未编译)
   3. 在postman中通过post请求访问http://127.0.0.1/deployContract 参数写name:已经下发的智能合约的名字（不带sol扩展名）来编译部署智能合约
   4. 可以在命令行中, 使用docker ps -a, docker stats 查看进程和内存, cpu消耗, 通过docker logs [容器哈希] -f 持续查看容器输出
   
