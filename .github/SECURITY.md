# Security Policy

## Supported Versions

Security fixes are applied to the latest released version of MSK GiveVehicle.
Please make sure you are running the most recent
[release](https://github.com/MSK-Scripts/msk_givevehicle/releases) before
reporting an issue.

| Version | Supported |
|---------|-----------|
| Latest release | Yes |
| Older versions | No |

## Reporting a Vulnerability

Please do not report security vulnerabilities through public GitHub issues,
pull requests, or the public Discord channels.

Instead, report them privately using one of these channels:

* **Email:** moritz.kohm@gmail.com
* **Discord:** send a direct message to the maintainer on the
  [MSK Scripts Discord](https://discord.gg/5hHSBRHvJE)

When reporting, please include as much of the following as you can:

* A description of the vulnerability and its impact
* Steps to reproduce, or a proof of concept
* The affected version of MSK GiveVehicle
* Your setup: ESX version, msk_core version, and whether `msk_garage` or a
  vehicle-key script is in use
* Whether the issue is reachable without admin rights, for example through a
  client event or an NUI callback

Vehicle spawning and deletion are privileged actions, so reports about missing
permission checks, event exploits or SQL injection in the vehicle browser are
especially welcome.

## What to Expect

* We will acknowledge your report as soon as possible.
* We will investigate and keep you updated on the progress.
* Once a fix is ready, we will release it and credit you if you wish.

Please give us a reasonable amount of time to address the issue before any
public disclosure. Thank you for helping keep MSK GiveVehicle and its users safe.
