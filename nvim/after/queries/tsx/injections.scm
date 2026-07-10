;; extends

((template_string) @injection.content
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#lua-match? @injection.content "^%s*([Ss][Ee][Ll][Ee][Cc][Tt]|[Ww][Ii][Tt][Hh]|[Bb][Ee][Gg][Ii][Nn]|[Ii][Nn][Ss][Ee][Rr][Tt]|[Uu][Pp][Dd][Aa][Tt][Ee]|[Dd][Ee][Ll][Ee][Tt][Ee]|[Cc][Rr][Ee][Aa][Tt][Ee]|[Aa][Ll][Tt][Ee][Rr]|[Dd][Rr][Oo][Pp])%s+"))

((string_fragment) @injection.content
  (#set! injection.language "sql")
  (#set! injection.include-children)
  (#lua-match? @injection.content "^%s*([Ss][Ee][Ll][Ee][Cc][Tt]|[Ww][Ii][Tt][Hh]|[Bb][Ee][Gg][Ii][Nn]|[Ii][Nn][Ss][Ee][Rr][Tt]|[Uu][Pp][Dd][Aa][Tt][Ee]|[Dd][Ee][Ll][Ee][Tt][Ee]|[Cc][Rr][Ee][Aa][Tt][Ee]|[Aa][Ll][Tt][Ee][Rr]|[Dd][Rr][Oo][Pp])%s+"))

((call_expression
  function: (identifier) @_sql
  arguments: (template_string) @injection.content)
  (#eq? @_sql "sql")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "sql")
  (#set! injection.include-children))
