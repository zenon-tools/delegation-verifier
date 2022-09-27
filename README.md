# Delegation Verifier
A service that manages Pillar delegator access to special features on various platforms. Currently supports [Rocket Chat](https://www.rocket.chat), managing delegator access to a delegators-only private chat. The delegation status of chat users is verified every five minutes.

The service uses a websocket connection to a Zenon node to validate delegation status in real-time.

## Building from source
The Dart SDK is required to build the server from source (https://dart.dev/get-dart). Use the Dart SDK to install the dependencies and compile the program by running the following commands:
```
dart pub get
dart compile exe bin/main.dart
```

If not on Windows remove the .exe file extension from the compiled file.

## Running as a system service (Linux)
It is advisable to run the service as a system service that automatically restarts the service if it experiences an unexpected crash.

Example systemd service configuration to use where the service's output is logged to `/var/log/delegation-verifier.log`. The Delegation Verifier binary file is assumed to be located at `/root/delegation-verifier/bin`:
```
[Unit]
Description=Delegation Verifier
Wants=network-online.target
After=network-online.target

[Service]
Restart=on-failure
RestartSec=5
ExecStart=/bin/bash -c 'exec ./main &>> /var/log/delegation-verifier.log'
WorkingDirectory=/root/delegation-verifier/bin

[Install]
WantedBy=multi-user.target
```

# Rocket Chat setup

Make a copy of the `example.config.yaml` file and rename it as `config.yaml`. This is the configuration file for the Delegation Verifier. This file must be located in the same folder as the Delegation Verifier binary.

### Create a private channel
A private channel for delegators has to be set up on Rocket Chat. The channel's name is set to the Delegation Verifier's `config.yaml` file. This will be the private chat that users will be added to/removed from based on their delegation status.

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
