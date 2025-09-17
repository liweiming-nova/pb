#!/bin/bash

echo "rm gen-go..."
rm -rf gen-go
mkdir -p gen-go

echo "begin to generate code with buf..."
buf generate
if [ $? -ne 0 ]; then
    echo "gen failed"
    exit 1
fi

# ========== 保留你的后处理逻辑 ==========
for f in $(find gen-go -type f -name '*.pb.go'); do
    if [ "$(uname)" == "Darwin" ]; then # Mac
        sed -e 's/,omitempty"/"/g' -i '' "$f"
    else # Linux
        sed -e 's/,omitempty"/"/g' -i "$f"
    fi
    protoc-go-inject-tag -input "$f"
done

echo "done."