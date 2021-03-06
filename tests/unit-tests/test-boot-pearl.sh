#!/bin/bash
source "$(dirname $0)/utils.sh"

# Disable the exiterr
set +e

function oneTimeSetUp(){
    setUpUnitTests
}

function setUp(){
    pearlSetUp
    mkdir -p ${PEARL_HOME}/packages/pearl/ls-colors/pearl-metadata
    create_config_file config.sh
    create_config_file config.bash
    create_config_file config.zsh
}

function tearDown(){
    pearlTearDown
}

function create_config_file() {
    local configfile=$1
    local content=$(cat <<EOF
    echo sourced $configfile
    [ -n "\$PEARL_PKGDIR" ]
EOF
)
    echo "$content" > ${PEARL_HOME}/packages/pearl/ls-colors/pearl-metadata/$configfile
}

function fish_wrapper(){
    echo "$@" > "${OUTPUT_DIR}/fish_command"
    fish ${OUTPUT_DIR}/fish_command
}

function bash_wrapper(){
    $@
    source "${OUTPUT_DIR}/sourced_file"
}

function test_pearl_no_pearl_root_var(){
    unset PEARL_ROOT
    assertCommandFailOnStatus 1 source $(dirname $0)/../../boot/pearl.sh
    assertCommandFailOnStatus 1 fish_wrapper "source $(dirname $0)/../../boot/pearl.fish"
}

function test_pearl_wrong_pearl_root_var(){
    PEARL_ROOT="/tmmmmp"
    assertCommandFailOnStatus 2 source $(dirname $0)/../../boot/pearl.sh
}

function test_pearl(){
    local content=$(cat <<EOF
    # Make sure that PEARL_HOME, PEARL_ROOT, PEARL_TEMPORARY are set with export
    env | grep -q PEARL_HOME
    env | grep -q PEARL_ROOT
    env | grep -q PEARL_TEMPORARY
    echo \$PATH | grep -q \$PEARL_ROOT/bin
    echo \$MANPATH | grep -q \$PEARL_ROOT/man
EOF
)
    echo -e "$content" > ${OUTPUT_DIR}/sourced_file

    ZSH_NAME="SOMENAME"
    BASH="SOMENAME"
    assertCommandSuccess bash_wrapper source $(dirname $0)/../../boot/pearl.sh
    assertEquals "$(echo -e "sourced utils.sh\nsourced config.sh\nsourced config.bash\nsourced config.zsh")" "$(cat $STDOUTF)"

}

function test_pearl_config_error(){
    echo "return 123" > ${PEARL_HOME}/packages/pearl/ls-colors/pearl-metadata/config.sh
    assertCommandFailOnStatus 123 source $(dirname $0)/../../boot/pearl.sh
}

source $(dirname $0)/shunit2
