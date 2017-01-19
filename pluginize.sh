set -ex
plugin="$1"
TMPDIR=$(mktemp -d rexray.tmp.XXXXX)
image=$(cat Dockerfile | docker build -q -)
docker create --name rexray "$image"
mkdir -p $TMPDIR/rootfs
docker export -o $TMPDIR/rexray.tar rexray
docker rm -vf rexray
( cd $TMPDIR/rootfs && tar xf ../rexray.tar )
cat <<EOF > $TMPDIR/config.json
{
      "Args": {
        "Description": "",
        "Name": "",
        "Settable": null,
        "Value": null
      },
      "Description": "A rexray volume plugin for Docker",
      "Documentation": "https://docs.docker.com/engine/extend/plugins/",
      "Entrypoint": [
        "/usr/bin/rexray", "service", "start", "-f"
      ],
      "Env": [
        {
          "Description": "",
          "Name": "REXRAY_SERVICE",
          "Settable": [
            "value"
          ],
          "Value": "ebs"
        },
        {
          "Description": "",
          "Name": "EBS_ACCESSKEY",
          "Settable": [
            "value"
          ],
          "Value": ""
        },
        {
          "Description": "",
          "Name": "EBS_SECRETKEY",
          "Settable": [
            "value"
          ],
          "Value": ""
        }
      ],
      "Interface": {
        "Socket": "rexray.sock",
        "Types": [
          "docker.volumedriver/1.0"
        ]
      },
      "Linux": {
        "AllowAllDevices": true,
        "Capabilities": ["CAP_SYS_ADMIN"],
        "Devices": null
      },
      "Mounts": [
        {
          "Source": "/dev",
          "Destination": "/dev",
          "Type": "bind",
          "Options": ["rbind"]
        }
      ],
      "Network": {
        "Type": "host"
      },
      "PropagatedMount": "/var/lib/libstorage/volumes",
      "User": {},
      "WorkDir": ""
}
EOF
docker plugin create "$plugin" "$TMPDIR"
rm -rf "$TMPDIR"
