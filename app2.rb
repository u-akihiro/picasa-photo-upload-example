require 'net/http'
require 'uri'
require 'cgi'
require 'base64'

# 実行時引数よりアクセストークンを取得
access_token = ARGV[0]
# エンドポイントURL
endpoint = 'https://picasaweb.google.com/data/feed/api/user/default/albumid/6037421118196288497'
uri = URI.parse endpoint
req = Net::HTTP::Post.new uri.request_uri
req['Content-Type'] = 'multipart/related; boundary="END_OF_POINT"'
req['Authorization'] = "Bearer #{access_token}"
req['Content-Encoding'] = "base64"
req['GData-Version'] = "2"

# 画像の読み込み
image = open './image.jpg', 'rb'
# 画像をBase64に変換
#Base64エンコードすると弾かれる。バイナリのまま渡すとうまくいく
#base64 = CGI.escape(Base64.strict_encode64 image.read)
# Atomを読み込む
atom = open './atom.txt', 'rb'

#req['Content-Length'] = atom.read.bytesize + base64.bytesize

post_body = <<"EOS"
--END_OF_POINT
Content-Type: application/atom+xml

#{atom.read}
--END_OF_POINT
Content-Type: image/jpeg

#{image.read}
--END_OF_POINT--
EOS

#req['Content-Length'] = post_body.bytesize

req.body = post_body

http = Net::HTTP.new uri.host, uri.port
http.use_ssl = true
#http.set_debug_output STDERR
res = http.request req

puts res.code
