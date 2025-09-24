#!/bin/bash
#########################################################################
# Author: (zhengfei@bestfulfill.com)
# Created Time: 2020-07-22 10:48:39
# File Name: build.sh
# Description:
#########################################################################

echo "rm gen-go gen-java..."
rm -rf gen-go #gen-java/src
mkdir -p gen-go
#mkdir -p gen-java/src/main/java

echo "begin to generate code ..."

find . -type f -name '*.proto' | xargs -n 1 protoc \
	-I=. \
	-I=./third_party \
	--go_out=paths=source_relative:./gen-go \
	--go-grpc_out=paths=source_relative,require_unimplemented_servers=false:./gen-go \
	--validate_out=paths=source_relative,lang=go:./gen-go \
	#--java_out=:./gen-java/src/main/java \
	#--grpc-java_out=:./gen-java/src/main/java
if [ $? -ne 0 ]
then
    echo "gen failed"
    exit -1
fi

for f in `find gen-go -type f -name '*.pb.go'`; do
    if [ `uname` == "Darwin" ]; then # Mac
        sed -e 's/,omitempty"/"/g' -i '' $f;
    else # Linux
        sed -e 's/,omitempty"/"/g' -i $f;
    fi;
    protoc-go-inject-tag -input $f;
done

echo done.

# vim: set noexpandtab ts=4 sts=4 sw=4 :
