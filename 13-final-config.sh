enable_secure_mode() {
    runuser -u otrs -- \
        perl -I"${INSTALL_DIR}" -I"${INSTALL_DIR}/Kernel/cpan-lib" \
        -MKernel::System::ObjectManager \
        -e '
            use strict;
            use warnings;

            local $Kernel::OM = Kernel::System::ObjectManager->new();
            
            my $SysConfigObject = $Kernel::OM->Get("Kernel::System::SysConfig");

            my $SettingName = "SecureMode";

            my $ExclusiveLockGUID = $SysConfigObject->SettingLock(
                Name   => $SettingName,
                Force  => 1,
                UserID => 1,
            );

            my $Result = $SysConfigObject->SettingUpdate(
                Name              => $SettingName,
                IsValid           => 1,
                EffectiveValue    => 1,
                ExclusiveLockGUID => $ExclusiveLockGUID,
                UserID            => 1,
            );

            exit !$Result;
        ' &> /dev/null
}

echo -n 'Rebuilding system configuration... '

if runuser -u otrs "${INSTALL_DIR}/bin/otrs.Console.pl" \
    'Maint::Config::Rebuild' &> /dev/null;
then
    print_check_result 'rebuilt' 1
else
    print_check_result 'failed' 0
    # TODO: Handle error
    exit 1
fi

echo -n 'Enabling secure mode... '

if enable_secure_mode; then
    print_check_result 'enabled' 1
else
    print_check_result 'failed' 0
    # TODO: Handle error
    exit 1
fi

echo
print_check_result 'System configuration completed.' 1
echo
