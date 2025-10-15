#!/bin/bash

# Build variables
ENV=Release

# Functions
show_help() {
    echo "This script is a front end for project build and clean up tasks, which are actually handled by Make"
    echo "Usage: bash manager.sh -<option> <argument (OPTIONAL)> ..."
    echo "It accepts chained options and tries to execute then in order, unknown"\
        " options are ignored, the script only stops when it either finish its"\
        " tasks or one of them fails\n"
    echo "Valid options are:"
    echo "  -h                    | Show this message"
    echo "  -b <(OPTIONAL) debug> | Build the project, if the \"debug\" argument is passed, it will build with debug rules"
    echo "  -c                    | Clean the project"
    echo "  -t                    | Generate symbols tags, only util if you're "\
        "using vim or other text editor that consumes ctags files to go to "\
        "symbols definitions"
    echo "  -ut                   | Remove the tags file"
    echo "  -p <(OPTIONAL) gdb>   | Runs the generated binary, if the argument "\
        "\"gdb\" is used, it will open the gdb to debug the game, but only if a"\
        "debug binary was generated"
}


play_test() {
    if [[ ${1,,} == "gdb" ]] && [ -f ./bin/Linux64/Debug/lsdl2srb2kart ]; then
        echo "Executing gdb"
        optn=$((optn+1))
        ENV=Debug
        BIN=gdb
    fi
    
    $BIN ./bin/Linux64/$ENV/lsdl2srb2kart
}

clean_tags() {
    rm -f tags 
}

gen_tags() {
    ctags -R --languages=C,C++ \
        --exclude=assets \
        --exclude=bin \
        --exclude=cmake \
        --exclude=debian-template \
        --exclude=deployer \
        --exclude=doc \
        --exclude=objs \
        --exclude=.git \
        --exclude=.ccls-cache \
        --exclude=.circleci \
        .
}

clean_build() {
    make clean
}

build() {
    if [[ ${1,,} == "debug" ]]; then
        echo "Generating debug build"
        optn=$((optn+1))
        DEBUG=1
        ENV=Debug
    fi

    make LINUX64=1 SDL=1 NOUPX=1 DEBUGMODE=$DEBUG -j8
}

if [[ $# -lt 1 ]]; then
    show_help
    exit 1
fi

for (( optn=1; optn <= $# ; optn++)); do
    arg=$((optn+1))

    case "${!optn}" in
        "-h" )
            show_help ;;
        "-b" )
            build ${!arg} ;;
        "-c" )
            clean_build ;;
        "-t" )
            gen_tags ;;
        "-ut" )
            clean_tags ;;
        "-p" )
            play_test ${!arg} ;;
        *)
            echo "Invalid option: \"${!optn}\" - ignoring.." ;;
    esac

    if [ $? -ne 0 ]; then
        exit $?
    fi
done
