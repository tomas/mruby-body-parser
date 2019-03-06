def env_for(path: '/', method: 'GET', query: '', body: '', type: BodyParser::FORM_DATA_TYPE, length: nil)
  { 'REQUEST_METHOD' => method, 
    'PATH_INFO' => path, 
    'QUERY_STRING' => query, 
    'CONTENT_TYPE' => type, 
    'CONTENT_LENGTH' => length,
    'rack.input' => body.nil? ? nil : InputStream.new(body) }
end

assert 'BodyParser' do
  
  backend = Proc.new { |env|
    # return body.hash hash as response body
    [200, {}, env['body.hash']]
  }

  app = BodyParser::Middleware.new(backend, skip_delete: true)

  status, headers, body = app.call(env_for(path: '/'))
  assert_kind_of Hash, body
  assert_equal [], body.keys

  status, headers, body = app.call(env_for(path: '/', body: nil)) # no rack.input
  assert_kind_of Hash, body
  assert_equal [], body.keys

  status, headers, body = app.call(env_for(body: 'id=2'))
  assert_equal nil, body[:id]
  assert_equal '2', body['id']

  status, headers, body = app.call(env_for(body: 'feed_id=5'))
  assert_equal '5', body['feed_id']

  status, headers, body = app.call(env_for(body: 'feed_id=5&age=99'))
  assert_equal '5',  body['feed_id']
  assert_equal '99', body['age']

  status, headers, body = app.call(env_for(body: 'feed_id=5&feed_id=6'))
  assert_equal %w[5 6],body['feed_id']

  status, headers, body = app.call(env_for(body: '{ "foo": 123 }'))
   # assert_equal ["{ \"foo\": 123 }"], body.keys # parsed as form data
  assert_equal nil, body['foo']

  status, headers, body = app.call(env_for(body: '{ "foo" ', type: 'application/json'))
  assert_equal [], body.keys # invalid

  status, headers, body = app.call(env_for(body: '{ "foo": 123 }', type: 'application/json')) # invalid type
  assert_equal 123, body['foo']

multipart_body =  ['--AaB03x',
  'content-disposition: form-data; name="field1"',
  '',
  "Joe Blow\r\nalmost tricked you!",
  '--AaB03x',
  'content-disposition: form-data; name="pics"; filename="file1.txt"',
  'Content-Type: text/plain',
  '',
  "... contents of file1.txt ...\r",
  '--AaB03x--',
  ''
].join("\r\n")

  multipart_type = 'multipart/form-data; boundary=AaB03x'
  status, headers, body = app.call(env_for(body: multipart_body, length: multipart_body.bytesize, type: multipart_type))

  assert_equal body['field1'].data, "Joe Blow\r\nalmost tricked you!"
  # assert_equal body['pics'].data, "... contents of file1.txt ...\r"
  assert_equal nil, body['pics'].data

  file = body['pics'].file
  assert_equal file.class, File
  assert_equal IO.read(file.path), "... contents of file1.txt ...\r"
  File.unlink(file.path)

=begin
multipart_body = %{--AaB03x
Content-Disposition: form-data; name="foo"

bar
--AaB03x
Content-Disposition: form-data; name="files"
Content-Type: multipart/mixed, boundary=BbC04y

--BbC04y
Content-Disposition: attachment; filename="file.txt"
Content-Type: text/plain

contents
--BbC04y
Content-Disposition: attachment; filename="flowers.jpg"
Content-Type: image/jpeg
Content-Transfer-Encoding: binary

contents
--BbC04y--
--AaB03x--
}

  multipart_type = 'multipart/form-data; boundary=AaB03x'
  _, body = app.call(env_for(body: multipart_body, length: multipart_body.bytesize, type: multipart_type))
  assert_equal 123, body['foo']
=end
end
