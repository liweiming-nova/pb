#!/bin/bash

echo "rm gen-go..."
rm -rf gen-go
mkdir -p gen-go

echo "begin to generate code with buf..."
# 临时重命名 third_party/google 避免与 Buf 内置模块冲突，但保留 validate
if [ -d "third_party/google" ]; then
    mv third_party/google third_party/google_backup
fi
buf dep update
buf generate
# 恢复 third_party/google 目录
if [ -d "third_party/google_backup" ]; then
    mv third_party/google_backup third_party/google
fi
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