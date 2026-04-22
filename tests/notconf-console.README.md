# notconf-console cheatsheet

## Start

```bash
./scripts/start-netconf-console.sh
```

## Attach

```bash
kubectl --context=minikube -n notconf exec -it deployment/notconf-console -- bash
```

## Get config

```bash
netconf-console2 --host=notconf.notconf.svc.cluster.local --port=830 --get-config
```

### Edit config

```bash
cat <<EOF | netconf-console2 --host=notconf.notconf.svc.cluster.local --port=830 --edit-config -
<configure xmlns="urn:nokia.com:sros:ns:yang:sr:conf">
  <service>
    <customer>
        <customer-id>1</customer-id>
        <customer-name>1</customer-name>
        <description>984844561</description>
    </customer>
  </service>
</configure>
EOF
```