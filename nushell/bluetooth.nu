alias bt = bluetoothctl
alias btscan = bt scan on

def list-bt-devices [] {
    bt devices | lines | each {|device|
        let parts = (echo $device | split row ' ')
        echo ($parts | skip 2 | str join) "[" ($parts | get 1) "]" |
            str join
    }
}

def get-mac-from-device-name [device: string] {
    echo $device | split row '[' | get 1 | split row ']' | get 0
}

def btconnect [device: string@list-bt-devices] {
    bt connect (get-mac-from-device-name $device)
}

def btdisconnect [device: string@list-bt-devices] {
    bt disconnect (get-mac-from-device-name $device)
}

def btpair [device: string@list-bt-devices] {
    bt pair (get-mac-from-device-name $device)
}

def btremove [device: string@list-bt-devices] {
    bt remove (get-mac-from-device-name $device)
}
