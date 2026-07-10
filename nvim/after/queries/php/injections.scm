;; extends

; php-enhanced-treesitter only matches SELECT when FROM is on the same line.
; This covers multiline SELECT statements and @lang SQL/Oracle markers.
([
  (string_content)
  (nowdoc_body)
  (heredoc_body)
] @injection.content
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#any-lua-match? @injection.content
    "^%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+"
    "^%s*[Bb][Ee][Gg][Ii][Nn]%s+"
    "\n%s*[Ss][Ee][Ll][Ee][Cc][Tt]%s+"))

([
  (string_content)
  (nowdoc_body)
  (heredoc_body)
] @injection.content
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#any-lua-match? @injection.content "@lang%s+[Oo][Rr][Aa][Cc][Ll][Ee]" "@lang%s+[Ss][Qq][Ll]"))
