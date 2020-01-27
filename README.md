# homebus-tasmota-dimmer

This is a simple HomeBus data source which publishes weather conditions from AirNow

[Tasmota API docs](https://tasmota.github.io/docs/#/Commands)

## Usage

On its first run, `homebus-tasmota-dimmer` needs to know how to find the HomeBus provisioning server.

```
bundle exec homebus-tasmota-dimmer -b homebus-server-IP-or-domain-name -P homebus-server-port
```

The port will usually be 80 (its default value).

Once it's provisioned it stores its provisioning information in `.env.provisioning`.

`homebus-tasmota-dimmer` also needs to know:

- the URL of the dimmer switch


