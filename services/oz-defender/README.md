# Open Zepplelin Defender

[OZ-Defender](https://docs.openzeppelin.com/defender/) makes handling contract calls easier and more scalable than managing our own relay contracts. For now this is used in place of a bundler for 4337 user operations.

This folder is used to store the code used in autotasks, and also contains scripts to test and update the autotasks.

<br/>

# Autotasks

This folder contains the code which will be executed in our [autotasks](https://docs.openzeppelin.com/defender/autotasks).

## Scripts

### Test

These scripts can be used to test calls of the autotaks. Create a test payload in `test/data` and run from project root with:

```
yarn relay
```

### Update

Used to push updates from the autotasks folder to defender.

To build the code which will be updloaded to Defender run the following from project root:

```
yarn webpack --env=TASK_NAME=relay-user-op
yarn ts-node services/oz-defender/autotasks/scripts/update/update-relay-user-op.ts
```
