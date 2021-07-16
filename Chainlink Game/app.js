const Web3 = require('Web3')
const Abi = require('./erc20abi.json')
randomAbi = require('./randomABI.json')

const provider = 'https://speedy-nodes-nyc.moralis.io/a89a5e99c977f7e095a47958/eth/kovan';
web3 = new Web3(provider);
//get some variables to use in contract creation

const gasPrice = 20000000000;
let gasLimit = 500000;

//create ETH account object from private key and add it to wallet
const account =  web3.eth.accounts.privateKeyToAccount('583a8292d5bd243bc84b43c9d07c65125c06e0f746faa03d7c8fd40ccb705173');
web3.eth.accounts.wallet.add(account);

//construct instance of link token contract
const link = new web3.eth.Contract(Abi, '0xa36085F69e2889c224210F603D836748e7dC0088', {
	from: account.address,
	gasPrice: gasPrice,
	gas: gasLimit,
});

const getLinkBalance = (addy)=>{
	link.methods.balanceOf(addy).call().then((res)=>{
		console.log(res.toString());
	})
}

const game = new web3.eth.Contract(randomAbi, '0xE2B4227DC3015A6e205B348fc7650D8f15b40CD9', {
	from: account.address,
	gasPrice: gasPrice,
	gas: gasLimit,
});

let getRandomNumber = game.methods.getRandomNumber().send().then(console.log);