### These are test calls issued against the running images 
#### installing the plugin
`export PATH="$PATH:$HOME/.pub-cache/bin"`\
`dart pub global activate protoc_plugin`\
`protoc --dart_out=grpc:lib/src/generated --proto_path ../scrapy/cmd/protobuf ../scrapy/cmd/protobuf/grpc.proto`\
`dart pub get`
