https://specifications.freedesktop.org/desktop-entry-spec/latest/recognized-keys.html
https://images.squarespace-cdn.com/content/v1/615e15afbd5653295346d2a8/6d235914-e640-47c0-bad1-62fc3f4bf688/NanoBeacon+Logo1.png?format=750w

# NanoBeaconConfigTool

------

### Eddystone Test

https://github.com/google/eddystone/blob/master/protocol-specification.md

#### UID Construction

An Eddystone-UID beacon ID is 16 bytes long, consisting of a 10-byte namespace component and 6-byte instance component. The namespace is intended to ensure ID uniqueness across multiple Eddystone implementers and may be used to filter on-device scanning for beacons. We recommend two methods for generating a unique 10-byte namespace: a truncated hash of your FQDN, or an elided UUID.

#### Truncated Hash of FQDN

Produce a SHA-1 hash of a fully-qualified domain name that you own. If you desire additional obscurity and/or additional namespaces, you may wish to use a random subdomain under this FQDN. Select the first 10 bytes from that hash.

`user@host:~$ echo homeassistant.some.domain | sha1sum | cut -c 1-10 -z | od -x --endian big`
`0000000 3630 6434 3565 6163 3433 0000`
`0000013`
`user@host:~$`

#### Elided Version 4 UUID

Generate a version 4 UUID then remove bytes 5 - 10 (inclusive). For example: from this UUID: 8b0ca750-e7a7-4e14-bd99-095477cb3e77 remove these bytes: e7a7-4e14-bd99. This produces the following namespace: 8b0ca750095477cb3e77.

This option may be useful if you interleave Eddystone-UID with other UUID-based frame formats. It allows you to relate your Eddystone-UID namespace to the UUID in the other frames by deriving one from the other.

`user@host:~$ uuidgen | awk '{split($0,a,"-"); printf("%s%s\n",a[1], a[5])}'`
`d08c981498dc8b28f020`
`user@host:~$`

#### Instance ID

The 6-byte instance portion of the Eddystone-UID beacon ID may be assigned via any method suitable for your application. They may be random, sequential, hierarchical, or any other scheme.

`user@host:~$ awk 'BEGIN {srand(systime()); printf("%06d", int(rand() * 2 ^ 20)); exit}' | od -x --endian big`
`0000000 3333 3037 31380000006`
`user@host:~$`

------

https://learn.sparkfun.com/tutorials/sparkfun-nanobeacon-board---in100-hookup-guide/troubleshooting

#### Increasing NanoBeacon Performance and Range

If you really need to squeeze out a little more performance from this board, InPlay suggests adjusting a couple of settings in the "XO" option under "Global Settings". First, changing the Internal Capacitor Code from 8 to 11 can add roughly 5-10dB performance which can help increase the range of the IN100. Second, changing the Strength Code from 16 to 19 should also help with overall performance.

------

### Easier persistent file access from user's home directory

`user@host:~$ ln -s ./.var/app/io.github.hfxuser.NanoBeaconConfigTool/NanoBeacon ./NanoBeacon`
`user@host:~$`
