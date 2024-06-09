# Always installs bindings for insert and default mode for simplicity and b/c it has almost no side-effect
# https://gitter.im/fish-shell/fish-shell?at=60a55915ee77a74d685fa6b1
function sinh_configure_bindings --description "Installs the default key bindings for sinh-x.fish with user overrides passed as options."
    # no need to install bindings if not in interactive mode or running tests
    status is-interactive || test "$CI" = true; or return

    for mode in default insert
        test -n  \e\cw && bind --mode $mode \e\cw _sinh_git_repos_status
    end

end
