<img align="right" width="150" height="150" top="100" src="./assets/readme.jpg">

# Athens • [![ci](https://github.com/abigger87/Athens/actions/workflows/ci.yml/badge.svg)](https://github.com/abigger87/Athens/actions/workflows/ci.yml) ![license](https://img.shields.io/github/license/abigger87/Athens?label=license) ![solidity](https://img.shields.io/badge/solidity-^0.8.15-lightgrey)

## What is Athens

When paired with the Athens Aztec Bridge, it will enable any users of existing protocols with on chain governance (Currently limited to forks of Governor Bravo) to vote on proposals anonymously through the power of Aztec's DefiBatching technology.

This project was created by sleep deprivation as part of the EthBerlin 2022 Hackathon and is not in anyway shape or form ready for production use.

Hackathon Bridge Implementation can be [found here](https://github.com/cheethas/aztec-connect-bridges/blob/cheethas/compoundGov/src/bridges/GovernorBravo/GovernorBravoBridgeContract.sol)

Generated from [femplate](https://github.com/abigger87/femplate)

## Blueprint

```ml
lib
├─ forge-std — https://github.com/foundry-rs/forge-std
├─ solmate — https://github.com/Rari-Capital/solmate
├─ openzeppelin - https://github.com/OpenZeppelin/openzeppelin-contracts
scripts
├─ Deploy.s — Simple Deployment Script
├─ CreateProxy.s - Example to Create a Proxy
src
├─ AthensFactory — A Factory Contract to Manage and Deploy Voter Proxies and ZKVoter Tokens
├─ AthensVoter - A Minimal Clone Contract to Hold and Cast Anonymous Votes
├─ AthensVoterTokenERC20 - A Minimal Clone ERC20 Token representing a ZKVoter Token
├─ interfaces
|   ├─ AthensFactoryInterface
|   ├─ AthensVoterInterface
|   └─ GovernorBravoDelegateInterface
```

## Development

**Setup**

```bash
forge install
```

**Building**

```bash
forge build
```

**Testing**

```bash
forge test
```

**Deployment & Verification**

Inside the [`utils/`](./utils/) directory are a few preconfigured scripts that can be used to deploy and verify contracts.

Scripts take inputs from the cli, using silent mode to hide any sensitive information.

_NOTE: These scripts are required to be \_executable_ meaning they must be made executable by running `chmod +x ./utils/*`.\_

_NOTE: these scripts will prompt you for the contract name and deployed addresses (when verifying). Also, they use the `-i` flag on `forge` to ask for your private key for deployment. This uses silent mode which keeps your private key from being printed to the console (and visible in logs)._

### First time with Forge/Foundry?

See the official Foundry installation [instructions](https://github.com/foundry-rs/foundry/blob/master/README.md#installation).

Then, install the [foundry](https://github.com/foundry-rs/foundry) toolchain installer (`foundryup`) with:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Now that you've installed the `foundryup` binary,
anytime you need to get the latest `forge` or `cast` binaries,
you can run `foundryup`.

So, simply execute:

```bash
foundryup
```

🎉 Foundry is installed! 🎉

### Writing Tests with Foundry

With [Foundry](https://github.com/foundry-rs/foundry), all tests are written in Solidity! 🥳

Create a test file for your contract in the `test/` directory.

For example, [`src/Greeter.sol`](./src/Greeter.sol) has its test file defined in [`./test/Greeter.t.sol`](./test/Greeter.t.sol).

To learn more about writing tests in Solidity for Foundry, reference Rari Capital's [solmate](https://github.com/Rari-Capital/solmate/tree/main/src/test) repository created by [@transmissions11](https://twitter.com/transmissions11).

### Configure Foundry

Using [foundry.toml](./foundry.toml), Foundry is easily configurable.

For a full list of configuration options, see the Foundry [configuration documentation](https://github.com/foundry-rs/foundry/blob/master/config/README.md#all-options).

## License

[AGPL-3.0-only](https://github.com/abigger87/Athens/blob/master/LICENSE)

## Acknowledgements

- [femplate](https://github.com/abigger87/femplate)
- [foundry](https://github.com/foundry-rs/foundry)
- [solmate](https://github.com/Rari-Capital/solmate)
- [forge-std](https://github.com/brockelmore/forge-std)
- [forge-template](https://github.com/foundry-rs/forge-template)
- [foundry-toolchain](https://github.com/foundry-rs/foundry-toolchain)

## Disclaimer

_These smart contracts are being provided as is. No guarantee, representation or warranty is being made, express or implied, as to the safety or correctness of the user interface or the smart contracts. They have not been audited and as such there can be no assurance they will work as intended, and users may experience delays, failures, errors, omissions, loss of transmitted information or loss of funds. The creators are not liable for any of the foregoing. Users should proceed with caution and use at their own risk._
