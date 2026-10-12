#!/bin/bash
set -uo pipefail

read -rp "Enter a service name: " svc    # prompt the user
echo "You chose: $svc"

echo "Script name: $0, argument count: $#, all arguments: $@"

action="${1:-}"
name="${2:-}"


case "$action" in
    status)
        systemctl is-active "$name"
        ;;
    logs)
        journalctl -u "$name" -n 5 --no-pager
        ;;
    "")
        echo "usage: $0 {status|logs} <service>" >&2
        exit 2
        ;;
    *)
        echo "unknown action: $action" >&2
        exit 2
        ;;
esac
