{pkgs, ...}: let
  privatekey = "/run/secrets/privatekey";
  vpn-dev = "wg0";
  network-if = "enp1s0";
  port = 51820;
in {
  networking = {
    nat = {
      enable = true;
      externalInterface = network-if;
      internalInterfaces = [vpn-dev];
    };
    firewall = {
      # trustedInterfaces = [vpn-dev];
      allowedUDPPorts = [port];
    };
  };

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = ["10.100.0.1/24"];

      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = port;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o ${network-if} -j MASQUERADE
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o ${network-if} -j MASQUERADE
      '';

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKeyFile = privatekey;

      peers = [
        # List of allowed peers.
        {
          # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
          publicKey = "MbFwLDBj+8YHt9/0pXDI/VgAilmFhTdJ58vmsVYsKWU=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = ["10.100.0.2/32"];
        }
        {
          publicKey = "AxhelI1E7gvjxz2Xff6+VCKF/eEFu0KPToqogwkoVRw=";
          allowedIPs = ["10.100.0.3/32"];
        }
      ];
    };
  };

  sops.secrets.privatekey = {
    sopsFile = ./secrets/simplevpn.yaml;
  };
}
