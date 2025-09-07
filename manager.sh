#!/bin/bash

play_test() {
    ./bin/Linux64/Debug/lsdl2srb2kart
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
        --exclude=.circleci
}

clean_build() {
    make clean
}

build() {
    make LINUX64=1 SDL=1 NOUPX=1 DEBUGMODE=1 -j8
}

for (( argn=1; argn <= $# ; argn++)); do
    case "${!argn}" in
        "-b" )
            build ;;
        "-c" )
            clean_build ;;
        "-t" )
            gen_tags ;;
        "-ut" )
            clean_tags ;;
        "-p" )
            play_test ;;
        *)
            echo "Invalid option: \"${!argn}\" - ignoring.." ;;
    esac

    if [ $? -ne 0 ]; then
        exit $?
    fi
done
