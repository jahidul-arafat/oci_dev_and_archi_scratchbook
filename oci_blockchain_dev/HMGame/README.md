# Develop Hangman Game using Oracle Block Chain App Builder
## Step-01: Environment Setup
### 1.1 VSCode


## Troubleshooting-01: Specification was failing to correctly generate the Chaincode
```bash
# My Go 
> which go 
/usr/local/go/bin/go

> whereis go
go: /usr/local/go/bin/go

> echo $GOPATH
/Users/jarotball/go

# All the goroot packages are in /usr/local/go/src and /usr/local/go/pkg

# All my custom go packages are in /Users/jarotball/go/src and /Users/jarotball/pkg

```


### Problems 01: Chaincode scaffolding from specification file couldn't automatically resolve the required go packages. Following packages require manual installation
- [x] github.com/hyperledger/fabric-protos-go
  - [x] peer
- [x] github.com/hyperledger/fabric-chaincode-go
  - [x] shim
  - [x] shimtext
- [x] github.com/creasty/defaults
- [ ] gopkg.in/validator.v2

#### How to Resolve this problem ?
Ref: https://github.com/sap-tutorials/Tutorials/issues/4415?tdsourcetag=s_pctim_aiomsg
``` bash
# Solution 01
> cd /Users/jarotball/go/src
> mkdir github.com
> cd github.com
> go mod init chaincode     # this will generate a go.mod file; this is mandatory
> go mod tidy
> go get github.com/hyperledger/fabric-chaincode-go/shim@latest
> go get github.com/hyperledger/fabric-protos-go/peer@latest
> go get github.com/creasty/defaults@latest
> go get gopkg.in/validator.v2

# Note. All these packages will be installed on $HOME/go/pkg/mod


# Solution 02: Manually creating a github.com package and clone the repective github repos and install them
> cd /Users/jarotball/go/src
> mkdir github.com
> cd github.com
> go mod init chaincode     # this will generate a go.mod file; this is mandatory
> go mod tidy

> mkdir hyperledger
> cd hyperledger
> git clone git@github.com:hyperledger/fabric-chaincode-go.git
> cd fabric-chaincode-go    # look for go.mod and go.sum files 
> go get ./shim
> go get ./shimtest

> git clone git@github.com/hyperledger/fabric-protos-go.git
> cd fabric-protos-go       # look for go.mod and go.sum files
> go get ./peer

> cd ../..

> pwd
> mkdir creasty
> cd creasty
> git clone git@github.com:creasty/defaults.git

> cd ../..
> pwd
> mkdir gopkg.in
> cd gopkg.in
> git clone git@github.com:go-validator/validator.git
> mv validator validator.v2   # look for go.mod and go.sum files; go.sum is no there in the git repo; so while coding you might have some warning; ignore those. This will not affect your deployment in Oracle BlockChain Cloud Platform.


#** Node: shimtest will be deprecated soon.

```





# Simulation with OBP at VSCode


# Simulation with POSTMAN Restful API
VSCode is pretty much doing the same thing, but hiding the mechanis of interaction from you to simplify the invocation and testing process. 
## 01. Get the REST API Version
```bash
Method: Get
URL: https://founder99403602-ocuocictrng30-phx.blockchain.ocp.oraclecloud.com:7443/restproxy/api/version
Authorization: Basic Auth

Response:
{
    "returnCode": "Success",
    "error": "",
    "result": "v2.0.0"
}

```

## 02. Using ChainCode queries
Note: ChainCode queries doesnt store anything in the ledge, means the transactions are not committed by the Peers but Endorsed (Validated by Peers)
```bash
A.
Method: POST
URL: https://founder99403602-ocuocictrng30-phx.blockchain.ocp.oraclecloud.com:7443/restproxy/api/v2/channels/hmgamechannel001/chaincode-queries
Authorization: Basic Auth
Body: raw
{
    "chaincode": "HMGameChainCode",
    "args": ["MakeAGuess", "jahid", "l"]
}

Note: This will not make any commit as we are using queries instead of actual transaction. So Nothing is stored even if the "character matched".

B. Verify that nothing has commited by the Peers as we have make queries instead of actual transactions. So BlockChain Ledge in the BlockChain Channel/Network has not stored anything
Method: Post
URL: https://founder99403602-ocuocictrng30-phx.blockchain.ocp.oraclecloud.com:7443/restproxy/api/v2/channels/hmgamechannel001/chaincode-queries
Authorization: Basic Auth
Body: raw
{
    "chaincode": "HMGameChainCode",
    "args": ["TheGameHistoryById", "TheGame"]
}

# In the response, you will see that character 'l' is not stored in the ladge


```

## 03. Using ChainCode Transactions - Async
Actual Transaction which is stories into the ledge means commit by the Peers.
```bash
Method: POST
URL: https://founder99403602-ocuocictrng30-phx.blockchain.ocp.oraclecloud.com:7443/restproxy/api/v2/channels/hmgamechannel001/transactions
Authorization: Basic Auth
Body: raw
{
    "chaincode": "HMGameChainCode",
    "args": ["MakeAGuess", "jahid","l"]
}

# This will only return the transaction id, not whats inside into the transaction. To See what's inside the transaction, try below

Method: GET
URL: https://founder99403602-ocuocictrng30-phx.blockchain.ocp.oraclecloud.com:7443/restproxy/api/v2/channels/hmgamechannel001/transactions/da7a61b3e4f1ea5cd83a5053691e473b1891d13519d1b8f4df801bb021b826cf
Authorization: Basic Auth
Body: raw
{
    "returnCode": "Success",
    "error": "",
    "result": {
        "txid": "da7a61b3e4f1ea5cd83a5053691e473b1891d13519d1b8f4df801bb021b826cf",
        "status": "valid",
        "payload": "Character was already guessed a**mal",
        "encode": "JSON"
    }
}

# If you want the endorsement process to be triggered, use the transactions url and you will get back the transaction ID and then with that transaction ID, you can query the status of the transaction at a later point. 

# We dont want endoresement to be instantinious. It may take some time because nodes(peers) have to come to the agreement. Hence our Block Chain Network or channel is simple having only two nodes or peers, the consunsus might not be lengthy. 

# But image a larger network having lots of nodes. This may take certain time before they achieve endorsement. Thats why transaction is make to be async, so we get the transaction ID and it dont have to wait for the actual transcation contents which we may query later. 
```


