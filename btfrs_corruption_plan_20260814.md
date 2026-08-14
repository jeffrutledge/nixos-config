# btrfs corruption plan 20260814

## near term
- boot live usb and run `btrfs check --repair`

### claude reboot plan

1. Get a live environment

Download the NixOS minimal ISO from nixos.org/download (it already has btrfs-progs and cryptsetup built in, so nothing extra to install).
Write it to a spare USB:
sudo dd if=nixos-minimal-*.iso of=/dev/sdX bs=4M status=progress conv=fsync
Replace /dev/sdX with your USB drive (double-check with lsblk first — this is destructive to whatever's on that drive).

2. Boot from it

Reboot, hit your boot-menu key (commonly F12, F2, or Esc) before NixOS's own bootloader loads, and pick the USB.

3. In the live environment, unlock and target the filesystem — don't mount it

sudo cryptsetup open /dev/nvme0n1p3 luksRoot
(enter your LUKS passphrase — this is the same partition as your normal boot, nvme0n1p3 per your earlier lsblk output)

btrfs check --repair requires the filesystem to be unmounted, which it will be by default in the live environment (you haven't mounted it,
just decrypted it) — don't run mount on it.

4. Look before you leap — run the check without --repair first

sudo btrfs check /dev/mapper/luksRoot
This reports every problem it finds without changing anything. Skim the output — if you want, paste it back to me and I'll help interpret it
before you commit to repairing.

5. Run the actual repair

sudo btrfs check --repair /dev/mapper/luksRoot
It'll print what it's fixing as it goes. This is the step that resolves the parent transid verify failed tree corruption we found.

6. Clean up and reboot back to normal

sudo cryptsetup close luksRoot
sudo reboot
(remove the USB when it restarts)

7. Back in your normal system, verify

sudo btrfs scrub start /
sudo btrfs scrub status /
This time it should run to completion instead of aborting. Whatever data-level corrupted files it still reports (the Firefox cache entries,
journal files, nix store paths, etc.) are the ones to delete and restore from backup — which brings us back to pinning down whether that's
restic or Duplicati, since I couldn't find a restic config in this repo.

### claude clean up corrupt plan

No single native btrfs command does this — btrfs scrub only detects corruption (and repairs it when a good mirror exists, which isn't the
case for your single-profile data), it doesn't delete anything. But here's a solid recipe combining btrfs scrub + btrfs inspect-internal to
find and remove exactly the bad files, once you're back on your normal boot after the metadata repair.

For /nix/store paths specifically — don't hand-delete these. Use nix's own repair, which verifies every store path's hash and re-fetches
anything that doesn't match:
sudo nix-store --verify --check-contents --repair

For everything else (home dir, caches, logs, etc.), run a fresh full scrub and capture which files it flags:

sudo btrfs scrub start -B /
(-B blocks in the foreground until it finishes — should complete now that the tree corruption is repaired)

Then pull the affected logical block addresses out of the kernel log and resolve each one to its real file path:
sudo dmesg | grep -oP '(?<=checksum error at logical )[0-9]+' | sort -u > /tmp/bad_blocks.txt

while read -r addr; do
  sudo btrfs inspect-internal logical-resolve -P "$addr" /
done < /tmp/bad_blocks.txt | sort -u > /tmp/bad_files.txt

cat /tmp/bad_files.txt
logical-resolve is the robust way to do this — it correctly maps a corrupted block to its real absolute path regardless of which subvolume
it's in, rather than you trying to hand-parse the relative paths dmesg prints.

Review /tmp/bad_files.txt before deleting anything. Once you're satisfied it's just cache/log/regenerable files (or things you've confirmed
are in your backup):
sudo xargs -a /tmp/bad_files.txt rm -v

Then restore whatever's actually needed from your backup — which is still the open question: is it restic somewhere outside this repo, or is
Duplicati (the one actually configured/referenced in this repo) your real backup tool?



## long term
- test bootstrap process
- run bootstrap to rebuild misty from scratch

## claude suggestions
❯ i have a backup using restic, I don't need dup. is there a way (maybe btrfs command) that will clean up all the corruptions

● There isn't one command that cleanly fixes both layers of damage here — there are actually two different problems:

  1. Corrupted file data (Firefox cache, journal, nix store files, etc.) — btrfs scrub can find these while mounted and report exact paths, but
  it can't repair them since your data profile is single (no mirror to heal from). The fix is: delete the bad file, restic-restore it.
  2. Corrupted metadata tree structure (the parent transid verify failed errors where both DUP mirrors are stuck at the same stale generation)
  — this is deeper than a file checksum mismatch, it's internal btrfs tree damage, and it's what made the scrub abort entirely. The tool for
  this is btrfs check --repair, but it cannot run on a mounted filesystem — since this is your root filesystem, that means booting a live
  USB/rescue environment, opening the LUKS volume, and running btrfs check there. It's also somewhat notorious for being a last-resort tool —
  it can fix the tree, but sometimes by discarding whatever the broken references pointed to.
