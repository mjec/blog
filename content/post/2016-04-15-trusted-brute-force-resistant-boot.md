+++
title = "An idea for trusted brute-force-resistant two-factor-authenticated full disk encryption"
tags = ["technical", "rc", "security", "systems", "cryptography"]
description = "Combining a trusted platform module with a smart card (e.g. YubiKey) enables trusted booting with full disk encryption and without the ability to brute force passwords."
date = "2016-04-15"
+++

I was privileged to see [Matthew Garrett's talk](https://www.youtube.com/watch?v=rML5DfYUh_k) at <abbr title="Linux.conf.au">LCA</abbr> this year on [tpmtotp](https://github.com/mjg59/tpmtotp). This is software which enables you to verify that your computer hardware has not been tampered with before you are required to enter your full disk encryption password. It does this by sealing the <abbr title="Time-based One-time Password Algorithm (RFC 6238)">TOTP</abbr> secret in the <abbr title="trusted platform module">TPM</abbr> against a particular set of platform control register values. This means that if any aspect of the boot configuration changes the secret cannot be unsealed, so an attacker cannot pretend to be you.

This idea was attractive to me. For a long time I carried my laptop's bootloader with me on a USB to ensure that there could be no tampering with it before I entered my disk encryption password. This mitigates against a significant attack, namely the installation of an early boot keylogger.

The recent [San Bernardino iPhone case](https://en.wikipedia.org/wiki/FBI%E2%80%93Apple_encryption_dispute) was a nice reminder that when it comes to hardware with a secure element, brute forcing is not always possible. This is a major change to the old orthodoxy that if the attacker has physical access, it's all over.

This afternoon I was thinking about potential system development activities that would enable me to learn [Rust](https://www.rust-lang.org/). I also happened to have the page open for [YubiKeys](http://www.yubico.com/), because now that I'm in the US I might be able to buy one without paying obscene amounts for shipping.

Over the course of a walk an idea formed in my head: we can combine the secure element of a YubiKey (or indeed any [FIPS-compliant PIV](http://csrc.nist.gov/groups/SNS/piv/standards.html) smart card) with the TPM to develop a system which you know is safe and for which your full disk encryption password is not amenable to brute forcing.

## Background
A smart card (specifically a PIV card, but I'll just refer to them as smart cards) performs cryptographic operations on a secure element. These operations are performed without the key ever being released to the user.

Each smart card is protected by a PIN. The precise details of this PIN are left to implementers, but only a limited number of tries are permitted before the PIN becomes locked. In the YubiKey case a PIN can be up to 8 bytes (256 bits) long. Some documentation suggests that a PIN must be alphanumeric, but this is not clear. The YubiKey owner can also set the maximum number of PIN attempts before it becomes locked, anywhere in the range 1 to 255.

If the PIN becomes locked it can be unlocked by use of a separate code known as the PUK. This is subject to the same restrictions as the PIN (and indeed it appears that on the YubiKey the two are implemented in the same way but accessed at different times).

Once the PIN and PUK are both locked, the card can no longer be used to perform cryptographic operations without being reset. The key material is lost.

A smart card contains a number of key slots. These notably include the card authentication key (slot 9E), which can perform encryption/decryption/signing operations without a PIN being entered, and the PIV authentication key (slot 9A), which requires the PIN to be entered before an operation can be performed. Slot 9A is designed for use cases including system login.

A TPM can "seal" a secret against the values of the process control registers. While the precise details of this are complicated, essentially it serves as cryptographic proof that everything executed on the system at a particular time (and of a particular type) matches a "known good" state.

## Set up

I assume that the user has a setup not unlike mine: a "main boot partition" which prompts for a user password then performs decryption and boots up the actual system following the usual [LUKS](https://gitlab.com/cryptsetup/cryptsetup/blob/master/README.md) process.

When a user installs this system, they will be installing an "early boot partition". They begin by generating new keys on their smart card (9A and 9E keys described above). These keys are never known to the operating system.

The user then chooses their boot password. This is passed through a key derivation function (KDF), producing eight bytes of output. The PIN for the smart card is set to the output of this KDF.

The user should also set a random PUK of maximal length. This should be written down on a piece of paper but otherwise not stored.

For a YubiKey the user should also set a maximum number of tries before the PIN and PUK are locked. 10 seems an appropriate balance to me.

The user's disk should be encrypted not with their boot password but instead with a randomly generated keyfile of appropriate length, mixed with the user's boot password (for example, using a KDF). The keyfile should then be encrypted with the 9A key (i.e. requiring the PIN to be entered). That encrypted key file should then be stored on the main boot partition.

The main boot partition should be modified to provide some verification visible to the user. This could be as simple as being a secret phrase, it could be a TOTP code, or even an application where the user presents a challenge and the computer responds from a database of responses. It can be arbitrarily complex, and should give the user confident that their program is running.

The main boot partition should be configured to first display this verification, and then prompt for a password. The password should then be passed through the KDF as above, and the result used as the PIN for the smart card. With the PIN, the keyfile can be decrypted using slot 9A. The decrypted keyfile should then be mixed with the original password and the result passed to LUKS to decrypt the main disk.

The main boot partition is going to be some form of in memory file system (initramfs). This is normally built into a [single compressed file](https://wiki.archlinux.org/index.php/Mkinitcpio) which is then loaded by the bootloader. At this stage the user will can build their initramfs file.

Next, a random key is generated. This key is used to encrypt the initramfs. A copy of this key (with appropriate protections e.g. readable only by root and protected by symmetric or other encryption) should be stored on the system drive (i.e. the drive that will be the subject of full disk encryption).

That key is also encrypted on the smart card with the 9E (i.e. no PIN) key slot. Then the encrypted key value (the "sealed value") should then be sealed to the TPM with a known good state.

We now point our bootloader to the early stage boot loader, and point that to the encrypted initramfs.

## The boot process

Our early boot partition is called by grub or equivalent.

It then asks the TPM for the sealed value. If this is provided, that proves that the system is in a known good state. If it is not provided, booting will fail at this point.

The sealed value is then passed to the smart card and decrypted using slot 9E. This does not require any intervention by the user. That decrypted value can then be used as a key to decrypt the initramfs.

Our early boot partition can then hand off control to the main boot partition. This main boot partition will present the verification information to the user, then prompt for a password.

If the verification information is absent or incorrect, the user knows that their system has been the subject of tampering. If it is present, that proves we are looking at the correct boot loader.

The password is then passed through the KDF and that provides the main boot partition with the smart card PIN. That PIN can be used to decrypt the keyfile, using the 9A key slot. The keyfile can then be mixed with the password itself, to form the full disk encryption key and the system can proceed to boot.

Importantly, if multiple passwords are tried, this will lock the PIN on the smart card. This prevents password brute forcing.

## Changes to the system

Any change which modifies the PCR will mean that a new copy of the early boot partition encryption key needs to be re-sealed into the TPM. This is why a copy should be saved to the disk (which will ultimately be encrypted in any case).

## Backups

The following elements should be backed up:

* The PUK - this can be used to change the PIN. The PUK will be necessary for instances where too many incorrect password attempts were made.

* The actual full disk encryption key/raw LUKS headers. These are necessary in case the smart card is ever lost or damaged. It is good practice to keep a back up of these in case of disk corruption in any case.

You can of course omit to keep backups - or indeed set the PUK to a random value that is immediately discarded - if you wish to live on the edge and reduce the attack surface.

## Assumptions

We assume that the cryptographic processes used here are all authenticated encryption/decryption and are not vulnerable to attack. We assume that the secure element of our smart card is in fact secure, and that the card cannot be cloned.

We assume that the cryptographic operations do not leak information about the plain text (and in particular that mixing the password with a keyfile decrypted using the KDF of the password as PIN for the smart card does not introduce a vulnerability).

We assume that the system starts in a known good state and is not compromised while turned on (because if it were, you can just read the raw disk encryption password from memory).

## Security guarantees

I believe this provides us with the following guarantees:

1. An attacker cannot recover the disk encryption key without both the smart card and the user's password (two factors of authentication)

3. An attacker cannot modify the system without that tampering being evident

4. An attacker cannot brute force the password without both the smart card and the PUK

5. The compromise of either factor leaves us in a position no worse than with if the remaining factor were our only means of authentication

6. An attacker cannot view the verification information without both having possession of the smart card and booting the system into a known good state

7. An attacker cannot recover the key without having the password and smart card, *and* being able to place the system into the known good state (because the sealed value is necessary to access the early boot partition, which is where the key material is stored)

## Risks

* The smart card alone is sufficient for a person with physical access to the machine to see the verification sequence. This is may permit an attacker to replicate the verification sequence. Having a dynamic verification sequence (e.g. TOTP or challenge-response) is a significant mitigation, but can be bypassed through bugs in the early boot partition code or direct memory access.

* The PUK can be used to reset the PIN or incorrect tries counter. We mitigate against this by setting the full disk encryption key to a value returned from the smart card mixed with the user's password. However, an attacker with the PUK can still brute force the password.

I am thinking about making this my batch project for my time at [RC](https://www.recurse.com/). I was thinking I wanted to do some system programming, and what better way to start? The only small snag is that I use  a Macbook Pro, so there's no TPM in this computer.
