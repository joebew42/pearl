
unset PEARL_ROOT PEARL_HOME
OLD_PWD=$PWD

function pearlSetUp(){
    pearlRootSetUp
    pearlHomeSetUp
}

function pearlRootSetUp(){
    PEARL_ROOT=$(TMPDIR=/tmp mktemp -d -t pearl-test-root.XXXXXXX)
    mkdir -p $PEARL_ROOT/etc
    touch $PEARL_ROOT/etc/pearl.conf.template
    mkdir -p $PEARL_ROOT/lib
    echo "echo sourced utils.sh" > $PEARL_ROOT/lib/utils.sh
}

function pearlHomeSetUp(){
    HOME=$(TMPDIR=/tmp mktemp -d -t pearl-user-home.XXXXXXX)
    mkdir -p $HOME
    PEARL_HOME=${HOME}/.config/pearl
    mkdir -p $PEARL_HOME
    mkdir -p $PEARL_HOME/etc
    touch $PEARL_HOME/etc/pearl.conf
    mkdir -p $PEARL_HOME/repos
    mkdir -p $PEARL_HOME/packages
}

function pearlTearDown(){
    cd $OLD_PWD
    rm -rf $PEARL_HOME
    rm -rf $HOME
    rm -rf $PEARL_ROOT
}

function setUpUnitTests(){
    OUTPUT_DIR="${SHUNIT_TMPDIR}/output"
    mkdir "${OUTPUT_DIR}"
    STDOUTF="${OUTPUT_DIR}/stdout"
    STDERRF="${OUTPUT_DIR}/stderr"
}

function assertCommandSuccess(){
    $(set -e
      $@ > $STDOUTF 2> $STDERRF
    )
    assertTrue "The command $1 did not return 0 exit status" $?
}

function assertCommandFail(){
    $(set -e
      $@ > $STDOUTF 2> $STDERRF
    )
    assertFalse "The command $1 returned 0 exit status" $?
}

# $1: expected exit status
# $2-: The command under test
function assertCommandFailOnStatus(){
    local status=$1
    shift
    $(set -e
      $@ > $STDOUTF 2> $STDERRF
    )
    assertEquals $status $?
}
