{ config
, lib
, pkgs
, ... }:

let
  livecd = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    system = "x86_64-linux";
    modules = [
      (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
      rescue/configuration.nix
    ];
  };

  mokKey = pkgs.runCommand "mok-key" {} ''
    export PATH=${lib.makeBinPath (with pkgs; [
      coreutils-full
      openssl
    ])}:$PATH

    mkdir -p $out
    # Generate 2048-bit RSA MOK key, valid 10 years
    openssl req -new -x509 -newkey rsa:2048 -nodes \
      -keyout $out/MOK.key \
      -out $out/MOK.pem \
      -days 3650 \
      -subj "/CN=NixOS Secure Boot MOK/"
    openssl x509 -in $out/MOK.pem -outform DER -out $out/MOK.crt
    chmod 600 $out/MOK.key
    chmod 644 $out/MOK.crt
  '';

  sbatMetadata = pkgs.writeText "sbat.csv" ''
    sbat,1,SBAT Version,sbat,1,https://github.com/rhboot/shim/blob/main/SBAT.md
    grub,1,GRUB,2.12,https://www.gnu.org/software/grub/
  '';
in {
  options.boot.grub = {
    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/sda";
      description = "Which device to install GRUB to.";
    };
    efi = {
      enable = lib.mkEnableOption "Whether to GRUB2's EFI support.";
      enableSecureBoot = lib.mkEnableOption "Whether to enable SecureBoot signing of GRUB.";
      removable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to install as removable or not (rarely needed).";
      };
    };
    enable = lib.mkEnableOption "Whether to GRUB2.";
    enableMemtest = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to add a memtest86 entry.";
    };
    enableRescue = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to add a small rescue environment to the bootloader.";
    };
    enableProber = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable GRUB2's os-prober.";
    };
    copyKernels = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to copy kernels to /boot";
    };
    configurationLimit = lib.mkOption {
      type = lib.types.int;
      default = 100;
      description = "Number of configurations to keep";
    };
  };

  config = {
    assertions = [
      {
        assertion = !(config.boot.grub.efi.enableSecureBoot && config.boot.grub.efi.removable);
        message = ''
          boot.grub.efi.enableSecureBoot and boot.grub.efi.removable cannot both be enabled.

          Secure Boot uses shim at EFI/Boot/bootx64.efi, which conflicts with GRUB's removable install path.
          Disable removable or Secure Boot.
        '';
      }
      {
        assertion = !config.boot.grub.efi.enableSecureBoot || config.boot.grub.efi.enable;
        message = "Secure Boot requires EFI mode (boot.grub.efi.enable = true).";
      }
    ];

    boot.loader = lib.mkIf config.boot.grub.enable {
      efi = lib.mkIf config.boot.grub.efi.enable {
        canTouchEfiVariables = !config.boot.grub.efi.removable;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = true;
        configurationLimit = config.boot.grub.configurationLimit;
        copyKernels = config.boot.grub.copyKernels;
        device = if config.boot.grub.efi.enable then "nodev" else config.boot.grub.device;
        efiSupport = config.boot.grub.efi.enable;
        efiInstallAsRemovable = config.boot.grub.efi.removable;
        extraEntries = lib.strings.optionalString config.boot.grub.enableRescue ''
          menuentry "NixOS Recuse" {
            linux ($drive1)/rescue-kernel init=${livecd.config.system.build.toplevel}/init ${toString livecd.config.boot.kernelParams}
            initrd ($drive1)/rescue-initrd
          }
        '';
        extraFiles = lib.mkIf config.boot.grub.enableRescue {
          "rescue-kernel" = "${livecd.config.system.build.kernel}/bzImage";
          "rescue-initrd" = "${livecd.config.system.build.netbootRamdisk}/initrd";
        };
        useOSProber = config.boot.grub.enableProber;
        memtest86.enable = config.boot.grub.enableMemtest;
        extraGrubInstallArgs = [
          "--sbat=${./sbat.csv}"
        ] ++ lib.optionals config.boot.grub.efi.enableSecureBoot  [
          "--modules=boot cat help chain configfile echo ls linux normal test true part_msdos part_gpt fat ext2 ntfs search search_fs_file search_label elf gzio font terminal gfxterm gfxterm_menu gfxterm_background gfxmenu png video videotest video_fb video_bochs video_cirrus video_colors efi_gop efi_uga tpm"
        ];
        extraInstallCommands = lib.strings.optionalString config.boot.grub.efi.enableSecureBoot ''
          export PATH=${lib.makeBinPath (with pkgs; [
            coreutils-full
            efibootmgr
            gawk
            gnugrep
            gnused
            sbsigntool
            util-linux
          ])}:$PATH

          # Ensure /etc/secureboot is exists and is up to date before signing
          echo "[SecureBoot] Linking MOK key to /etc/secureboot"
          mkdir -p /etc/secureboot
          ln -sf ${mokKey}/MOK.key /etc/secureboot/MOK.key
          ln -sf ${mokKey}/MOK.crt /etc/secureboot/MOK.crt
          ln -sf ${mokKey}/MOK.pem /etc/secureboot/MOK.pem

          mkdir -p /boot/SecureBoot
          cp ${mokKey}/* /boot/SecureBoot

          echo "[SecureBoot] Signing GRUB EFI with MOK key..."

          sign_file() {
            local f="$1"
            local tmp="$f.signed"

            if ! sbverify --cert /etc/secureboot/MOK.pem $f >/dev/null 2>&1; then
              echo "[SecureBoot] Signing binary..."
              sbsign --key /etc/secureboot/MOK.key \
                    --cert /etc/secureboot/MOK.pem \
                    --output "$tmp" "$f"
              mv "$tmp" "$f"
            else
              echo "[SecureBoot] Binary already signed, skipping..."
            fi
          }

          # Sign GRUB EFI
          GRUB_EFI="/boot/EFI/NixOS-boot/grubx64.efi"
          if [ -f "$GRUB_EFI" ]; then
            sign_file "$GRUB_EFI"
          fi

          echo "[SecureBoot] Signing Linux kernels..."
          for f in /boot/kernels/*-bzImage; do
            sign_file $f
          done

          echo "[SecureBoot] Installing shim..."
          mkdir -p /boot/EFI/NixOS-boot
          cp ${pkgs.shim}/efi/shimx64.efi /boot/EFI/NixOS-boot
          cp ${pkgs.shim}/efi/mmx64.efi /boot/EFI/NixOS-boot

          echo "[SecureBoot] Fixing GRUB2 loadfont config..."
          sed -i 's|if loadfont (\$drive1)//converted-font\.pf2; then|if true; then|g' /boot/grub/grub.cfg

          echo "[SecureBoot] Overwriting GRUB boot entry with shim..."

          BOOT_LABEL="NixOS-shim"
          EFI_PATH="\EFI\NixOS-boot\shimx64.efi"

          # Detect EFI system partition
          EFI_MOUNT=$(findmnt -n -o SOURCE /boot || true)
          if [ -z "$EFI_MOUNT" ]; then
            echo "Error: Cannot detect mounted EFI system partition."
            exit 1
          fi

          # Just grab the partition directly from Linux, they already did the hard work
          DISK=$(lsblk -no PKNAME "$EFI_MOUNT")
          PART_NUM=$(cat /sys/class/block/$(basename "$EFI_MOUNT")/partition)
          [ -z "$PART_NUM" ] && echo "no partition number, skipping efibootmgr" && exit 0
          echo "[SecureBoot] Using EFI partition $EFI_MOUNT (disk $DISK, part $PART_NUM)"

          EXISTING=$(efibootmgr -v | grep -F "$BOOT_LABEL" || true)
          if [ -n "$EXISTING" ]; then
            BOOT_NUM=$(echo "$EXISTING" | sed -E 's/Boot([0-9A-F]{4}).*/\1/')
            efibootmgr -b "$BOOT_NUM" -B >/dev/null 2>&1
          fi
          efibootmgr -c -d "/dev/$DISK" -p "$PART_NUM" -L "$BOOT_LABEL" -l "$EFI_PATH" >/dev/null 2>&1

          # Set as next boot
          BOOT_NUM=$(efibootmgr -v | grep "$BOOT_LABEL" | sed -E 's/Boot([0-9A-F]{4}).*/\1/')
          if [ -n "$BOOT_NUM" ]; then
            efibootmgr -n "$BOOT_NUM" >/dev/null 2>&1
          fi
        '';
      };
      timeout = 10;
    };

    environment.systemPackages = lib.optionals config.boot.grub.efi.enableSecureBoot (with pkgs; [
      mokutil
      pesign
      sbsigntool
    ]) ++ (with pkgs; [
      efibootmgr
      efivar
    ]);
  };
}
