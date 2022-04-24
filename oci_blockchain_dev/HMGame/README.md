# Develop Hangman Game using Oracle Block Chain App Builder
# Environment Setup


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
