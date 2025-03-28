# ISW / Ice-Sealed Wyvern
<img src="https://github.com/YoyPa/isw/blob/master/image/isw.svg" alt="" width="25%" align="right">

- isw started as an equivalent of "control tools by pherein" but under linux.
- It is meant to alter fan profiles of MSI laptops.
- Profiles for supported laptops are located in <a href="https://github.com/YoyPa/isw/blob/master/etc/isw.conf">/etc/isw.conf</a>.
- You can check <a href="https://github.com/YoyPa/isw/blob/master/etc/isw.conf">/etc/isw.conf</a>. comments for more details.

## Warning
- Use it at your own risk!
- Secure boot can prevent access to the EC.
- isw is made/tested with MSI GS40 6QE under Arch/Manjaro, other laptops depend on user contribution.
- Check that your EC (Embedded Controler) work the same way, you can find documentation on the <a href="https://github.com/YoyPa/isw/wiki/MSI-G-laptop-EC---Rosetta">wiki</a>.

## How to install
### Package or not package ?
- If you are using archlinux or a derivative you can install it from AUR: ```yay -S isw```
- If you are on a different distro family:
  - Clone ```git clone https://github.com/YoyPa/isw```
  - Then look at this <a href="https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=isw">PKGBUILD</a> to know where to put files.
  - /!\ Path can change a bit depending on the distro /!\

### Builtin or not builtin ?
- It need ```ec_sys``` module with option ```write_support=1```, there are two scenario to set that:
  - ec_sys is a builtin kernel module:
    - add ```ec_sys.write_support=1``` in ```/etc/default/grub``` (Arch AUR package can't do it for you).
    - then update your grub with ```update-grub``` and reboot.
  - ec_sys is not a builtin kernel module:
    - copy both ```isw-ec_sys.conf``` files provided (/etc/mod[...]) with same path (Arch AUR package will do it for you).
    - then reboot OR ```modprobe ec_sys write_support=1```.

## ISW decription.
```usage: isw [-h] [-b B] [-c] [-f FILE] [-p P] [-r [R]] [-s S S] [-t T] [-u USB] [-w W]

optional arguments:
  -h, --help            show this help message and exit
  -b B                  ┬ enable or disable CoolerBoost
                        └ replace B with off OR on

  -c                    ─ show an EC dump

  -f FILE, --file FILE  ┬ show profile in EC update file
                        └ replace FILE with FILE_NAME

  -p P                  ┬ show current profile in EC
                        └ replace P with SECTION_NAME

  -r [R]                ┬ show realtime CPU+GPU temp and fan speed from EC
                        ├ replace [R] with any [NUMBER] to perform a [NUMBER] of time(s)
                        └ Assume [0] if given nothing = infinite loop

  -s S S                ┬ set a single value into EC
                        ├ replace 1st S with ADDRESS in hexadecimal (0x00)
                        └ replace 2nd S with VALUE   in decimal     (00)

  -t T                  ┬ set the battery charging treshold
                        └ replace T with a NUMBER between 20 and 100 (٪)

  -u USB, --usb USB     ┬ set usb backlight level
                        └ replace USB with off, half OR full

  -w W                  ┬ write into EC
                        └ replace W with SECTION_NAME

┌─ TIPS ──────────────────────────────────────────────────────────────────┐
│ Set your config in '/etc/isw.conf'.                                     │
│ Arguments order is relevant, -c and -p can be used twice. Example:      │
│ isw -cw SECTION_NAME -c will show you EC dump before and after change.  │
├─ SUPPORT ───────────────────────────────────────────────────────────────┤
│ Help me support your laptop by providing following command output:      │
│ isw -cp MSI_ADDRESS_DEFAULT                                             │
│ via https://github.com/YoyPa/isw (open an issue).                       │
│ Make sure your dump is made before altering EC with isw, you can reset  │
│ your EC with a reboot or by changing power source.                      │
├─ NAME ──────────────────────────────────────────────────────────────────┤
│ ISW is MSI at 180°                                                      │
│ It means Ice-Sealed Wyvern in opposition to MSI's 'unleash the dragon'  │
└─────────────────────────────────────────────────────────────────────────┘
```
<b>NB: all option exept -h and -f need priviledges.</b>

### An example
<b>SECTION_NAME</b> refer to the motherboard name inside ```isw.conf```, if <b>for example</b> you have a <b>GS40_6QE</b> your <b>SECTION_NAME</b> would be <b>14A1EMS1</b>.

If you want to change temperature treshold and/or fan speed for cpu and/or gpu, you have to edit the corresponding section in ```isw.conf``` to set the wanted values and use ```isw -w 14A1EMS1``` to apply.

If you want to check the current temperature and fan speed you will have to type ```isw -r```.

Don't forget to read the comment at the beginning of ```isw.conf```, it contain some helpfull info.

## Launch at startup/resume
You can launch ```isw -w [SECTION_NAME]``` at startup/resume via systemd with isw@.service (need priviledges):
```
systemctl enable isw@[SECTION_NAME].service
```
## ec_sys support for kernel version greater than 5.11
```sh
cd /opt
sudo wget https://github.com/musikid/acpi_ec/releases/download/v1.0.2/acpi-ec_1.0.2_all.deb
sudo dpkg -i acpi-ec_1.0.2_all.deb
sudo reboot
```
OR
```sh
sudo -i
cd /opt
git clone https://github.com/musikid/acpi_ec.git
cd acpi_ec
# Make sure your env is clean
./uninstall.sh &>/dev/null
apt remove -y acpi-ec 2>/dev/null
# Perform installation
./install.sh
# In my case, I needed to run the keys-setup.sh
scripts/keys-setup.sh
reboot

# In grub, enroll the MOK using the password you chose
# Then, run the signing procedure
sudo /usr/src/linux-headers-5.19.0-21-generic/scripts/sign-file sha512 /opt/scripts/mok.priv  /opt/scripts/mok.der /var/lib/dkms/acpi_ec/v1.0.2/5.19.0-21-generic/x86_64/module/acpi_ec.ko
sudo /usr/src/linux-headers-5.19.0-21-generic/scripts/sign-file sha512 /opt/scripts/mok.priv  /opt/scripts/mok.der /usr/lib/modules/5.19.0-21-generic/updates/dkms/acpi_ec.ko
sudo reboot
```
After reboot, verify you can see the /dev/ec socket. If so, you have two options:
    - edit the ```/usr/bin/isw``` python script to point there
    - create symlink from the expected path to point there
	- I'm unsure it would survive in ```/sys/kernel/debug``` after reboot, slight modification of isw systemd file could be an option
