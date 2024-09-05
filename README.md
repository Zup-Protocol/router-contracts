## ⚡️⚡️⚡️ Router Contracts

This repository contains the Router Contracts for the **Zup Protocol**.

Router Contracts are all contracts used to deposit into liquidity pools from other DEXes.

## Getting Started

### Dependencies
- **Git**
  - To know if Git is installed, run `git --version` you should see a response like `git version x.x.x`.
  - If Git is not installed, head over to [Installing Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

- **Foundry**

  - To know if Foundry is installed, run `forge --version` you should see a response like `forge x.x.x`.
  - If Foundry is not installed, head over to [Foundry Installation](https://book.getfoundry.sh/getting-started/installation)

- **Node.js**

  - To know if Node.js is installed, run `node --version` you should see a response like `vX.X.X`.
  - If Node.js is not installed, head over to [How to install Node.js](https://nodejs.org/en/learn/getting-started/how-to-install-nodejs)

- **Yarn**

  - To know if Yarn is installed, run `yarn --version` you should see a response like `yarn x.x.x`.
  - If Yarn is not installed, head over to [Yarn installation](https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable)

### Installation
1. Clone the repository
2. Run `yarn` to install all the dependencies. It will also install forge libraries.
3. Nothing more! All done ⚡️

### Running Tests
To run all the tests, just open your terminal and type:
```bash 
yarn test
```

it will run the unit, fuzz and fork tests.

It’s not recommended to run it every time you want to test something specific, as it will also run the fork tests, which take a lot of time. Instead you can just run the tests you want to test using `forge test --mt {TEST_NAME}`. If you want to run a specific group of tests, you can use the commands below:

To run only the unit tests:
```bash
yarn testunit
```

To run only the Fuzz tests:
```bash
yarn testfuzz
```

To run only the Fork tests:
```bash
yarn testfork
```

## Committing
- Every commit should follow the [Conventional Commits](https://www.conventionalcommits.org) format (`<type>[optional scope]: <description>`). In other case, the commit will be rejected

- Commits to the main branch are not allowed by default. Pull requests should be opened and then merged into the main branch
