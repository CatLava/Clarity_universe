# Overview: 
This is a contract written in Clarity meant to be deployed on the STX blockchain. The contract premise is allowing two players to gamble on a pot. The players enter a set amount into the contract along with a randomization number. The randomization numbers goes through a random function where pending even or odd, the winner receives complete pot along with the ability to mint a NFT. The premise is adding a bit of fun to minting an NFT. For instance, a project can mint a winner and loser nft that is comprised of different art work. 

## Contracts: 
There are three contracts associated with the files.
1. gambling contract which is the main contracts
2. nft contract - this is primarily built from the Stacks docs here: https://docs.syvita.org/write-smart-contracts/nft-tutorial. There were minor modifications for this contracts
3. SIP-009 stand in contract for testing.

### Additional info
The entirety of the contracts are written in the STX smart contract language Clarity. The testing was done with Clarinet only. These contracts have not been verified on testnet or mainnet.

#### Issues
The nft portion requires further development to limit the amount of calls along with security testing of the contract. The nft was put in as a proof of concept.

#### Acknowledgments:
Clarity Universe contributors and the entire Hiro/Stacks team. Couldn't do it without the below docs.
https://book.clarity-lang.org/title-page.html
https://docs.stacks.co/references/language-functions
