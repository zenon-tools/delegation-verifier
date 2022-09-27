# Delegation Verifier
A service that manages Pillar delegator access to special features on various platforms. Currently supports [Rocket Chat](https://www.rocket.chat), managing delegator access to a delegators-only private chat.

The service uses a Zenon node to validate delegation status in real-time.

## Building from source

## Running as a system service
It is advisable to run the service as a system service that automatically restarts the service if it experiences an unexpected crash.

Example systemd service configuration to use where the service's output is logged to //:

## Rocket Chat setup

### Create a private channel
A private channel for delegators has to be set up. The channel's name is set in the Delegation Verifier's `config.yaml` file. This will be the private chat that users will be added to/removed from based on their delegation status.

### Set a minimum delegation weight
A minimum delegation weight in ZNN has to be set in the `config.yaml` file. This is the minimum delegation weight a user must have to access the private chat.

### Set up credentials for the Delegation Verifier service
The Delegation Verifier needs Rocket Chat user credentials with **admin privileges and with all 2FA features disabled** for said user. The credentials are set in the `config.yaml` file.

### Set custom fields for user address & signature information
The Delegation Verifier reads the user's address and signature information from the user's Rocket Chat profile. The user profile's must be configured with custom fields for the user's delegation address, public key, signed message and signature information. The custom fields are configured from `Administration > Settings > Accounts`.

The following values should be used.

For the setting `Custom Fields to Show in User Info`:

```json
[{"Delegation Address": "address"}, {"Public Key": "pubkey"}, {"Signed Message": "message"}, {"Signature": "signature"}]
```

For the setting `Registration > Custom Fields`:

```json
{
	"Delegation Address": {
		"type": "text",
		"required": false,
		"minLength": 2,
		"maxLength": 80,
		"private": true
	},
        "Public Key": {
		"type": "text",
		"required": false,
		"minLength": 2,
		"maxLength": 80,
		"private": true
	},
	"Signed Message": {
		"type": "select",
		"defaultValue": "Acta Non Verba",
		"options": ["Acta Non Verba", "Independent Entity", "Network of Momentum"],
		"required": false,
		"private": true
	},
	"Signature": {
		"type": "text",
		"required": false,
		"minLength": 2,
		"maxLength": 200,
		"private": true
	}
}
```
