function! db#adapter#oracle#canonicalize(url) abort
  let url = a:url

  " Dadbod strips a leading jdbc: before adapter canonicalization, so
  " jdbc:oracle:thin:@//host:1521/service arrives here as
  " oracle:thin:@//host:1521/service. Normalize the common JDBC thin forms
  " to Dadbod's oracle://user:pass@host:port/service URL shape.
  let url = substitute(url,
        \ '^oracle:thin:\([^/@:][^/]*\)/\([^@]*\)@//',
        \ 'oracle://\1:\2@', '')
  let url = substitute(url, '^oracle:thin:@//', 'oracle://', '')

  let sid_match = matchlist(url, '^oracle:thin:@\([^:]*\):\(\d\+\):\(.\+\)$')
  if !empty(sid_match)
    let url = 'oracle://' . sid_match[1] . ':' . sid_match[2] . '/' . sid_match[3]
  endif

  let sid_auth_match = matchlist(url, '^oracle:thin:\([^/@:][^/]*\)/\([^@]*\)@\([^:]*\):\(\d\+\):\(.\+\)$')
  if !empty(sid_auth_match)
    let url = 'oracle://' . sid_auth_match[1] . ':' . sid_auth_match[2] . '@' . sid_auth_match[3] . ':' . sid_auth_match[4] . '/' . sid_auth_match[5]
  endif

  return substitute(substitute(substitute(substitute(url,
        \ '^oracle:\zs\([^/@:]*\)/\([^/@:]*\)@/*\(.*\)$', '//\1:\2@\3', ''),
        \ '^oracle:\zs/\=/\@!', '///', ''),
        \ '^oracle:\zs//\ze\%(/\|$\)', '//localhost', ''),
        \ '^oracle:\zs//\ze[^@/]*\%(/\|$\)', '//system@', '')
endfunction

function! s:conn(url) abort
  return get(a:url, 'host', 'localhost')
        \ . (has_key(a:url, 'port') ? ':' . a:url.port : '')
        \ . (get(a:url, 'path', '/') == '/' ? '' : a:url.path)
endfunction

function! db#adapter#oracle#interactive(url) abort
  let url = db#url#parse(a:url)
  return [get(g:, 'dbext_default_ORA_bin', 'sqlplus'), '-L',
        \ get(url, 'user', 'system') . '/' . get(url, 'password', 'oracle') .
        \ '@' . s:conn(url)]
endfunction

function! db#adapter#oracle#filter(url) abort
  let cmd = db#adapter#oracle#interactive(a:url)
  call insert(cmd, '-S', 1)
  return cmd
endfunction

function! db#adapter#oracle#auth_pattern() abort
  return 'ORA-01017'
endfunction

function! db#adapter#oracle#dbext(url) abort
  let url = db#url#parse(a:url)
  return {'srvname': s:conn(url), 'host': '', 'port': '', 'dbname': ''}
endfunction

function! db#adapter#oracle#massage(input) abort
  if a:input =~# ";\s*\n*$"
    return a:input
  endif
  return a:input . "\n;"
endfunction
