function! s:oracle_thin_to_oracle(url) abort
  let url = a:url

  " jdbc:oracle:thin:user/password@//host:1521/service
  let url = substitute(url,
        \ '^jdbc:oracle:thin:\([^/@:][^/]*\)/\([^@]*\)@//',
        \ 'oracle://\1:\2@', '')

  " jdbc:oracle:thin:@//host:1521/service
  let url = substitute(url, '^jdbc:oracle:thin:@//', 'oracle://', '')

  " jdbc:oracle:thin:@host:1521:SID
  let sid_match = matchlist(url, '^jdbc:oracle:thin:@\([^:]*\):\(\d\+\):\(.\+\)$')
  if !empty(sid_match)
    return 'oracle://' . sid_match[1] . ':' . sid_match[2] . '/' . sid_match[3]
  endif

  " jdbc:oracle:thin:user/password@host:1521:SID
  let sid_auth_match = matchlist(url, '^jdbc:oracle:thin:\([^/@:][^/]*\)/\([^@]*\)@\([^:]*\):\(\d\+\):\(.\+\)$')
  if !empty(sid_auth_match)
    return 'oracle://' . sid_auth_match[1] . ':' . sid_auth_match[2] . '@' . sid_auth_match[3] . ':' . sid_auth_match[4] . '/' . sid_auth_match[5]
  endif

  return url
endfunction

function! db#adapter#jdbc#canonicalize(url) abort
  let url = s:oracle_thin_to_oracle(a:url)
  if url =~# '^oracle:'
    return db#adapter#oracle#canonicalize(url)
  endif
  throw 'DB: JDBC URL is only configured for Oracle thin URLs'
endfunction

function! db#adapter#jdbc#interactive(url) abort
  return db#adapter#oracle#interactive(db#adapter#jdbc#canonicalize(a:url))
endfunction

function! db#adapter#jdbc#filter(url) abort
  return db#adapter#oracle#filter(db#adapter#jdbc#canonicalize(a:url))
endfunction

function! db#adapter#jdbc#auth_pattern() abort
  return db#adapter#oracle#auth_pattern()
endfunction

function! db#adapter#jdbc#dbext(url) abort
  return db#adapter#oracle#dbext(db#adapter#jdbc#canonicalize(a:url))
endfunction

function! db#adapter#jdbc#massage(input) abort
  return db#adapter#oracle#massage(a:input)
endfunction
